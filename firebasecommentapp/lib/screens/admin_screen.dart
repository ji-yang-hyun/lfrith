import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasecommentapp/screens/login_screen.dart';
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
      if (songInfo["number"] == 0) {
        continue;
      }

      currentSongTitle = songInfo["title"];
      setState(() {});
      var yt = YoutubeExplode();
      var video = await yt.videos.get(url);
      String albumCoverImgUrl = video.thumbnails.maxResUrl;
      String title = video.title;
      String artist = video.author;
      int views = video.engagement.viewCount;
      int likes = video.engagement.likeCount ?? 0;

      String description = video.description;
      String searchTag = (artist + title + description)
          .toLowerCase()
          .replaceAll(" ", "")
          .replaceAll("\n", "");

      var newSongInfo = {
        "albumcover": albumCoverImgUrl,
        "artist": artist,
        "comment_numbers": songInfo["comment_numbers"],
        "likes": likes,
        "report_count": songInfo["report_count"],
        "search_tag": searchTag,
        "title": title,
        "views": views,
        "youtube_url": url,
        "rating": songInfo["rating"],
        "number": songInfo["number"],
      };

      FirebaseFirestore.instance
          .collection('songs')
          .doc('song${songInfo["number"]}')
          .set(newSongInfo);

      currentSongTitle = "update ${songInfo["number"]} done";
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
