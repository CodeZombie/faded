import 'package:flutter/cupertino.dart';
import 'package:happycamper/happycamper.dart';
import 'package:happycamper/models/tagsearchresult.dart';
import 'package:happycamper/models/tag.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class BandCampRepository {
  late final HappyCamper happyCamper;
  List<String> likedTags = ["dubstep", "rock", "electro"];

  bool initialized = false;

  Future<void> initialize() async {
    if (initialized) {
      return;
    }
    WidgetsFlutterBinding.ensureInitialized();
    PermissionStatus value = await Permission.storage.request();
    if (value == PermissionStatus.granted) {
      final directory = await getApplicationSupportDirectory();
      happyCamper = HappyCamper(directory.path);
      initialized = true;
    }
  }

  Future<List<Tag>> getSimilarTags(String searchTerm) async {
    await initialize();
    List<Tag> tags = [];
    if (initialized) {
      TagSearchResult tagSearchResult = await happyCamper.getSimilarTags(searchTerm);
      for (Tag tag in tagSearchResult.tags) {
        tags.add(tag);
      }
    }
    return tags;
  }

  //TODO: we can get rid of the "item list" and 'tag list' classes and replace them with methods in the repository.
  //  For example, getLikedTags will return all liked tags with optional filtering.
  //  Another method, getSimilarTags, will return all tags matching a search term.
  //  Inside the TagSearchList Stateful Widget, we can have a method that is called
  //    when the user enters text into the search bar which calls getLikedTags and getSimilarTags and with their results calls
  //    setData() to put the results into the listview widget.
  //    Nothing complex, just some functions!!!
  Future<List<String>> getLikedTags(String searchTerm) async {
    List<String> filteredItems = [];
    for (String item in likedTags) {
      if (item.toLowerCase().contains(searchTerm.toLowerCase())) filteredItems.add(item);
    }
    return filteredItems;
  }
}
