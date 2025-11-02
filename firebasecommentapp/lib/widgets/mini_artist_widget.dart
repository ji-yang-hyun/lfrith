import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/screens/artist_screen.dart';
import 'package:firebasecommentapp/screens/song_screen.dart';
import 'package:flutter/material.dart';

class MiniArtistWidget extends StatelessWidget {
  const MiniArtistWidget({
    super.key,
    required this.artistInfo,
    required this.artistNumber,
    required this.screenNumber,
  });
  final Map<String, dynamic> artistInfo;
  final int artistNumber;
  final int screenNumber;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

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
                  (context, animation, secondaryAnimation) => ArtistScreen(
                    artistInfo: artistInfo,
                    screenNumber: screenNumber,
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
                artistInfo["profile_image"],
                fit: BoxFit.fitHeight,
              ),
            ),
            SizedBox(width: 30),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: (screenSize.width < 450) ? 235 : 265,
                  height: 30,
                  child: Text(
                    "${artistInfo["name"]}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
