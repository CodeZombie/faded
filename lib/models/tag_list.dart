import 'dart:async';

import 'package:faded/models/item_list.dart';
import 'package:faded/repositories/bandcamprepo.dart';
import 'package:happycamper/models/tag.dart';

class TagList extends ItemList {
  late BandCampRepository bandCampRepository;
  Timer? searchTimer;

  TagList(this.bandCampRepository) : super();

  Future<List<String>> getFilteredItems(String searchTerm) async {
    searchTimer?.cancel();
    Completer completer = Completer();
    searchTimer = Timer(const Duration(seconds: 1), () => completer.complete());
    await completer.future;

    List<Tag> tags = await bandCampRepository.getSimilarTags(searchTerm);
    List<String> additionalItems = [];
    for (Tag tag in tags) {
      additionalItems.add(tag.name);
    }
    List<String> superItems = await super.getFilteredItems(searchTerm);
    return superItems + additionalItems;
  }
}
