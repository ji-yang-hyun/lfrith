import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/screens/home_screen.dart';
import 'package:firebasecommentapp/screens/search_screen.dart';
import 'package:firebasecommentapp/screens/song_screen.dart';
import 'package:firebasecommentapp/widgets/bottom_navigation_bar.dart';
import 'package:firebasecommentapp/widgets/ordered_songs_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ArtistScreen extends StatefulWidget {
  const ArtistScreen({
    super.key,
    required this.artistInfo,
    required this.screenNumber,
  });
  final Map<String, dynamic> artistInfo;
  final int screenNumber;

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  ScrollController controller = ScrollController();
  List<Map<String, dynamic>> songsInfo = [];
  List<dynamic> latelyAddedSongs = [];
  List<dynamic> latelyCommentedSongs = [];
  List<dynamic> mostViewedSongs = [];
  List<dynamic> mostRatedSongs = [];
  List<dynamic> mostCommentedSongs = [];
  List<dynamic> mostRecommendedSongs = [];
  List<dynamic> mostLikedSongs = [];
  List<dynamic> interestedArtistsSongs = [];
  List<dynamic> logRecommandSongs = [];
  int opacity = 0;

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

    for (int num in widget.artistInfo["songs"]) {
      songsInfo.add(songsInfoPreLoad[num]);
    }

    getLatelyOrders();
    getInfoByOrders();
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

    for (int num in latelyInfo["lately_added"]) {
      if (widget.artistInfo["songs"].contains(num)) {
        latelyAddedSongs.add(num);
      }
    }
    for (int num in latelyInfo["lately_commented"]) {
      if (widget.artistInfo["songs"].contains(num)) {
        latelyCommentedSongs.add(num);
      }
    }

    latelyAddedSongs = List.from(latelyAddedSongs.reversed);

    latelyCommentedSongs = List.from(latelyCommentedSongs.reversed);

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
  }

  void scrollCallback() {
    print(controller.offset);
    if (controller.offset <= 450 && controller.offset >= 350) {
      opacity = (((controller.offset - 350) / 100) * 255).floor();
    } else {
      if (controller.offset >= 450) {
        opacity = 255;
      } else {
        opacity = 0;
      }
    }
    setState(() {});
  }

  void backFunc() {
    if (widget.screenNumber == 1) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionsBuilder:
          // secondaryAnimation: 화면 전화시 사용되는 보조 애니메이션효과
          // child: 화면이 전환되는 동안 표시할 위젯을 의미(즉, 전환 이후 표시될 위젯 정보를 의미)
          (context, animation, secondaryAnimation, child) {
            // Offset에서 x값 1은 오른쪽 끝 y값 1은 아래쪽 끝을 의미한다.
            // 애니메이션이 시작할 포인트 위치를 의미한다.

            var begin = Offset((2 > 1) ? -1 : 1, 0);
            var end = const Offset(0, 0);
            // Curves.ease: 애니메이션이 부드럽게 동작하도록 명령
            var curve = Curves.ease;
            // 애니메이션의 시작과 끝을 담당한다.
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
        ),
      );
    }
    if (widget.screenNumber == 2) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionsBuilder:
          // secondaryAnimation: 화면 전화시 사용되는 보조 애니메이션효과
          // child: 화면이 전환되는 동안 표시할 위젯을 의미(즉, 전환 이후 표시될 위젯 정보를 의미)
          (context, animation, secondaryAnimation, child) {
            // Offset에서 x값 1은 오른쪽 끝 y값 1은 아래쪽 끝을 의미한다.
            // 애니메이션이 시작할 포인트 위치를 의미한다.

            var begin = Offset(-1, 0);
            var end = const Offset(0, 0);
            // Curves.ease: 애니메이션이 부드럽게 동작하도록 명령
            var curve = Curves.ease;
            // 애니메이션의 시작과 끝을 담당한다.
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          pageBuilder:
              (context, animation, secondaryAnimation) => SongScreen(
                songNumber: latestSongNumber,
                targetUserNumber: loginUserNumber,
              ),
        ),
      );
    }
    if (widget.screenNumber == 3) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionsBuilder:
          // secondaryAnimation: 화면 전화시 사용되는 보조 애니메이션효과
          // child: 화면이 전환되는 동안 표시할 위젯을 의미(즉, 전환 이후 표시될 위젯 정보를 의미)
          (context, animation, secondaryAnimation, child) {
            // Offset에서 x값 1은 오른쪽 끝 y값 1은 아래쪽 끝을 의미한다.
            // 애니메이션이 시작할 포인트 위치를 의미한다.

            var begin = Offset((2 > 3) ? -1 : 1, 0);
            var end = const Offset(0, 0);
            // Curves.ease: 애니메이션이 부드럽게 동작하도록 명령
            var curve = Curves.ease;
            // 애니메이션의 시작과 끝을 담당한다.
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          pageBuilder:
              (context, animation, secondaryAnimation) => SearchScreen(),
        ),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    controller.addListener(scrollCallback);
    getSongsInfo();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: backFunc,

          icon: Icon(Icons.arrow_back_ios_new),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          widget.artistInfo["name"],
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color:
                (opacity != 0)
                    ? Colors.black.withAlpha(opacity)
                    : Colors.transparent,
          ),
        ),
        backgroundColor:
            (opacity != 0)
                ? ((opacity != 255)
                    ? Colors.white.withAlpha(opacity)
                    : Colors.white)
                : Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      bottomNavigationBar: myBottomNavigationBar(currentWidgetName: "SONG"),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        controller: controller,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(widget.artistInfo["profile_image"]),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        widget.artistInfo["name"],
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
              orderByText: "최근 댓글 달림",
              songsList: latelyCommentedSongs,
              songsInfo: songsInfoPreLoad,
            ),

            OrderedSongsWidget(
              orderByText: "최다 댓글",
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
    );
  }
}
