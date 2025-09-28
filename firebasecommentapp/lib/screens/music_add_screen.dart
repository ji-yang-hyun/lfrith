import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/screens/home_screen.dart';
import 'package:firebasecommentapp/screens/song_screen.dart';
import 'package:firebasecommentapp/search_engine.dart';
import 'package:firebasecommentapp/widgets/bottom_navigation_bar.dart';
import 'package:firebasecommentapp/widgets/song_check_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MusicAddScreen extends StatefulWidget {
  const MusicAddScreen({super.key});

  @override
  State<MusicAddScreen> createState() => _MusicAddScreenState();
}

class _MusicAddScreenState extends State<MusicAddScreen> {
  String albumCoverImgUrl = "";
  String title = "";
  String artist = "";
  int views = 0;
  int likes = 0;
  double rating = 0;
  Map<String, dynamic> newSong = {};
  bool showSongState = false;
  String commentText = "";
  String description = "";
  //클립보드가 비었을 때 들어갈 url
  String nullUrl = "https://youtu.be/3R8WylnTONA?si=kHwD7_p6ZKqQEX5e";

  // String nullUrl = "https://youtu.be/PtJsY_PkpSI?si=3GdDniak4PGYeIfj";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void getMusicFunc() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    String? clipboardText = clipboardData?.text ?? nullUrl;
    // print(clipboardText);
    if (clipboardText.contains("youtu.be") == false) {
      print(clipboardText);
      commentText = "$clipboardText 는 유효하지 않은 url입니다.";
      setState(() {});
      return;
    }

    getMusicMetadataFunc(clipboardText);

    // print(clipboardText);
  }

  void getMusicMetadataFunc(String musicUrl) async {
    validImage = true;
    var yt = YoutubeExplode();
    var video = await yt.videos.get(musicUrl);
    albumCoverImgUrl = video.thumbnails.maxResUrl;
    title = video.title;
    artist = video.author;
    views = video.engagement.viewCount;
    likes = video.engagement.likeCount ?? 0;
    List<String> keywords = module1(title, artist);
    List<List<String>> searchTag = await module2(keywords);
    List<String> searchTag0 = searchTag[0];
    List<String> searchTag1 = searchTag[1];
    List<String> searchTag2 = searchTag[2];

    newSong = {
      "albumcover": albumCoverImgUrl,
      "artist": artist,
      "comment_numbers": [],
      "likes": likes,
      "report_count": 0,
      "search_tag0": searchTag0,
      "search_tag1": searchTag1,
      "search_tag2": searchTag2,
      "title": title,
      "views": views,
      "youtube_url": musicUrl,
      "rating": rating,
      "number": 0,
      "keywords": keywords,
    };

    showSongState = true;
    setState(() {});

    print(newSong);
  }

  void addMusicFunc() async {
    if (!validImage) {
      commentText = "이미지가 유효하지 않습니다";
      setState(() {});
      return;
    }

    var songs =
        await FirebaseFirestore.instance
            .collection('songs')
            .orderBy("number")
            .get();
    var songCount = songs.size - 1; // 있는 음악의 개수

    var songsFetch = [
      for (int i = 0; i < songs.size; i++)
        Map<String, dynamic>.from(songs.docs[i].data() as Map),
    ];

    for (int i = 0; i < songsFetch.length; i++) {
      var song = songsFetch[i];
      if (newSong["youtube_url"].toString().split("?")[0] ==
          song["youtube_url"].toString().split("?")[0]) {
        //여기서 i번쨰 음악의 페이지로 이동시켜주면 될 듯 i를 매개변수로 줘서 ㅇㅇ
        //url은 상황따라 바뀌니까 그걸 좀 따로 해야할 것 같은데 그 영상 코드를 쓰는 거...
        //url을 보면 ?를 기준으로 앞쪽은 동일하고 뒷쪽은 왜인지 모르게 달라지는걸 볼 수
        ////있으므로 스플릿을 해서 하는게 어떨까 싶다 ㅇㅇ.
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionsBuilder:
            // secondaryAnimation: 화면 전화시 사용되는 보조 애니메이션효과
            // child: 화면이 전환되는 동안 표시할 위젯을 의미(즉, 전환 이후 표시될 위젯 정보를 의미)
            (context, animation, secondaryAnimation, child) {
              // Offset에서 x값 1은 오른쪽 끝 y값 1은 아래쪽 끝을 의미한다.
              // 애니메이션이 시작할 포인트 위치를 의미한다.

              var begin = Offset(0, -1);
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
                  songNumber: i,
                  targetUserNumber: loginUserNumber,
                ),
          ),
        );
        return;
      }
    }

    newSong["number"] = songCount + 1;

    var addedData =
        await FirebaseFirestore.instance
            .collection('home')
            .doc('home_screen_data')
            .get();

    Map<String, dynamic> addedInfo = Map<String, dynamic>.from(
      addedData.data() as Map,
    );

    addedInfo["lately_added"].removeAt(0);
    addedInfo["lately_added"].add(songCount + 1);

    FirebaseFirestore.instance
        .collection('home')
        .doc('home_screen_data')
        .set(addedInfo);

    FirebaseFirestore.instance
        .collection('songs')
        .doc('song${songCount + 1}')
        .set(newSong);

    await songsInfoPreLoadUpdate();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionsBuilder:
        // secondaryAnimation: 화면 전화시 사용되는 보조 애니메이션효과
        // child: 화면이 전환되는 동안 표시할 위젯을 의미(즉, 전환 이후 표시될 위젯 정보를 의미)
        (context, animation, secondaryAnimation, child) {
          // Offset에서 x값 1은 오른쪽 끝 y값 1은 아래쪽 끝을 의미한다.
          // 애니메이션이 시작할 포인트 위치를 의미한다.

          var begin = Offset(0, -1);
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
              songNumber: songCount + 1,
              targetUserNumber: loginUserNumber,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: myBottomNavigationBar(currentWidgetName: "SEARCH"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showSongState)
              Column(
                children: [
                  SongCheckWidget(
                    title: title,
                    artist: artist,
                    albumCoverImgUrl: albumCoverImgUrl,
                  ),
                  if (!validImage) Text("이미지가 유효하지 않습니다"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          showSongState = false;
                          commentText = "";
                          validImage = true;
                          setState(() {});
                        },
                        icon: Icon(Icons.close, color: Colors.red),
                      ),
                      (validImage)
                          ? IconButton(
                            onPressed: addMusicFunc,
                            icon: Icon(Icons.arrow_forward, color: Colors.blue),
                          )
                          : SizedBox(),
                    ],
                  ),
                ],
              ),
            if (!showSongState)
              TextButton(
                onPressed: getMusicFunc,
                child: Text(
                  "클릭하여 클립보드 url 붙여넣기",
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ),
            if (!showSongState)
              TextButton(
                onPressed: getMusicFunc,
                child: Text(
                  commentText,
                  style: TextStyle(fontSize: 14, color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
