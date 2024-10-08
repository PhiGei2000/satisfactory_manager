import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satisfactory_manager/data/database.dart';
import 'package:satisfactory_manager/data/factory.dart';
import 'package:satisfactory_manager/widgets/itemDialog.dart';

class FactoryItemList extends StatelessWidget {
  final String factoryName;

  const FactoryItemList({super.key, this.factoryName = ""});

  @override
  Widget build(BuildContext context) {
    if (factoryName.isEmpty) {
      return const SizedBox();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("$factoryName - Production overview"),
      ),
      body: Consumer<FactoryDatabase>(builder: (context, database, child) {
        final factory = database.getFactory(factoryName)!;
        final items = factory.items.values;

        return DataTable(headingTextStyle: const TextStyle(fontWeight: FontWeight.bold), columns: const [
          DataColumn(label: Text("Item")),
          DataColumn(label: Text("Consumption"), numeric: true),
          DataColumn(label: Text("Production"), numeric: true),
          DataColumn(label: Text("")),
        ], rows: [
          for (final item in items) getDataRow(context, item)
        ]);
      }),
      floatingActionButton: FloatingActionButton(onPressed: () => addItem(context), child: const Icon(Icons.add)),
    );
  }

  void editEntry(BuildContext context, Item product) async {
    final newProduct = await showDialog<Item>(
        context: context, builder: (context) => ItemDialog("Edit product", item: product));

    if (newProduct == null) {
      return;
    }

    if (context.mounted) {
      Provider.of<FactoryDatabase>(context, listen: false).getFactory(factoryName)!.addItem(newProduct);
    }
  }

  void addItem(BuildContext context) async {
    final item =
        await showDialog<Item>(context: context, builder: (BuildContext context) => const ItemDialog("Add item"));

    if (item == null) {
      return;
    }

    if (context.mounted) {
      Provider.of<FactoryDatabase>(context, listen: false).addOrUpdateItem(factoryName, item);
    }
  }

  DataRow getDataRow(BuildContext context, Item item) => DataRow(cells: [
        DataCell(Text(item.item.toString())),
        DataCell(Text(item.inputRate.toString())),
        DataCell(Text(item.outputRate.toString())),
        DataCell(IconButton(onPressed: () => editEntry(context, item), icon: const Icon(Icons.edit)))
      ]);
}
