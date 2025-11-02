import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/screens/admin_screen.dart';
import 'package:firebasecommentapp/screens/home_screen.dart';
import 'package:firebasecommentapp/screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  String commentText = "";

  void guestUse() {
    loginUserNumber = -1;
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
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
      ),
    );
  }

  void done() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('loginUserNumber', loginUserNumber);

    if (loginUserNumber == 0) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => AdminScreen(),
        ),
      );
    } else {
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
          pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
        ),
      );
    }
  }

  void loginFunction() async {
    String userIdInput = idController.text;
    String userPwInput = pwController.text;
    bool validUser = false;
    bool validID = false;
    bool validPW = false;

    // 전 스크린에서 usersInfoPreLoad를 받아왔으니 사용.
    for (int i = 0; i < usersInfoPreLoad.length; i++) {
      var user = usersInfoPreLoad[i];
      // print(user["ID"]);
      if (user["ID"] == userIdInput) {
        validID = true;
        if (user["PW"] == userPwInput) {
          validPW = true;
          validUser = true;
          loginUserNumber = i;
        }
      }
    }

    if (validUser) {
      commentText = "";
      setState(() {});
      done();
    } else {
      if (validPW) {
        commentText = "비밀번호를 다시 확인해 주세요";
      } else {
        commentText = "ID를 다시 확인해 주세요";
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusScope.of(
                context,
              ).unfocus(), // textfield아닌 부분 터치하면 unfocus하는 부분
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 160),
              Container(
                width: 350,
                height: 370,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ID", style: TextStyle(fontSize: 22)),
                      Expanded(
                        child: TextField(
                          cursorColor: Colors.black,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                            ),
                          ),
                          controller: idController,
                        ),
                      ),
                      SizedBox(height: 17),
                      Text("Password", style: TextStyle(fontSize: 22)),
                      Expanded(
                        child: TextField(
                          cursorColor: Colors.black,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                            ),
                          ),
                          controller: pwController,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        child: Text(
                          commentText,
                          style: TextStyle(fontSize: 15, color: Colors.red),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                PageRouteBuilder(
                                  transitionsBuilder:
                                  // secondaryAnimation: 화면 전화시 사용되는 보조 애니메이션효과
                                  // child: 화면이 전환되는 동안 표시할 위젯을 의미(즉, 전환 이후 표시될 위젯 정보를 의미)
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
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
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => SignInScreen(),
                                ),
                              );
                            },
                            child: Text("sign in now"),
                          ),
                          TextButton(
                            onPressed: guestUse,
                            child: Text(
                              "guest use",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 170),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                height: 60,
                width: 105,
                child: Center(
                  child: IconButton(
                    onPressed: loginFunction,
                    icon: Icon(
                      Icons.arrow_forward_sharp,
                      size: 30,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
