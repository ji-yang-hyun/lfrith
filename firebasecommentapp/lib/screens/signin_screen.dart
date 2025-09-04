import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  String commentText = "";

  void done() {
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
        pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
      ),
    );
  }

  void signInFunction() async {
    if (idController.text.length *
            pwController.text.length *
            nameController.text.length ==
        0) {
      return;
    }
    Map<String, dynamic> userData = {
      'ID': idController.text,
      'PW': pwController.text,
      'NAME': nameController.text,
      "number": 0,
      "commented_songs": [],
      "liked_comment": [],
    };

    var userCount = usersInfoPreLoad.length - 1;
    bool validNewUser = true;
    bool validNewName = true;
    bool validNewID = true;

    for (int i = 0; i < usersInfoPreLoad.length; i++) {
      var user = usersInfoPreLoad[i];
      // print(user["ID"]);
      if (user["ID"] == userData["ID"]) {
        validNewID = false;
        validNewUser = false;
      }
      if (user["NAME"] == userData["NAME"]) {
        validNewName = false;
        validNewUser = false;
      }
    }

    if (validNewUser) {
      userData["number"] = userCount + 1;
      await FirebaseFirestore.instance
          .collection('users')
          .doc('user${userCount + 1}')
          .set(userData);

      await usersInfoPreLoadUpdate(); // 여기서 users에 새로운 유저 추가하고 다시 preLoad
      done();
    } else {
      if (!validNewID) {
        commentText = "사용된 ID입니다";
      }
      if (!validNewName) {
        commentText = "사용된 이름입니다";
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
                height: 430,
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
                      SizedBox(height: 17),
                      Text("User name", style: TextStyle(fontSize: 22)),
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
                          controller: nameController,
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
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => LoginScreen(),
                                ),
                              );
                            },
                            child: Text("login now"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 110),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                height: 60,
                width: 105,
                child: Center(
                  child: IconButton(
                    onPressed: signInFunction,
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
