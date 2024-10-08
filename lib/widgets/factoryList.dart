import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satisfactory_manager/data/factory.dart';
import 'package:satisfactory_manager/widgets/textDialog.dart';

import '../data/database.dart';
import '../screens/factoryScreen.dart';

class FactoryList extends StatelessWidget {
  final void Function(String) onFactorySelected;
  final void Function(String) onRemoveFactory;

  const FactoryList(this.onFactorySelected, this.onRemoveFactory, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FactoryDatabase>(builder: (BuildContext context, FactoryDatabase database, Widget? child) {
        final colorScheme = Theme.of(context).colorScheme;
        final factories = database.factories;

        return ListView.builder(
          itemBuilder: (BuildContext context, int index) => GestureDetector(
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 5),
              color: colorScheme.surface,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Expanded(
                    child: Text(
                  factories[index].name,
                )),
                IconButton(
                    onPressed: () => renameFactory(context, factories[index].name), icon: const Icon(Icons.edit)),
                IconButton(onPressed: () => removeFactory(context, factories[index]), icon: const Icon(Icons.delete))
              ]),
            ),
            onTap: () => onFactorySelected(factories[index].name),
          ),
          itemCount: factories.length,
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createFactory(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void createFactory(BuildContext context) async {
    final factoryName = await showDialog<String>(
        context: context, builder: (BuildContext context) => const TextDialog(title: "New Factory"));

    if (factoryName == null) {
      return;
    }

    if (context.mounted) {
      Provider.of<FactoryDatabase>(context, listen: false).addFactory(Factory(factoryName));
    }
  }

  void renameFactory(BuildContext context, String factoryName) async {
    final newName = await showDialog<String>(
        context: context, builder: (context) => TextDialog(initialText: factoryName, title: "Rename \"$factoryName\""));

    if (newName == null) {
      return;
    }

    if (context.mounted) {
      Provider.of<FactoryDatabase>(context, listen: false).renameFactory(factoryName, newName);
    }
  }

  void removeFactory(BuildContext context, Factory factory) async {
    final dialogResult = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Remove \"${factory.name}\""),
              content: Text("Are you sure, that you want to remove \"${factory.name}\"?"),
              actions: [
                IconButton(onPressed: () => Navigator.pop(context, true), icon: const Icon(Icons.done)),
                IconButton(onPressed: () => Navigator.pop(context, false), icon: const Icon(Icons.close))
              ],
            ));

    if (dialogResult ?? false) {
      if (context.mounted) {
        Provider.of<FactoryDatabase>(context, listen: false).removeFactory(factory.name);
        onRemoveFactory(factory.name);
      }
    }
  }
}
