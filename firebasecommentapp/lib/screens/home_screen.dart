import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/widgets/bottom_navigation_bar.dart';
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
  List<dynamic> mostRecommendedSongs = [];
  List<dynamic> mostLikedSongs = [];
  List<dynamic> interestedArtistsSongs = [];
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

    songsInfoPreLoad = songsInfoPrePreLoad;
    commentsInfoPreLoad = commentsInfoPrePreLoad;
    usersInfoPreLoad = usersInfoPrePreLoad;
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
    getInterestedArtistOrders();
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

  void getInterestedArtistOrders() {
    // var userData =
    //     await FirebaseFirestore.instance
    //         .collection('users')
    //         .doc('user$loginUserNumber')
    //         .get();
    Map<String, dynamic> userInfo = usersInfoPreLoad[loginUserNumber];
    List<dynamic> commentedSongs = userInfo["commented_songs"];
    List<dynamic> commentedArtist = [];

    // if (commentedArtist.length * commentedSongs.length == 0) {
    //   return;
    // }

    for (int songNumber in commentedSongs) {
      commentedArtist.add(songsInfo[songNumber]["artist"]);
    }

    //댓글을 단 노래의 아티스트를 많이 나온 순서대로 정렬.
    commentedArtist.sort(
      (a, b) => commentedArtist
          .where((element) {
            return b == element;
          })
          .length
          .compareTo(
            commentedArtist.where((element) {
              return a == element;
            }).length,
          ),
    );

    //중복제거
    commentedArtist = commentedArtist.toSet().toList();

    for (String artist in commentedArtist) {
      interestedArtistsSongs =
          [
            interestedArtistsSongs,
            searchFunc(artist),
          ].expand((x) => x).toList();
    }

    setState(() {});
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

    songsInfoCopy.sort(
      (a, b) => recommendPointFunc(
        b["views"],
        b["comment_numbers"].length,
        b["likes"],
        b["rating"].toDouble(),
        b["report_count"],
      ).compareTo(
        recommendPointFunc(
          a["views"],
          a["comment_numbers"].length,
          a["likes"],
          a["rating"].toDouble(),
          a["report_count"],
        ),
      ),
    );
    mostRecommendedSongs = List.from([
      for (var m in songsInfoCopy) m["number"],
    ]);

    songsInfoPreLoad = songsInfo;
    mostRecommendedSongsPreLoad = mostRecommendedSongs;

    isLoad = true;

    setState(() {});
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
                orderByText: "추천순 Top 3",
                songsList: mostRecommendedSongs,
                songsInfo: songsInfo,
              ),

              OrderedSongsWidget(
                orderByText: "좋아하는 아티스트",
                songsList: interestedArtistsSongs,
                songsInfo: songsInfo,
              ),

              OrderedSongsWidget(
                orderByText: "추천순",
                songsList: mostRecommendedSongs,
                songsInfo: songsInfo,
              ),

              OrderedSongsWidget(
                orderByText: "최다 조회수",
                songsList: mostViewedSongs,
                songsInfo: songsInfo,
              ),

              OrderedSongsWidget(
                orderByText: "최고 평점",
                songsList: mostRatedSongs,
                songsInfo: songsInfo,
              ),
              OrderedSongsWidget(
                orderByText: "최근 추가됨",
                songsList: latelyAddedSongs,
                songsInfo: songsInfo,
              ),
              OrderedSongsWidget(
                orderByText: "최근 댓글 달림",
                songsList: latelyCommentedSongs,
                songsInfo: songsInfo,
              ),

              OrderedSongsWidget(
                orderByText: "최다 댓글",
                songsList: mostCommentedSongs,
                songsInfo: songsInfo,
              ),
              OrderedSongsWidget(
                orderByText: "최다 좋아요",
                songsList: mostLikedSongs,
                songsInfo: songsInfo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
