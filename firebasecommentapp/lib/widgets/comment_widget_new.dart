import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/screens/song_screen.dart';
import 'package:firebasecommentapp/screens/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommentWidgetNew extends StatelessWidget {
  const CommentWidgetNew({
    super.key,
    required this.commentInfo,
    required this.userInfo,
    required this.parentSetStateFunc,
    required this.myUserInfo,
  });
  final Map<String, dynamic> commentInfo;
  final Map<String, dynamic> userInfo;
  final Map<String, dynamic> myUserInfo;
  final Function parentSetStateFunc;

  void deleteFunc() {
    HapticFeedback.mediumImpact();
    deleteFuncFrontEnd();
    deleteFuncBackEnd();
  }

  void deleteFuncFrontEnd() {
    commentsInfoPreLoad[commentInfo["number"]]["report_count"] = 15;
    parentSetStateFunc();
  }

  void deleteFuncBackEnd() async {
    //어차피 songScreen에서는 newlikedcomments만 보기 떄문에 여기서 바꿔도 된다.
    var commentDataDB =
        await FirebaseFirestore.instance
            .collection('comments')
            .doc("comment${commentInfo["number"]}")
            .get();

    Map<String, dynamic> commentInfoDB = Map<String, dynamic>.from(
      commentDataDB.data() as Map,
    );

    commentInfoDB["report_count"] = 15;

    await FirebaseFirestore.instance
        .collection('comments')
        .doc("comment${commentInfo["number"]}")
        .set(commentInfoDB);

    print("delete done");
  }

  void likeFunc() {}

  void likeFuncFrontEnd() {
    //하트 누르는 건 여러번 누를때의 편한 처리를 위해
    // songScreen의 exitFunc에서(아마도) DB에 반영한다(암튼 나중에 반영함)
    if (usersInfoPreLoad[loginUserNumber]["liked_comment"].contains(
      commentInfo["number"],
    )) {
      HapticFeedback.lightImpact();
      // 이미 하트 눌려져있던 경우
      usersInfoPreLoad[loginUserNumber]["liked_comment"].remove(
        commentInfo["number"],
      );
      commentsInfoPreLoad[commentInfo["number"]]["likes"] -= 1;
      newUnLikedComments.add(commentInfo["number"]);
    } else {
      HapticFeedback.lightImpact();
      usersInfoPreLoad[loginUserNumber]["liked_comment"].add(
        commentInfo["number"],
      );
      commentsInfoPreLoad[commentInfo["number"]]["likes"] += 1;
      newLikedComments.add(commentInfo["number"]);
    }

    parentSetStateFunc();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    bool isChanged = false;
    if (commentInfo["report_count"] > 10) {
      return SizedBox(height: 0, width: 0);
    }
    return GestureDetector(
      onLongPress: () {
        if (userInfo["number"] == myUserInfo["number"]) {
          HapticFeedback.mediumImpact();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                // clipBehavior: Clip.antiAlias,
                content: SizedBox(
                  height: 95,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      Text("댓글을 삭제할까요?", style: TextStyle(fontSize: 17)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.black45,
                              size: 25,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              deleteFunc();
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.delete_outline_outlined,
                              color: Colors.red,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, size: 15),
                      Text(commentInfo["rating"].toString()),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
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
                                  UserScreen(
                                    userNumber: commentInfo["user_number"],
                                  ),
                        ),
                      );
                    },
                    child: Text(
                      userInfo["NAME"],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  (showFullTextCommentNumber != commentInfo["number"])
                      ? SizedBox(
                        width: 250,
                        child: Text(
                          maxLines: 2,
                          commentInfo["text"],
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,

                            fontSize: 15,
                          ),
                        ),
                      )
                      : SizedBox(
                        width: 250,
                        child: Text(
                          commentInfo["text"],
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                  SizedBox(
                    height: 32,
                    child: TextButton(
                      onPressed: () {
                        if (showFullTextCommentNumber !=
                            commentInfo["number"]) {
                          showFullTextCommentNumber = commentInfo["number"];
                        } else {
                          showFullTextCommentNumber = -1;
                        }
                        print(showFullTextCommentNumber);
                        parentSetStateFunc();
                      },
                      child: Text(
                        "자세히 보기",
                        style: TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ),
                  ),

                  // 원래 대댓글 기능 위치
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () async {
                          likeFuncFrontEnd();
                        },
                        icon: Icon(
                          Icons.favorite,
                          color:
                              (usersInfoPreLoad[loginUserNumber]["liked_comment"]
                                      .contains(commentInfo["number"]))
                                  ? Colors.red[200]
                                  : Colors.black54,
                          size: 20,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                        child: Text(commentInfo["likes"].toString()),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 10),
        ],
      ),
    );
  }
}




