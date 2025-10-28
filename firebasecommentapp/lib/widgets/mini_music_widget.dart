import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/screens/song_screen.dart';
import 'package:flutter/material.dart';

class MiniMusicWidget extends StatelessWidget {
  const MiniMusicWidget({
    super.key,
    required this.musicInfo,
    required this.musicNumber,
    required this.screenNumber,
  });
  final Map<String, dynamic> musicInfo;
  final int musicNumber;
  final int screenNumber;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    if (musicInfo["report_count"] > 10) {
      return SizedBox(height: 0, width: 0);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: GestureDetector(
        onTap: () async {
          if (searchTextFieldFocusNode.hasFocus) {
            searchTextFieldFocusNode.unfocus();
            return;
          }
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

                var begin = Offset((screenNumber > 2) ? -1 : 1, 0);
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
                    targetUserNumber: loginUserNumber,
                  ),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              height: 70,
              width: 70,
              child: Image.network(
                musicInfo["albumcover"],
                fit: BoxFit.fitHeight,
              ),
            ),
            SizedBox(width: 5),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: (screenSize.width < 450) ? 260 : 290,
                  height: 30,
                  child: Text(
                    "${musicInfo["artist"]} - ${musicInfo["title"]}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "${musicInfo["rating"]} ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text("(${musicInfo["comment_numbers"].length.toString()})"),
                    Text(
                      "  views : ${(musicInfo["views"] / 10000).toStringAsFixed(1)}만",
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
