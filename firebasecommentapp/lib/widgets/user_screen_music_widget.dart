import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/screens/song_screen.dart';
import 'package:flutter/material.dart';

class UserScreenMusicWidget extends StatelessWidget {
  const UserScreenMusicWidget({
    super.key,
    required this.musicInfo,
    required this.musicNumber,
    required this.rating,
    required this.likes,
    required this.userNumber,
  });
  final Map<String, dynamic> musicInfo;
  final int musicNumber;
  final int rating;
  final int likes;
  final int userNumber;

  @override
  Widget build(BuildContext context) {
    if (musicInfo["report_count"] > 10) {
      return SizedBox(height: 0, width: 0);
    }
    return GestureDetector(
      onTap: () async {
        // var songData =
        //     await FirebaseFirestore.instance
        //         .collection('songs')
        //         .doc("song$musicNumber")
        //         .get();
        // var songInfo = Map<String, dynamic>.from(songData.data() as Map);

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
                  songNumber: musicNumber,
                  targetUserNumber: userNumber,
                ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SizedBox(
          height: 161,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    height: 140,
                    width: 140,
                    child: Image.network(
                      musicInfo["albumcover"],
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 250,
                            child: Text(
                              musicInfo["artist"],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: 250,
                              child: Text(
                                musicInfo["title"],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star),
                              Text(
                                rating.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 20),
                              Icon(Icons.favorite),
                              Text(
                                " ${likes.toString()}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
