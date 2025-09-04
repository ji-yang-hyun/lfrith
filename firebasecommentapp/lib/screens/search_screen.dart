import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/screens/home_screen.dart';
import 'package:firebasecommentapp/screens/music_add_screen.dart';
import 'package:firebasecommentapp/screens/song_screen.dart';
import 'package:firebasecommentapp/widgets/bottom_navigation_bar.dart';
import 'package:firebasecommentapp/widgets/mini_music_widget.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> songsInfo = [];
  TextEditingController strController = TextEditingController();
  List<int> songsToShow = [];

  void getSongsInfo() async {
    songsInfo = songsInfoPreLoad; // homeScreen에서 load한거 그냥 갖다 쓰자,
    // 어차피 home에 들어감으로서 주기적으로 다시 받아와질거고 유저가 이 갭동안 추가할만큼 많이 않을것.
    if (songsInfoPreLoad.isEmpty) {
      // 만약에 비어있다면 다시 로딩.
      var songsData =
          await FirebaseFirestore.instance
              .collection('songs')
              .orderBy("number")
              .get();
      songsInfo = [
        for (int i = 0; i < songsData.size; i++)
          Map<String, dynamic>.from(songsData.docs[i].data() as Map),
      ];
    } //역대 모든 노래들 불러오기.
    searchFunc();

    setState(() {});
  }

  void searchFunc() {
    songsToShow = []; // 보여줄 노래 리스트 초기화
    String? keyword = strController.text
        .toLowerCase()
        .replaceAll(" ", "")
        .replaceAll("\n", "");

    for (int i = 1; i < songsInfo.length; i++) {
      if (keyword.isEmpty) {
        songsToShow.add(i);
      } else {
        if (songsInfo[i]["search_tag"].contains(keyword)) {
          songsToShow.add(i);
        }
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    getSongsInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: Hero(
          tag: "bar",
          child: myBottomNavigationBar(currentWidgetName: "SEARCH"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: searchTextFieldFocusNode,
                      onSubmitted: (value) => searchFunc(),
                      cursorColor: Colors.black,
                      style: TextStyle(fontSize: 17),
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black54,
                            width: 2,
                          ),
                        ),
                      ),
                      controller: strController,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      searchFunc();
                    },
                    icon: Icon(Icons.search),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 35,
              child: TextButton(
                onPressed: () {
                  if (searchTextFieldFocusNode.hasFocus) {
                    searchTextFieldFocusNode.unfocus();
                    return;
                  }
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      transitionsBuilder:
                      // secondaryAnimation: 화면 전화시 사용되는 보조 애니메이션효과
                      // child: 화면이 전환되는 동안 표시할 위젯을 의미(즉, 전환 이후 표시될 위젯 정보를 의미)
                      (context, animation, secondaryAnimation, child) {
                        // Offset에서 x값 1은 오른쪽 끝 y값 1은 아래쪽 끝을 의미한다.
                        // 애니메이션이 시작할 포인트 위치를 의미한다.

                        var begin = Offset(0, 1);
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
                          (context, animation, secondaryAnimation) =>
                              MusicAddScreen(),
                    ),
                  );
                },
                child: Text("찾으시는 음악이 없나요?   url로 검색하기"),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (int i in songsToShow)
                      MiniMusicWidget(
                        musicInfo: songsInfo[i],
                        musicNumber: i,
                        screenNumber: 3,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
