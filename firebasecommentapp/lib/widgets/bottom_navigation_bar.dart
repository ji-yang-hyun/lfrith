import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/screens/home_screen.dart';
import 'package:firebasecommentapp/screens/login_screen.dart';
import 'package:firebasecommentapp/screens/search_screen.dart';
import 'package:firebasecommentapp/screens/song_screen.dart';
import 'package:firebasecommentapp/screens/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class myBottomNavigationBar extends StatelessWidget {
  const myBottomNavigationBar({super.key, required this.currentWidgetName});
  final String currentWidgetName;

  int getScreenNumber() {
    if (currentWidgetName == "HOME") {
      return 1;
    }
    if (currentWidgetName == "SONG") {
      return 2;
    }
    if (currentWidgetName == "SEARCH") {
      return 3;
    }
    if (currentWidgetName == "USER") {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              if (currentWidgetName == "HOME") {
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

                    var begin = Offset((getScreenNumber() > 1) ? -1 : 1, 0);
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
                      (context, animation, secondaryAnimation) => HomeScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.home,
              color:
                  (currentWidgetName == "HOME") ? Colors.blue : Colors.black54,
            ),
          ),
          IconButton(
            onPressed: () async {
              if (currentWidgetName == "SONG") {
                return;
              }
              if (latestSongNumber == 0) {
                return;
              } else {
                // var songData =
                //     await FirebaseFirestore.instance
                //         .collection('songs')
                //         .doc("song$latestSongNumber")
                //         .get();
                // var songInfo = Map<String, dynamic>.from(
                //   songData.data() as Map,
                // );

                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    transitionsBuilder:
                    // secondaryAnimation: 화면 전화시 사용되는 보조 애니메이션효과
                    // child: 화면이 전환되는 동안 표시할 위젯을 의미(즉, 전환 이후 표시될 위젯 정보를 의미)
                    (context, animation, secondaryAnimation, child) {
                      // Offset에서 x값 1은 오른쪽 끝 y값 1은 아래쪽 끝을 의미한다.
                      // 애니메이션이 시작할 포인트 위치를 의미한다.

                      var begin = Offset((getScreenNumber() > 2) ? -1 : 1, 0);
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
            },
            icon: Icon(
              Icons.album,
              color:
                  (currentWidgetName == "SONG") ? Colors.blue : Colors.black54,
            ),
          ),
          IconButton(
            onPressed: () {
              if (currentWidgetName == "SEARCH") {
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

                    var begin = Offset((getScreenNumber() > 3) ? -1 : 1, 0);
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
                          SearchScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.search,
              color:
                  (currentWidgetName == "SEARCH")
                      ? Colors.blue
                      : Colors.black54,
            ),
          ),
          IconButton(
            onPressed: () {
              if (currentWidgetName == "USER") {
                return;
              }
              if (loginUserNumber == -1) {
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
                return;
              }

              print(Navigator.of(context));

              print(Navigator.of(context));
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  transitionsBuilder:
                  // secondaryAnimation: 화면 전화시 사용되는 보조 애니메이션효과
                  // child: 화면이 전환되는 동안 표시할 위젯을 의미(즉, 전환 이후 표시될 위젯 정보를 의미)
                  (context, animation, secondaryAnimation, child) {
                    // Offset에서 x값 1은 오른쪽 끝 y값 1은 아래쪽 끝을 의미한다.
                    // 애니메이션이 시작할 포인트 위치를 의미한다.

                    var begin = Offset((getScreenNumber() > 4) ? -1 : 1, 0);
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
                          UserScreen(userNumber: loginUserNumber),
                ),
              );
            },
            icon: FaIcon(
              FontAwesomeIcons.circleUser,
              color:
                  (currentWidgetName == "USER") ? Colors.blue : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
