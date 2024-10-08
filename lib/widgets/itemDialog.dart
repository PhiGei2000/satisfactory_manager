import 'package:flutter/material.dart';
import 'package:satisfactory_manager/data/factory.dart';
import 'package:satisfactory_manager/data/items.dart';

class ItemDialog extends StatefulWidget {
  final String title;

  final Item? item;

  const ItemDialog(this.title, {super.key, this.item});

  @override
  State<StatefulWidget> createState() => ItemDialogState();
}

class ItemDialogState extends State<ItemDialog> {
  late ItemID? item;
  late final TextEditingController _consumptionController;
  late final TextEditingController _productionController;

  String itemNameHint = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    item = widget.item?.item;
    _consumptionController = TextEditingController(text: widget.item?.inputRate.toString());
    _productionController = TextEditingController(text: widget.item?.outputRate.toString());
  }

  @override
  void dispose() {
    _consumptionController.dispose();
    _productionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 0.8 * screenSize.width,
        height: 0.5 * screenSize.height,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Autocomplete(
                  optionsBuilder: (TextEditingValue textEditingValue) => ItemID.itemNames
                      .where((element) => element.toLowerCase().contains(textEditingValue.text.toLowerCase())),
                  fieldViewBuilder: (context, controller, focusNode, defaultBuilder) => TextField(
                    decoration: const InputDecoration(labelText: "Item"),
                    controller: controller,
                    focusNode: focusNode,
                  ),
                  initialValue: item == null ? null : TextEditingValue(text: item.toString()),
                  onSelected: (String value) => setState(() {
                    item = ItemID.getItem(value);
                  }),
                )),
            Row(children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: "Input rate"),
                    controller: _consumptionController,
                    validator: validateProductionNumbers,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: "Output rate"),
                    controller: _productionController,
                    validator: validateProductionNumbers,
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
      actions: [
        IconButton(onPressed: submit, icon: const Icon(Icons.done)),
        IconButton(onPressed: cancel, icon: const Icon(Icons.close)),
      ],
    );
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
          context,
          Item(item!,
              inputRate: _consumptionController.text.isEmpty ? 0 : num.parse(_consumptionController.text),
              outputRate: _productionController.text.isEmpty ? 0 : num.parse(_productionController.text)));
    }
  }

  void cancel() {
    Navigator.pop(context, null);
  }

  String? validateProductionNumbers(String? value) {
    const text = "Enter a non negative number";
    if (value == null) {
      return text;
    }

    if (value.isEmpty) {
      return null;
    }

    num? result = num.tryParse(value);
    if (result == null) {
      return text;
    }

    return result >= 0 ? null : text;
  }

  String? validateItemName(String? value) {
    const text = "Enter a valid item name";

    if (value == null || value.isEmpty) {
      return text;
    }

    if (!ItemID.values.map((e) => e.itemName).contains(value)) {
      return text;
    }
    return null;
  }
}
