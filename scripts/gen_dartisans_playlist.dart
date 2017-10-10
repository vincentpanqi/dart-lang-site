import 'dart:io';
import 'dart:async';

import 'youtube.dart' as youtube;

final String PLAYLIST_ID = 'PLOU2XLYxmsIIS2zgjdmBEwTrA6m5YgHBs';

final String OUTPUT_FILENAME = 'src/site/dartisans/episodes.yaml';

writePlaylistYaml(Directory directory, Map playlist) {
  var episodeOffset = 1;
  var file = new File('${directory.path}/../$OUTPUT_FILENAME');
  var output = file.openWrite();
  output.write("""
# DO NOT EDIT THIS FILE - IT IS AUTOGENERATED
# See scripts/gen_dartisans_playlist.dart
url-prefix: http://commondatastorage.googleapis.com/dartlang-podcast/
episodes:
""");
  var entries = playlist['feed']['entry'];
  for (var i = 0; i < entries.length; i++) {
    var epNum = entries.length - i + episodeOffset;
    writeEntry(output, entries[i], epNum);
  }
  output.close();
}

writeEntry(IOSink out, Map entry, int epNum) {
  String playerUrl = entry[r'media$group'][r'media$player'][0]['url'];
  String youtubeId = new RegExp("v=(.*)&").firstMatch(playerUrl)[1];
  String title = entry['title'][r'$t'];
  String subtitle;
  Match match = new RegExp(r": (.*)$").firstMatch(title);
  if (match == null) {
    print("Title '$title' does not have a :");
    return;
  } else {
    subtitle = match[1];
  }
  String thumbnail = entry[r'media$group'][r'media$thumbnail'][0]['url'];
  String recorded;
  if (entry[r'yt$recorded'] == null) {
    print("No explicit recorded date for $title. Please set.");
    return;
  } else {
    recorded = entry[r'yt$recorded'][r'$t'];
  }
  String desc = entry['content'][r'$t']
                  .replaceAll("\n", ' ')
                  .replaceAll('"', "'");

  out.write("""
- title: "${title}"
  subtitle: "${subtitle}"
#  file: unknown.mp3
  pubdate: ${recorded}
  description: "${desc}"
#  length: 21815187
  num: $epNum
  youtubeid: $youtubeId
  thumbnail: $thumbnail
""");
}

main() {
  var script = new File(new Options().script);

  youtube.fetchPlaylist(PLAYLIST_ID)
  .then((Map data) {
    writePlaylistYaml(script.directory, data);
    print("Complete!");
  });
}