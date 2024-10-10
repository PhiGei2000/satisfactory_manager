import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satisfactory_manager/data/database.dart';
import 'package:satisfactory_manager/data/factory.dart';
import 'package:satisfactory_manager/widgets/itemDialog.dart';

class FactoryItemList extends StatefulWidget {
  final String factoryName;

  const FactoryItemList({super.key, this.factoryName = ""});

  @override
  State<StatefulWidget> createState() => FactoryItemListState();
}

class FactoryItemListState extends State<FactoryItemList> {
  Set<int> selectedRows = <int>{};

  @override
  Widget build(BuildContext context) {
    if (widget.factoryName.isEmpty) {
      return const SizedBox();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.factoryName} - Production overview"),
      ),
      body: SingleChildScrollView(
        child: Consumer<FactoryDatabase>(builder: (context, database, child) {
          final factory = database.getFactory(widget.factoryName)!;
          final items = factory.items.values;

          return SizedBox(
            width: double.infinity,
            child: DataTable(
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
              columns: const [
                DataColumn(label: Text("Item")),
                DataColumn(label: Text("Consumption"), numeric: true),
                DataColumn(label: Text("Production"), numeric: true),
              ],
              rows: [
                for (final (index, item) in items.indexed)
                  DataRow(
                    cells: [
                      DataCell(Text(item.item.toString()), onTap: () => editEntry(item)),
                      DataCell(Text(item.inputRate.toString()), onTap: () => editEntry(item)),
                      DataCell(Text(item.outputRate.toString()), onTap: () => editEntry(item)),
                    ],
                    selected: selectedRows.contains(index),
                    onLongPress: () => toggleSelectRow(index),
                  )
              ],
            ),
          );
        }),
      ),
      floatingActionButton: selectedRows.isNotEmpty
          ? FloatingActionButton(onPressed: removeItems, child: const Icon(Icons.delete))
          : FloatingActionButton(onPressed: addItem, child: const Icon(Icons.add)),
    );
  }

  void toggleSelectRow(int index) {
    if (selectedRows.contains(index)) {
      setState(() {
        selectedRows.remove(index);
      });
    } else {
      setState(() {
        selectedRows.add(index);
      });
    }
  }

  void editEntry(Item product) async {
    final newProduct =
        await showDialog<Item>(context: context, builder: (context) => ItemDialog("Edit product", item: product));

    if (newProduct == null) {
      return;
    }

    if (context.mounted) {
      final database = Provider.of<FactoryDatabase>(context, listen: false);

      if (newProduct.item != product.item) {
        await database.removeItem(widget.factoryName, product);
      } else {
        await database.addOrUpdateItem(widget.factoryName, newProduct);
      }
    }
  }

  void addItem() async {
    final item =
        await showDialog<Item>(context: context, builder: (BuildContext context) => const ItemDialog("Add item"));

    if (item == null) {
      return;
    }

    if (context.mounted) {
      Provider.of<FactoryDatabase>(context, listen: false).addOrUpdateItem(widget.factoryName, item);
    }
  }

  void removeItems() async {
    final dialogResult = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Remove items"),
              content: const Text("Are you sure, that you want to remove the selected entries?"),
              actions: [
                IconButton(onPressed: () => Navigator.pop(context, true), icon: const Icon(Icons.done)),
                IconButton(onPressed: () => Navigator.pop(context, false), icon: const Icon(Icons.close))
              ],
            ));

    if (dialogResult ?? false) {
      if (context.mounted) {
        final database = Provider.of<FactoryDatabase>(context, listen: false);
        final itemsToRemove = database
            .getFactory(widget.factoryName)!
            .items
            .values
            .indexed
            .where((element) => selectedRows.contains(element.$1))
            .map((e) => e.$2);

        await database.removeItems(widget.factoryName, itemsToRemove);
        setState(() {
          selectedRows = <int>{};
        });
      }
    }
  }
}
