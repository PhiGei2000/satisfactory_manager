import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:satisfactory_manager/data/factory.dart';
import 'package:satisfactory_manager/data/items.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FactoryDatabase extends ChangeNotifier {
  late final Future<Database> _database;

  late final List<Factory> _factories;

  UnmodifiableListView<Factory> get factories => UnmodifiableListView(_factories);

  FactoryDatabase() {
    _factories = [];

    openFactoryDatabase();
  }

  Future<void> openFactoryDatabase() async {
    final path = join((await getApplicationSupportDirectory()).path, "satisfactory_manager.db");
    _database = openDatabase(path, version: 1, onCreate: _initDatabase, onOpen: _loadData);
  }

  void _initDatabase(Database db, int version) async {
    await db.execute("CREATE TABLE Factories(name TEXT PRIMARY KEY)");
    await db.execute(
        "CREATE TABLE FactoryItems(itemID INTEGER, factory TEXT REFERENCES Factories(name) ON UPDATE CASCADE, inputRate REAL, outputRate REAL, CONSTRAINT PK_FactoryItems PRIMARY KEY (itemID, factory))");
  }

  void _loadData(Database db) async {
    _factories.addAll(await db.query("Factories").then((factoryRows) async {
      final result = <Factory>[];
      for (final factoryRow in factoryRows) {
        final factoryName = factoryRow['name'] as String;
        final items =
            await db.query("FactoryItems", where: "factory = ?", whereArgs: [factoryName]).then((itemRows) => [
                  for (final itemRow in itemRows)
                    Item(ItemID.values[itemRow['itemID'] as int],
                        inputRate: itemRow['inputRate'] as num, outputRate: itemRow['outputRate'] as num)
                ]);

        result.add(Factory.withItems(factoryName, items));
      }

      return result;
    }));

    notifyListeners();
  }

  Factory? getFactory(String name) => _factories.where((factory) => factory.name == name).firstOrNull;

  Future<void> addFactory(Factory factory) async {
    if (_factories.any((element) => element.name == factory.name)) {
      throw ArgumentError("Another factory with the name \"${factory.name}\" already exists!");
    }

    _factories.add(factory);
    await (await _database).insert("Factories", {"name": factory.name});

    if (factory.items.isNotEmpty) {
      var sqlInsertItems =
          "INSERT INTO FactoryItems VALUES ${factory.items.values.map((e) => "(${e.item.index}, ${factory.name}, ${e.inputRate}, ${e.outputRate})").join(",")}";
      (await _database).execute(sqlInsertItems);
    }

    notifyListeners();
  }

  Future<void> renameFactory(String factoryName, String newName) async {
    if (!_factories.any((element) => element.name == factoryName)) {
      throw ArgumentError("No factory with the name \"$factoryName\" was found!");
    }

    final index = _factories.indexWhere((element) => element.name == factoryName);
    _factories[index] = Factory.withItems(newName, _factories[index].items.values);

    await _database
        .then((db) => db.update("Factories", {"name": newName}, where: "name = ?", whereArgs: [factoryName]));

    notifyListeners();
  }

  Future<void> removeFactory(String factoryName) async {
    _factories.removeWhere((element) => element.name == factoryName);

    await _database.then((db) => db.delete("Factories", where: "name = ?", whereArgs: [factoryName]));
    notifyListeners();
  }

  Future<void> addOrUpdateItem(String factoryName, Item item) async {
    final factory = getFactory(factoryName);
    if (factory == null) {
      throw ArgumentError("No factory with the name \"$factoryName\" was found!");
    }

    factory.addItem(item);

    final itemExists = await (_database
        .then((db) => db.query("FactoryItems",
            columns: ["COUNT(*)"], where: "itemID = ? AND factory = ?", whereArgs: [item.item.index, factoryName]))
        .then((i) => Sqflite.firstIntValue(i) ?? 0)
        .then((count) => count > 0));

    if (itemExists) {
      await _database.then((db) => db.update(
          "FactoryItems", {"itemID": item.item.index, "inputRate": item.inputRate, "outputRate": item.outputRate},
          where: "factory = ?", whereArgs: [factoryName]));
    } else {
      await _database.then((db) => db.insert("FactoryItems", {
            "itemID": item.item.index,
            "factory": factoryName,
            "inputRate": item.inputRate,
            "outputRate": item.outputRate
          }));
    }

    notifyListeners();
  }

  Future<void> removeItem(String factoryName, Item item) async {
    final factory = getFactory(factoryName);
    if (factory == null) {
      throw ArgumentError("No factory with the name \"$factoryName\" was found!");
    }

    if (factory.items.remove(item.item) != null) {
      await _database.then((db) =>
          db.delete("FactoryItems", where: "itemID = ? AND factory = ?", whereArgs: [item.item.index, factoryName]));

      notifyListeners();
    }
  }

  Future<void> removeItems(String factoryName, Iterable<Item> itemsToRemove) async {
    final itemIDs = itemsToRemove.map<ItemID>((item) => item.item);

    final batch = await _database.then<Batch>((db) => db.batch());
    for (final itemID in itemIDs) {
      batch.delete("FactoryItems", where: "itemID = ? AND factory = ?", whereArgs: [itemID.index, factoryName]);
    }

    await batch.commit(noResult: true, continueOnError: true);

    getFactory(factoryName)!.items.removeWhere((key, value) => itemIDs.contains(key));
    notifyListeners();
  }
}
