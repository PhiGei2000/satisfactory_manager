import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satisfactory_manager/data/database.dart';
import 'package:satisfactory_manager/data/factory.dart';
import 'package:satisfactory_manager/data/items.dart';
import 'package:satisfactory_manager/widgets/bottomNavigationBar.dart';

class LogisticsScreen extends StatefulWidget {
  static const String routeName = "/logistics";

  const LogisticsScreen({super.key});

  @override
  State<StatefulWidget> createState() => LogisticsScreenState();
}

class LogisticsScreenState extends State<LogisticsScreen> {
  ItemID? selectedItem;

  @override
  Widget build(BuildContext context) {
    Widget overview;

    if (selectedItem == null) {
      overview = Consumer<FactoryDatabase>(builder: (context, database, child) {
        final factories = database.factories;
        final totalValues = getTotalValues(factories);

        return DataTable(
            columns: const [
              DataColumn(label: Text("Item")),
              DataColumn(label: Text("Total consumption"), numeric: true),
              DataColumn(label: Text("Total production"), numeric: true)
            ],
            rows: totalValues.values
                .map((item) => DataRow(cells: [
                      DataCell(Text(item.item.itemName)),
                      DataCell(Text(item.inputRate.toString())),
                      DataCell(Text(item.outputRate.toString()))
                    ]))
                .toList());
      });
    } else {
      overview = Consumer<FactoryDatabase>(builder: (context, database, child) {
        final itemValues = getItemValues(database.factories, selectedItem!);
        itemValues["Total"] = itemValues.values.fold(
            Item(selectedItem!),
            (previousValue, element) => Item(selectedItem!,
                inputRate: previousValue.inputRate + element.inputRate,
                outputRate: previousValue.outputRate + element.outputRate));

        return DataTable(
            columns: const [
              DataColumn(label: Text("Factory")),
              DataColumn(label: Text("Consumption"), numeric: true),
              DataColumn(label: Text("Production"), numeric: true)
            ],
            rows: itemValues.entries
                .map((entry) => DataRow(cells: [
                      DataCell(Text(entry.key)),
                      DataCell(Text(entry.value.inputRate.toString())),
                      DataCell(Text(entry.value.outputRate.toString()))
                    ]))
                .toList());
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Logistics - ${selectedItem == null ? "total" : selectedItem!.itemName} production"),
        leading: const Icon(Icons.local_shipping),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    child: Autocomplete(
                  optionsBuilder: (value) =>
                      ItemID.itemNames.where((element) => element.toLowerCase().contains(value.text.toLowerCase())),
                  fieldViewBuilder: (context, controller, focusNode, defaultBuilder) => TextField(
                    controller: controller,
                    decoration: const InputDecoration(icon: Icon(Icons.search)),
                    focusNode: focusNode,
                  ),
                  onSelected: (value) => setState(() {
                    selectedItem = ItemID.getItem(value);
                  }),
                )),
              ],
            ),
          ),
          const Divider(),
          Expanded(
              child: SingleChildScrollView(
            child: overview,
          )),
        ],
      ),
      bottomNavigationBar: const FactoryManagerBottomNavigationBar(1),
    );
  }

  Map<ItemID, Item> getTotalValues(UnmodifiableListView<Factory> factories) {
    final totalValues = <ItemID, Item>{};

    for (final factory in factories) {
      for (final item in factory.items.values) {
        if (totalValues.containsKey(item.item)) {
          totalValues[item.item] = Item(item.item,
              inputRate: totalValues[item.item]!.inputRate + item.inputRate,
              outputRate: totalValues[item.item]!.outputRate + item.outputRate);
        } else {
          totalValues[item.item] = item;
        }
      }
    }

    return totalValues;
  }

  Map<String, Item> getItemValues(UnmodifiableListView<Factory> factories, ItemID item) => {
        for (final factory in factories.where((factory) => factory.items.containsKey(item)))
          factory.name: factory.items[item]!
      };
}
