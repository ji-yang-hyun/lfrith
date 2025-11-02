import 'package:firebasecommentapp/screens/ordered_artists_screen.dart';
import 'package:firebasecommentapp/screens/ordered_songs_screen.dart';
import 'package:firebasecommentapp/widgets/big_artist_widget.dart';
import 'package:firebasecommentapp/widgets/big_music_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class OrderedArtistsWidget extends StatelessWidget {
  const OrderedArtistsWidget({
    super.key,
    required this.orderByText,
    required this.artistsList,
    required this.artistsInfo,
  });
  final List<dynamic> artistsList;
  final String orderByText;
  final List<Map<String, dynamic>> artistsInfo;

  @override
  Widget build(BuildContext context) {
    if (artistsList.isEmpty) {
      return SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 240,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  orderByText,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 27),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      // 돌아오는거 간단하게 하기 위해 여기서만!
                      PageRouteBuilder(
                        transitionsBuilder:
                        // secondaryAnimation: 화면 전화시 사용되는 보조 애니메이션효과
                        // child: 화면이 전환되는 동안 표시할 위젯을 의미(즉, 전환 이후 표시될 위젯 정보를 의미)
                        (context, animation, secondaryAnimation, child) {
                          // Offset에서 x값 1은 오른쪽 끝 y값 1은 아래쪽 끝을 의미한다.
                          // 애니메이션이 시작할 포인트 위치를 의미한다.

                          var begin = Offset(1, 0);
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
                                OrderedArtistsScreen(
                                  orderByText: orderByText,
                                  artistsList: artistsList,
                                  artistsInfo: artistsInfo,
                                ),
                      ),
                    );
                  },
                  icon: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i
                      in (artistsList.length >= 5)
                          ? artistsList.sublist(0, 5)
                          : artistsList)
                    BigArtistWidget(
                      artistInfo: artistsInfo[i],
                      artistNumber: i,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
