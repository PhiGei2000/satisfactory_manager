import 'package:satisfactory_manager/data/items.dart';

class Item {
  final ItemID item;
  final num inputRate;
  final num outputRate;

  Item(this.item, {this.inputRate = 0, this.outputRate = 0});
}

class Factory {
  final String name;

  late final Map<ItemID, Item> items;

  Factory(this.name) {
    items = {};
  }

  Factory.withItems(this.name, Iterable<Item> items) {
    this.items = {for (var item in items) item.item: item};
  }

  void addItem(Item item) {
    items[item.item] = item;
  }

  void removeItem(Item item) {
    items.remove(item.item);
  }
}
