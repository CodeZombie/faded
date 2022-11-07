import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemPanel extends StatelessWidget {
  late final String label;

  ItemPanel(this.label, {Key? key}) : super(key: key);

  @override
  Widget build(Object context) {
    return Card(child: Padding(padding: EdgeInsets.all(16.0), child: Text(label)));
  }
}
