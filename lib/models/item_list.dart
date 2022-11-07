import 'package:flutter/foundation.dart';

class ItemList extends ChangeNotifier {
  List<String> items = [];
  List<String> filteredItems = [];

  Future<List<String>> getFilteredItems(String searchTerm) async {
    List<String> filteredItems = [];
    for (String item in items) {
      if (item.toLowerCase().contains(searchTerm.toLowerCase())) filteredItems.add(item);
    }
    return filteredItems;
  }
}
