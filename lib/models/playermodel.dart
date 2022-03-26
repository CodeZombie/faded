import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:happycamper/models/tag.dart';
import 'package:happycamper/models/tagsearchresult.dart';
import 'package:happycamper/happycamper.dart';
import 'package:path_provider/path_provider.dart';

class PlayerModel extends ChangeNotifier  {
  final List<Tag> tags = [Tag("fake-genre", "Fake Genre")];
  late final HappyCamper happyCamper;

  bool initialized = false;

  Future<void> initialize() async {
    if (initialized) {
      return;
    }
    WidgetsFlutterBinding.ensureInitialized();
    final directory = await getApplicationSupportDirectory();
    happyCamper = HappyCamper(directory.path);
    print("Hive Intialized for the first time.");
    initialized = true;
  }
  
  void searchForSimilarTags(String searchTerm) async {
    await initialize();
    TagSearchResult tagSearchResult = await happyCamper.getSimilarTags(searchTerm);
    tags.clear();
    for (Tag tag in tagSearchResult.tags) {
      tags.add(tag);
    }
    notifyListeners();
  }
}