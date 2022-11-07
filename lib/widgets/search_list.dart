import 'package:faded/models/item_list.dart';
import 'package:faded/widgets/itempanel.dart';
import 'package:flutter/material.dart';

class SearchList extends StatefulWidget {
  ItemList itemList;
  List<String> items = [];

  SearchList(this.itemList, {Key? key}) : super(key: key);

  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  TextEditingController searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchTextController.addListener(onSearchTextChanged);
    //searchTextController.text = widget.itemList.searchTerm;
    onSearchTextChanged();
  }

  void onSearchTextChanged() async {
    widget.itemList.getFilteredItems(searchTextController.text).then((value) {
      setState(() {
        widget.items = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(
        controller: searchTextController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter a search term',
        ),
      ),
      Expanded(
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.items.length,
          itemBuilder: ((context, index) {
            final item = widget.items[index];
            return ItemPanel(item);
          }),
        ),
      )
    ]);
  }
}
