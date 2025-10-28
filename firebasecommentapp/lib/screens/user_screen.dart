import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/screens/login_screen.dart';
import 'package:firebasecommentapp/widgets/bottom_navigation_bar.dart';
import 'package:firebasecommentapp/widgets/user_screen_music_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key, required this.userNumber});
  final int userNumber;

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool loaded = false;
  bool userLoaded = false;
  Map<String, dynamic> userInfo = {};
  List<Map<String, dynamic>> songsInfo = [];
  List<int> commentedSongs = [];
  List<int> commentRatings = [];
  List<int> commentLikes = [];
  List<int> commentNumbers = [];
  void getData() async {
    // var userData =
    //     await FirebaseFirestore.instance
    //         .collection('users')
    //         .doc("user${widget.userNumber}")
    //         .get();
    userInfo = Map<String, dynamic>.from(usersInfoPreLoad[widget.userNumber]);
    userLoaded = true;
    setState(() {});

    // var songsData =
    //     await FirebaseFirestore.instance
    //         .collection('songs')
    //         .orderBy("number")
    //         .get();
    songsInfo = List.from(songsInfoPreLoad);

    // var commentsData =
    //     await FirebaseFirestore.instance
    //         .collection('comments')
    //         .orderBy("number")
    //         .get();
    var commentsInfo = List.from(commentsInfoPreLoad);

    for (var comment in commentsInfo) {
      if (comment["user_number"] == widget.userNumber) {
        print("correct");
        if (comment["rating"] != 0) {
          commentRatings.add(comment["rating"]);
          commentLikes.add(comment["likes"]);
          commentNumbers.add(comment["number"]);
        }
      }
    }

    commentRatings = List.from(commentRatings.reversed);
    commentLikes = List.from(commentLikes.reversed);
    commentNumbers = List.from(commentNumbers.reversed);

    commentedSongs = List.from(userInfo["commented_songs"].reversed);

    loaded = true;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return (loaded)
        ? Scaffold(
          bottomNavigationBar: Hero(
            tag: "bar",
            child: myBottomNavigationBar(currentWidgetName: "USER"),
          ),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                Row(
                  children: [
                    SizedBox(width: 20),
                    Container(
                      width: 105,
                      height: 105,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54, width: 5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.headphones,
                          size: 70,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userInfo["NAME"],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "작성한 댓글 ${commentedSongs.length}개",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    if (widget.userNumber == loginUserNumber)
                      IconButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setInt('loginUserNumber', -1);
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
                                      LoginScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.logout, color: Colors.red),
                      ),
                  ],
                ),

                SizedBox(height: 30),

                if (commentedSongs.isNotEmpty)
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        for (int i = 0; i < commentedSongs.length; i++)
                          UserScreenMusicWidget(
                            musicInfo: songsInfo[commentedSongs[i]],
                            musicNumber: commentedSongs[i],
                            rating: commentRatings[i],
                            likes: commentLikes[i],
                            userNumber: widget.userNumber,
                            commentInfo: commentsInfoPreLoad[commentNumbers[i]],
                          ),
                      ],
                    ),
                  ),

                if (commentedSongs.isEmpty)
                  Text(
                    "아직 작성한 댓글이 없어요!",
                    style: TextStyle(color: Colors.black45),
                  ),
              ],
            ),
          ),
        )
        : Scaffold(
          bottomNavigationBar: Hero(
            tag: "bar",
            child: myBottomNavigationBar(currentWidgetName: "USER"),
          ),
          body: Center(
            child:
                (userLoaded)
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 60),
                        Row(
                          children: [
                            SizedBox(width: 20),
                            Container(
                              width: 105,
                              height: 105,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black54,
                                  width: 5,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.headphones,
                                  size: 70,
                                  color: Colors.black38,
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userInfo["NAME"],
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "작성한 댓글 0개",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.userNumber == loginUserNumber)
                              IconButton(
                                onPressed: () async {},
                                icon: Icon(Icons.logout, color: Colors.red),
                              ),
                          ],
                        ),
                      ],
                    )
                    : SizedBox(),
          ),
        );
  }
}
