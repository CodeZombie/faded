import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

abstract class Playable extends ChangeNotifier {
  static const likeable = true;

  String title = "Unnamed";
  bool liked = false;

  void play(AudioPlayer player);

  void setLiked(bool liked) {
    this.liked = liked;
    if (liked) {
      //delete from the database
    } else {
      //store in database :3
    }
  }
}
