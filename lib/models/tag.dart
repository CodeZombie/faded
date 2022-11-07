import 'package:audioplayers/audioplayers.dart';
import 'package:faded/models/playable.dart';

class Tag extends Playable {
  Tag(String title) {
    this.title = title;
  }

  @override
  void play(AudioPlayer player) {
    //Hit happycamper for a Track based on this tag.
    //Then play said Track in the player.
  }
}
