import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/screens/login_screen.dart';
import 'package:firebasecommentapp/search_engine.dart';
import 'package:firebasecommentapp/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String currentSongTitle = "not yet";

  void refreshAllSongInfo() async {
    var songsData =
        await FirebaseFirestore.instance
            .collection('songs')
            .orderBy("number")
            .get();
    var songsInfo = [
      for (int i = 0; i < songsData.size; i++)
        Map<String, dynamic>.from(songsData.docs[i].data() as Map),
    ]; //역대 모든 노래들 불러오기.

    for (Map<String, dynamic> songInfo in songsInfo) {
      String url = songInfo["youtube_url"];
      if (songInfo["number"] != 2) {
        continue;
      }

      currentSongTitle = songInfo["title"];
      setState(() {});
      var yt = YoutubeExplode();
      var video = await yt.videos.get(url);
      String title = video.title;
      String artist = video.author;
      int views = video.engagement.viewCount;
      int likes = video.engagement.likeCount ?? 0;
      String channelUrl = "";
      int subscriber = 0;
      String channelProfileUrl = "";
      channelUrl = "https://www.youtube.com/channel/${video.channelId}";

      var channel = await yt.channels.get(channelUrl);
      channelProfileUrl = channel.logoUrl;
      subscriber = channel.subscribersCount ?? 0;

      List<String> keywordsTitle = module1(title, "");
      List<String> keywordsArtist = module1(artist, "");
      List<String> keywords = keywordsTitle + keywordsArtist;

      List<List<String>> searchTagTitle = await module2(keywordsTitle);
      List<String> searchTag0Title = searchTagTitle[0];
      List<String> searchTag1Title = searchTagTitle[1];
      List<String> searchTag2Title = searchTagTitle[2];

      List<List<String>> searchTagArtist = await module2(keywordsArtist);
      List<String> searchTag0Artist = searchTagArtist[0];
      List<String> searchTag1Artist = searchTagArtist[1];
      List<String> searchTag2Artist = searchTagArtist[2];

      List<String> searchTag0 = searchTag0Title + searchTag0Artist;
      List<String> searchTag1 = searchTag1Title + searchTag1Artist;
      List<String> searchTag2 = searchTag2Title + searchTag2Artist;

      var newSongInfo = {
        "albumcover": songInfo["albumcover"],
        "artist": artist,
        "comment_numbers": songInfo["comment_numbers"],
        "likes": likes,
        "report_count": songInfo["report_count"],
        "search_tag0": searchTag0,
        "search_tag1": searchTag1,
        "search_tag2": searchTag2,
        "title": title,
        "views": views,
        "youtube_url": url,
        "rating": songInfo["rating"],
        "number": songInfo["number"],
        "keywords": keywords,
      };

      FirebaseFirestore.instance
          .collection('songs')
          .doc('song${songInfo["number"]}')
          .set(newSongInfo);

      await artistsInfoPreLoadUpdate();

      int artistDB = 0;
      for (var artistM in artistsInfoPreLoad) {
        if (artistM["name"] == artist) {
          artistDB = artistM["number"];
        }
      }

      if (artistDB == 0) {
        Map<String, dynamic> newArtist = {
          "number": artistsInfoPreLoad.length,
          "channel_url": channelUrl,
          "keywords": keywordsArtist,
          "name": artist,
          "profile_image": channelProfileUrl,
          "search_tag0": searchTag0Artist,
          "search_tag1": searchTag1Artist,
          "search_tag2": searchTag2Artist,
          "songs": [songInfo["number"]],
          "subscriber": subscriber,
        };

        FirebaseFirestore.instance
            .collection('artists')
            .doc('artist${newArtist["number"]}')
            .set(newArtist);
      } else {
        Map<String, dynamic> artistInfo = artistsInfoPreLoad[artistDB];
        artistInfo["songs"].add(songInfo["number"]);
        FirebaseFirestore.instance
            .collection('artists')
            .doc('artist${artistInfo["number"]}')
            .set(artistInfo);
      }

      await artistsInfoPreLoadUpdate();

      currentSongTitle = "update ${songInfo["number"]} done";
      await songsInfoPreLoadUpdate();
      setState(() {});
    }

    currentSongTitle = "update All done";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("admin access")),
      bottomNavigationBar: myBottomNavigationBar(currentWidgetName: ""),
      body: Center(
        child: Column(
          children: [
            IconButton(
              onPressed: () {
                refreshAllSongInfo();
              },
              icon: Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('loginUserNumber', -1);
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            LoginScreen(),
                  ),
                );
              },
              icon: Icon(Icons.logout),
            ),
            Text(currentSongTitle),
          ],
        ),
      ),
    );
  }
}
