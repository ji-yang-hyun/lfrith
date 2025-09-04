import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/screens/song_screen.dart';
import 'package:firebasecommentapp/screens/user_screen.dart';
import 'package:firebasecommentapp/widgets/reply_widget.dart';
import 'package:flutter/material.dart';

class CommentWidget extends StatefulWidget {
  const CommentWidget({
    super.key,
    required this.commentNumber,
    required this.showCommentTextfieldFunc,
    required this.songNumber,
    // required this.parentSetStateFunc,
    required this.addreplyFuncParent,
  });
  final int commentNumber;
  final Function showCommentTextfieldFunc;
  final int songNumber;
  // final Function parentSetStateFunc;
  final Function addreplyFuncParent;

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  int likes = 0;
  int rating = 0;
  List<dynamic> replyNumbers = [];
  int reportCount = 0;
  String commentText = "";
  int userNumber = 0;
  String userName = "";
  List<List<dynamic>> replys = []; //[[user, text, likes, reportCount]]
  TextEditingController replyController = TextEditingController();
  Map<String, dynamic> commentInfo = {};
  bool isLiked = false;
  bool showFullText = false;
  bool commentInfoLoad = false;
  bool userInfoLoad = false;
  int combuildCount = 0;

  void getCommentInfo() async {
    commentInfoLoad = false;
    setState(() {});

    var commentData =
        await FirebaseFirestore.instance
            .collection('comments')
            .doc('comment${widget.commentNumber}')
            .get();
    commentInfo = Map<String, dynamic>.from(commentData.data() as Map);

    likes = commentInfo["likes"];
    rating = commentInfo["rating"];
    replyNumbers = commentInfo["replys"];
    reportCount = commentInfo["report_count"];
    commentText = commentInfo["text"];
    userNumber = commentInfo["user_number"];

    var userData =
        await FirebaseFirestore.instance
            .collection('users')
            .doc('user$userNumber')
            .get();

    Map<String, dynamic> userInfo = Map<String, dynamic>.from(
      userData.data() as Map,
    );

    userName = userInfo["NAME"];
    print("build");
    commentInfoLoad = true;

    if (mounted) {
      setState(() {});
    }
  }

  void getUserInfo() async {
    var userData =
        await FirebaseFirestore.instance
            .collection('users')
            .doc('user$loginUserNumber')
            .get();

    Map<String, dynamic> userInfo = Map<String, dynamic>.from(
      userData.data() as Map,
    );

    if (userInfo["liked_comment"].contains(widget.commentNumber)) {
      isLiked = true;
    } else {
      isLiked = false;
    }

    userInfoLoad = true;
    setState(() {});
  }

  void likedFunc() async {
    //다른 사용자가 변경한 변경점이 있을 수 있으므로 한 번 업데이트를 해주고 시작한다.

    if (isLiked == false) {
      getCommentInfo();
      commentInfo["likes"] += 1;
      FirebaseFirestore.instance
          .collection('comments')
          .doc('comment${widget.commentNumber}')
          .set(commentInfo);
      getCommentInfo();

      //댓글에 이미 좋아요 표시했다고 저장한다.
      var userData =
          await FirebaseFirestore.instance
              .collection('users')
              .doc('user$loginUserNumber')
              .get();

      Map<String, dynamic> userInfo = Map<String, dynamic>.from(
        userData.data() as Map,
      );

      userInfo["liked_comment"].add(widget.commentNumber);

      FirebaseFirestore.instance
          .collection('users')
          .doc('user$loginUserNumber')
          .set(userInfo);

      isLiked = true;
    } else {
      getCommentInfo();
      commentInfo["likes"] -= 1;
      FirebaseFirestore.instance
          .collection('comments')
          .doc('comment${widget.commentNumber}')
          .set(commentInfo);
      getCommentInfo();

      //댓글에 이미 좋아요 표시했다고 저장한다.
      var userData =
          await FirebaseFirestore.instance
              .collection('users')
              .doc('user$loginUserNumber')
              .get();

      Map<String, dynamic> userInfo = Map<String, dynamic>.from(
        userData.data() as Map,
      );

      userInfo["liked_comment"].remove(widget.commentNumber);

      FirebaseFirestore.instance
          .collection('users')
          .doc('user$loginUserNumber')
          .set(userInfo);

      isLiked = false;
    }

    setState(() {});
  }

  void reportedFunc() {
    commentInfo["report_count"] += 1;
    FirebaseFirestore.instance
        .collection('comments')
        .doc('comment${widget.commentNumber}')
        .set(commentInfo);
  }

  @override
  void initState() {
    // TODO: implement initState
    getCommentInfo();
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    combuildCount += 1;
    print("build comment $combuildCount");
    // getCommentInfo();
    //setstate는 기본적으로 child위젯이 있던 없던 build 메소드만 다시 실행시켜준다
    //initState는 위젯이 그려질 떄 한 번. 즉 스크린 로드 때 위젯이 처음 생길 때 한 번만
    //실행된다. 그래서 새로운 코멘트를 추가할 떄는 아예없던 위젯이 생기는거니 문제없이
    //동작했던 것이다.
    //그렇기 때문에 build메소드에 gecommentInfo. 즉 코멘트의 정보를 업데이트 하는
    //함수를 넣음으로서 이미 그려진 comment위젯에서 새로운 코멘트의 정보를 받는 것 이다.
    //이로서 알 수 있는것은 부모 위젯에서 자식 위젯으로 stateful위젯을 포함한 경우에
    //setstate를 하면 위젯들의 매개변수는 다시 잘 전달되고 빌드 메소드는 잘 실행되지만
    //트리에는 이미 자식위젯이 있는 상태였기 때문에 자식의 initState는 다시 하지
    //않는다는 것을 알 수 있다.

    if (commentInfo["number"] != null) {
      if (commentInfo["number"] != widget.commentNumber) {
        // print(commentInfo["number"]);
        // print(widget.commentNumber);
        getCommentInfo();
      }
    }

    return (!(commentText.isEmpty))
        ? Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [Icon(Icons.star, size: 15), Text("$rating")],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    UserScreen(userNumber: userNumber),
                          ),
                        );
                      },
                      child: Text(
                        userName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showFullText = !showFullText;
                        setState(() {});
                      },
                      child:
                          (!showFullText)
                              ? SizedBox(
                                width: 250,
                                child: Text(
                                  commentText,
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 15,
                                  ),
                                ),
                              )
                              : SizedBox(
                                width: 250,
                                child: Text(
                                  commentText,
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                    ),
                    SizedBox(
                      height: 32,
                      child: TextButton(
                        onPressed: () async {
                          commentNumberToShow = widget.commentNumber;
                          replyTextFieldAutoFocus = true;
                          widget.showCommentTextfieldFunc();
                          setState(() {});
                        },
                        child: Text(
                          "add reply",
                          style: TextStyle(color: Colors.black45, fontSize: 12),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 32,
                      child: TextButton(
                        onPressed: () async {
                          commentNumberToShow = widget.commentNumber;
                          replyTextFieldAutoFocus = false;
                          widget.showCommentTextfieldFunc();

                          setState(() {});
                        },
                        child: Text(
                          "--- show ${replyNumbers.length} reply ---",
                          style: TextStyle(color: Colors.black45, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(height: 1),
                    Row(
                      children: [
                        IconButton(
                          onPressed: likedFunc,
                          icon: Icon(
                            Icons.favorite,
                            color: (isLiked) ? Colors.red[200] : Colors.black54,
                            size: 20,
                          ),
                        ),
                        Text(likes.toString()),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 10),
          ],
        )
        : Text("");
  }
}
