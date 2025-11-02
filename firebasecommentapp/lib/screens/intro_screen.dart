import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/screens/admin_screen.dart';
import 'package:firebasecommentapp/screens/home_screen.dart';
import 'package:firebasecommentapp/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool visible = false;
  bool loadingFin = false;
  bool timerFin = false;
  int loginUserNumberPref = 0;
  bool loadInfoFin = false;
  List<dynamic> images = [];

  void getLoginInfo() async {
    // await getNurak();
    await songsInfoPreLoadUpdate();
    await commentsInfoPreLoadUpdate();
    // 하나 기다리는 시간이면 다른애들도 다 끝날거다. comment가 제일 많을거니까 ㅇㅇ
    // 아니였음 그래서 다 달아줌 ㅎㅎ...
    await usersInfoPreLoadUpdate();
    await artistsInfoPreLoadUpdate();
    //그리고 여기서 가장 중요한 건 사진들을 전부 캐싱해야 부드럽게 움직이기 때문에 여기서 사진들을 다
    // 한 번씩 불러오는것이 좋다.
    images =
        [for (var songInfo in songsInfoPreLoad) songInfo["albumcover"]] +
        [
          for (var artistInfo in artistsInfoPreLoad)
            artistInfo["profile_image"],
        ];

    images.removeAt(songsInfoPreLoad.length);
    images.removeAt(0);

    loadInfoFin = true;
    setState(() {});

    final prefs = await SharedPreferences.getInstance();

    loginUserNumberPref = prefs.getInt("loginUserNumber") ?? -1;

    loadingFin = true;

    if (!timerFin) {
      return;
    }

    if (loginUserNumberPref == -2) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => LoginScreen(),
        ),
      );
    } else {
      if (loginUserNumberPref == 0) {
        loginUserNumber = loginUserNumberPref;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => AdminScreen(),
          ),
        );
      } else {
        loginUserNumber = loginUserNumberPref;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => HomeScreen(),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getLoginInfo();
    Future.delayed(const Duration(milliseconds: 500), () {
      visible = !visible;
      setState(() {});
    });
    Future.delayed(const Duration(seconds: 2), () {
      timerFin = true;
      if (loadingFin) {
        if (loginUserNumberPref == -1) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) => LoginScreen(),
            ),
          );
        } else {
          if (loginUserNumberPref == 0) {
            loginUserNumber = loginUserNumberPref;
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) => AdminScreen(),
              ),
            );
          } else {
            loginUserNumber = loginUserNumberPref;
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) => HomeScreen(),
              ),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: Duration(milliseconds: 700),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 115,

                child: Image.asset(
                  "assets/images/logo.jpg",
                  fit: BoxFit.fitHeight,
                ),
              ),
              if (loadInfoFin)
                Column(
                  children: [
                    for (var url in images)
                      Image.network(url, height: 0, width: 0),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
