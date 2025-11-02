import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/widgets/bottom_navigation_bar.dart';
import 'package:firebasecommentapp/widgets/ordered_artists_widget.dart';
import 'package:firebasecommentapp/widgets/ordered_songs_top_widget.dart';
import 'package:firebasecommentapp/widgets/ordered_songs_widget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> songsInfo = [];
  List<dynamic> latelyAddedSongs = [];
  List<dynamic> latelyCommentedSongs = [];
  List<dynamic> mostViewedSongs = [];
  List<dynamic> mostRatedSongs = [];
  List<dynamic> mostCommentedSongs = [];
  List<dynamic> mostLikedSongs = [];
  List<dynamic> interestedArtists = [];
  List<dynamic> logRecommandSongs = [];

  bool isLoad = false;

  void updatePreLoad() async {
    if (newLikedComments.isNotEmpty || newUnLikedComments.isNotEmpty) {
      return;
    }

    List<Map<String, dynamic>> songsInfoPrePreLoad =
        await songsInfoPreLoadUpdate(mode: 1);
    List<Map<String, dynamic>> commentsInfoPrePreLoad =
        await commentsInfoPreLoadUpdate(mode: 1);
    List<Map<String, dynamic>> usersInfoPrePreLoad =
        await usersInfoPreLoadUpdate(mode: 1);
    List<Map<String, dynamic>> artistsInfoPrePreLoad =
        await artistsInfoPreLoadUpdate(mode: 1);

    songsInfoPreLoad = songsInfoPrePreLoad;
    commentsInfoPreLoad = commentsInfoPrePreLoad;
    usersInfoPreLoad = usersInfoPrePreLoad;
    artistsInfoPreLoad = artistsInfoPrePreLoad;
    getSongsInfo();
    setState(() {});

    print("update done!");
  }

  void getSongsInfo() async {
    // var songsData =
    //     await FirebaseFirestore.instance
    //         .collection('songs')
    //         .orderBy("number")
    //         .get();
    // songsInfo = [
    //   for (int i = 0; i < songsData.size; i++)
    //     Map<String, dynamic>.from(songsData.docs[i].data() as Map),
    // ]; //역대 모든 노래들 불러오기.

    songsInfo = songsInfoPreLoad;

    getLatelyOrders();
    getInfoByOrders();
    getLogByOrders();
    setState(() {});
  }

  List<int> searchFunc(String keyword) {
    //기본적으로 조회수 순으로 정렬해서 찾아준다
    List<Map<String, dynamic>> songsInfoCopy = List.from(songsInfo);
    songsInfoCopy.sort((a, b) => b["views"].compareTo(a["views"]));
    List<int> artistsSongs = [];

    for (int i = 1; i < songsInfoCopy.length; i++) {
      if (songsInfoCopy[i]["artist"] == keyword) {
        artistsSongs.add(songsInfoCopy[i]["number"]);
      }
      if (artistsSongs.length >= 5) {
        return artistsSongs;
      }
    }

    return artistsSongs;
  }

  void getLatelyOrders() async {
    var latelyData =
        await FirebaseFirestore.instance
            .collection('home')
            .doc('home_screen_data')
            .get();
    Map<String, dynamic> latelyInfo = Map<String, dynamic>.from(
      latelyData.data() as Map,
    );

    latelyAddedSongs = List.from(latelyInfo["lately_added"].reversed);

    latelyCommentedSongs = List.from(latelyInfo["lately_commented"].reversed);

    setState(() {});
  }

  void getInfoByOrders() {
    List<Map<String, dynamic>> songsInfoCopy = List.from(songsInfo);
    songsInfoCopy.sort((a, b) => b["views"].compareTo(a["views"]));
    mostViewedSongs = List.from([for (var m in songsInfoCopy) m["number"]]);

    songsInfoCopy.sort((a, b) => b["rating"].compareTo(a["rating"]));
    mostRatedSongs = List.from([for (var m in songsInfoCopy) m["number"]]);

    songsInfoCopy.sort(
      (a, b) =>
          b["comment_numbers"].length.compareTo(a["comment_numbers"].length),
    );
    mostCommentedSongs = List.from([for (var m in songsInfoCopy) m["number"]]);

    songsInfoCopy.sort((a, b) => b["likes"].compareTo(a["likes"]));
    mostLikedSongs = List.from([for (var m in songsInfoCopy) m["number"]]);

    isLoad = true;

    setState(() {});
  }

  void getLogByOrders() {
    if (loginUserNumber == -1) {
      return;
    }

    Map<String, int> artistPoints = {};

    if (usersInfoPreLoad[loginUserNumber]["user_visit_log"].length == 0) {
      return;
    }

    for (int num in usersInfoPreLoad[loginUserNumber]["commented_songs"]) {
      artistPoints[songsInfoPreLoad[num]["artist"]] =
          (artistPoints[songsInfoPreLoad[num]["artist"]] ?? 0) + 5;
    }
    for (int num in usersInfoPreLoad[loginUserNumber]["user_visit_log"]) {
      artistPoints[songsInfoPreLoad[num]["artist"]] =
          (artistPoints[songsInfoPreLoad[num]["artist"]] ?? 0) + 1;
    }

    List<String> artists = artistPoints.keys.toList();
    artists.sort((a, b) => artistPoints[b]!.compareTo(artistPoints[a]!));

    List<int> songsSorted = [];
    List<Map<String, dynamic>> songsInfoCopy = List.from(songsInfoPreLoad);
    songsInfoCopy.sort(
      (a, b) => (artistPoints[b["artist"]] ?? -1).compareTo(
        (artistPoints[a["artist"]] ?? -1),
      ),
    );

    int cnt = 0;
    for (int i = 0; i < songsInfoCopy.length; i++) {
      if (i != 0) {
        if (songsInfoCopy[i - 1]["artist"] != songsInfoCopy[i]["artist"]) {
          cnt = 0;
        }
      }

      if (cnt < 3) {
        // print(usersInfoPreLoad[loginUserNumber]);
        if (!usersInfoPreLoad[loginUserNumber]["commented_songs"].contains(
              songsInfoCopy[i]["number"],
            ) &&
            !usersInfoPreLoad[loginUserNumber]["user_visit_log"].contains(
              songsInfoCopy[i]["number"],
            )) {
          cnt += 1;
          songsSorted.add(songsInfoCopy[i]["number"]);
        }
      }
    }

    bool check = false;
    for (int num in songsSorted) {
      if (songsInfoPreLoad[num]["report_count"] < 10) {
        check = true;
      }
    }
    if (check) {
      logRecommandSongs = songsSorted;
    }

    List<Map<String, dynamic>> artistsInfoCopy = List.from(artistsInfoPreLoad);
    artistsInfoCopy.sort(
      (a, b) => (artistPoints[b["name"]] ?? -1).compareTo(
        (artistPoints[a["name"]] ?? -1),
      ),
    );

    interestedArtists = [for (var artist in artistsInfoCopy) artist["number"]];
    interestedArtists.remove(0);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState

    getSongsInfo();
    updatePreLoad(); // 여기서 한 번 preLoadUpdate, 전부 다.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Hero(
        tag: "bar",
        child: myBottomNavigationBar(currentWidgetName: "HOME"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              OrderedSongsTopWidget(
                orderByText: "  이번 주 추천 Top 3",
                songsList: recommandWeek,
                songsInfo: songsInfoPreLoad,
              ),

              OrderedSongsWidget(
                orderByText: "활동 기반 추천",
                songsList: logRecommandSongs,
                songsInfo: songsInfoPreLoad,
              ),

              OrderedArtistsWidget(
                orderByText: "관심있는 아티스트",
                artistsList: interestedArtists,
                artistsInfo: artistsInfoPreLoad,
              ),

              OrderedSongsWidget(
                orderByText: "최다 조회수",
                songsList: mostViewedSongs,
                songsInfo: songsInfoPreLoad,
              ),

              OrderedSongsWidget(
                orderByText: "최고 평점",
                songsList: mostRatedSongs,
                songsInfo: songsInfoPreLoad,
              ),
              OrderedSongsWidget(
                orderByText: "최근 추가됨",
                songsList: latelyAddedSongs,
                songsInfo: songsInfoPreLoad,
              ),
              OrderedSongsWidget(
                orderByText: "최근 댓글 추가됨",
                songsList: latelyCommentedSongs,
                songsInfo: songsInfoPreLoad,
              ),

              OrderedSongsWidget(
                orderByText: "최다 댓글수",
                songsList: mostCommentedSongs,
                songsInfo: songsInfoPreLoad,
              ),
              OrderedSongsWidget(
                orderByText: "최다 좋아요",
                songsList: mostLikedSongs,
                songsInfo: songsInfoPreLoad,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