//대댓글 기능 백업
// SizedBox(
                //   height: 32,
                //   child: TextButton(
                //     onPressed: () async {
                //       commentNumberToShow = commentInfo["number"];
                //       replyTextFieldAutoFocus = true;
                //       showCommentTextfieldFunc();
                //     },
                //     child: Text(
                //       "add reply",
                //       style: TextStyle(color: Colors.black45, fontSize: 12),
                //     ),
                //   ),
                // ),

                // SizedBox(
                //   height: 32,
                //   child: TextButton(
                //     onPressed: () async {
                //       commentNumberToShow = commentInfo["number"];
                //       replyTextFieldAutoFocus = false;
                //       showCommentTextfieldFunc();
                //     },
                //     child: Text(
                //       "--- show ${commentInfo["replys"].length} reply ---",
                //       style: TextStyle(color: Colors.black45, fontSize: 12),
                //     ),
                //   ),
                // ),






                //좋아요기능 백업

// onPressed: () async {
//                         if (isChanged) {
//                           return;
//                         }
//                         isChanged = true;
//                         if (isLiked == false) {
//                           var commentInfoNew = commentInfo;
//                           commentInfoNew["likes"] += 1;
//                           await FirebaseFirestore.instance
//                               .collection('comments')
//                               .doc('comment${commentInfo["number"]}')
//                               .set(commentInfoNew);

//                           var myUserInfoNew = myUserInfo;

//                           myUserInfoNew["liked_comment"].add(
//                             commentInfo["number"],
//                           );

//                           await FirebaseFirestore.instance
//                               .collection('users')
//                               .doc('user$loginUserNumber')
//                               .set(myUserInfoNew);
//                         } else {
//                           var commentInfoNew = commentInfo;
//                           commentInfoNew["likes"] -= 1;
//                           await FirebaseFirestore.instance
//                               .collection('comments')
//                               .doc('comment${commentInfo["number"]}')
//                               .set(commentInfoNew);

//                           var myUserInfoNew = myUserInfo;

//                           myUserInfoNew["liked_comment"].remove(
//                             commentInfo["number"],
//                           );

//                           await FirebaseFirestore.instance
//                               .collection('users')
//                               .doc('user$loginUserNumber')
//                               .set(myUserInfoNew);
//                         }
//                         print(commentInfo);
//                         parentSetStateFunc();
//                       },





//최단기 퇴물

// void likeFuncBackEnd() async {
//     // while (likeRequestCount != 0) {
//     //   print("a");
//     // }
//     likeRequestCount += 1;
//     print("start");
//     var commentDataDB =
//         await FirebaseFirestore.instance
//             .collection('comments')
//             .doc("comment${commentInfo["number"]}")
//             .get();
//     var commentInfoNew = Map<String, dynamic>.from(commentDataDB.data() as Map);

//     var myUsertDataDB =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc("user$loginUserNumber")
//             .get();
//     var myUserInfoNew = Map<String, dynamic>.from(myUsertDataDB.data() as Map);

//     if (!usersInfoPreLoad[loginUserNumber]["liked_comment"].contains(
//       commentInfo["number"],
//     )) {
//       commentInfoNew["likes"] += 1;
//       FirebaseFirestore.instance
//           .collection('comments')
//           .doc('comment${commentInfo["number"]}')
//           .set(commentInfoNew);

//       myUserInfoNew["liked_comment"].add(commentInfo["number"]);

//       FirebaseFirestore.instance
//           .collection('users')
//           .doc('user$loginUserNumber')
//           .set(myUserInfoNew);
//     } else {
//       commentInfoNew["likes"] -= 1;
//       await FirebaseFirestore.instance
//           .collection('comments')
//           .doc('comment${commentInfo["number"]}')
//           .set(commentInfoNew);

//       myUserInfoNew["liked_comment"].remove(commentInfo["number"]);

//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc('user$loginUserNumber')
//           .set(myUserInfoNew);
//     }
//     likeRequestCount -= 1;
//     print("end");
//   }