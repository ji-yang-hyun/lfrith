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

  void getLoginInfo() async {
    // await getNurak();
    await songsInfoPreLoadUpdate();
    await commentsInfoPreLoadUpdate();
    // 하나 기다리는 시간이면 다른애들도 다 끝날거다. comment가 제일 많을거니까 ㅇㅇ
    // 아니였음 그래서 다 달아줌 ㅎㅎ...
    await usersInfoPreLoadUpdate();

    final prefs = await SharedPreferences.getInstance();

    loginUserNumberPref = prefs.getInt("loginUserNumber") ?? -1;

    loadingFin = true;

    if (!timerFin) {
      return;
    }

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
          child: SizedBox(
            height: 115,

            child: Image.asset("assets/images/logo.jpg", fit: BoxFit.fitHeight),
          ),
        ),
      ),
    );
  }
}
