import 'package:faded/models/item_list.dart';
import 'package:faded/models/playermodel.dart';
import 'package:faded/models/tag_list.dart';
import 'package:faded/repositories/bandcamprepo.dart';
import 'package:faded/widgets/search_list.dart';
import 'package:flutter/material.dart';
import 'package:happycamper/happycamper.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const FadedApp());
}

class FadedApp extends StatelessWidget {
  const FadedApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Faded',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FadedMainWidget(
        title: 'Flutter Demo Home Page',
      ),
    );
  }
}

class FadedMainWidget extends StatefulWidget {
  const FadedMainWidget({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<FadedMainWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<FadedMainWidget> {
  late BandCampRepository bandCampRepository = BandCampRepository();
  ItemList itemList = ItemList();
  late TagList tagList = TagList(bandCampRepository);

  _MyHomePageState() {
    itemList = ItemList();
    itemList.items.add("Hello");
    itemList.items.add("World");
    itemList.items.add("My");
    itemList.items.add("Name");
    itemList.items.add("Is");
    itemList.items.add("Jeremy");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Text("Tags")),
                Tab(icon: Text("Playlists")),
                Tab(icon: Text("Albums")),
                Tab(icon: Text("Songs")),
              ],
            ),
            title: const Text('Tabs Demo'),
          ),
          body: TabBarView(
            children: [
              SearchList(tagList),
              const Icon(Icons.directions_transit),
              const Icon(Icons.directions_bike),
              SearchList(itemList),
            ],
          ),
        ),
      ),
    );
  }
}
