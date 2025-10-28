import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/screens/song_screen.dart';
import 'package:firebasecommentapp/widgets/reply_widget_new.dart';
import 'package:flutter/material.dart';

class FullCommentWidget extends StatefulWidget {
  const FullCommentWidget({
    super.key,
    required this.commentNumber,

    required this.songNumber,
    required this.songComments,
    // required this.parentSetStateFunc,
    required this.backToListViewFunc,
  });
  final int commentNumber;

  final int songNumber;
  final List<dynamic> songComments;
  // final Function parentSetStateFunc;
  final Function backToListViewFunc;

  @override
  State<FullCommentWidget> createState() => _FullCommentWidgetState();
}

class _FullCommentWidgetState extends State<FullCommentWidget> {
  int likes = 0;
  int rating = 0;
  List<dynamic> replyNumbers = [];
  int reportCount = 0;
  String commentText = "";
  int userNumber = 0;
  String userName = "";
  List<List<dynamic>> replys = []; //[[user, text, likes, reportCount]]
  TextEditingController replyController = TextEditingController();
  late Map<String, dynamic> commentInfo;
  bool isLiked = false;
  bool showFullText = false;
  bool isLoadComment = false;
  bool isLoadUser = false;
  List<Map<String, dynamic>> commentFetch = [];
  List<Map<String, dynamic>> userFetch = [];

  void childBackToListViewFunc() {
    widget.backToListViewFunc();
  }

  void getCommentInfo() async {
    var comments =
        await FirebaseFirestore.instance
            .collection('comments')
            .orderBy("number")
            .get();
    commentFetch = [
      for (int i = 0; i < comments.size; i++)
        Map<String, dynamic>.from(comments.docs[i].data() as Map),
    ]; //역대 모든 댓글들 불러오기.
    var users =
        await FirebaseFirestore.instance
            .collection('users')
            .orderBy("number")
            .get();
    userFetch = [
      for (int i = 0; i < users.size; i++)
        Map<String, dynamic>.from(users.docs[i].data() as Map),
    ]; //역대 모든 유저들 불러오기.

    commentInfo = commentFetch[widget.commentNumber];

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
    isLoadComment = true;
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

    isLoadUser = true;
    if (mounted) {
      setState(() {});
    }
  }

  void addReplyFunc() async {
    FocusScope.of(context).unfocus();

    if (replyController.text.isEmpty) {
      replyController.text = "";
      // widget.addreplyFuncParent();
      setState(() {});
      return;
    }

    Map<String, dynamic> replyData = {
      "likes": 0,
      "rating": 0,
      "replys": [],
      "report_count": 0,
      "text": replyController.text,
      "user_number": loginUserNumber,
      "number": 0,
    };

    replyController.text = "";
    setState(() {});

    var comments =
        await FirebaseFirestore.instance
            .collection('comments')
            .orderBy("number")
            .get();
    var commentCount = comments.size - 1; //지금까지 있던 모든 노래의 댓글 수

    commentInfo["replys"].add(commentCount + 1);

    replyData["number"] = commentCount + 1;
    await FirebaseFirestore.instance
        .collection('comments')
        .doc('comment${commentCount + 1}')
        .set(replyData);

    await FirebaseFirestore.instance
        .collection('comments')
        .doc('comment${widget.commentNumber}')
        .set(commentInfo);

    getCommentInfo();
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

  /*
  // void likedFunc_old() async {
  //   commentInfo["likes"] += 1;
  //   FirebaseFirestore.instance
  //       .collection('comments')
  //       .doc('comment${widget.commentNumber}')
  //       .set(commentInfo);

  //   var comments =
  //       await FirebaseFirestore.instance
  //           .collection('comments')
  //           .orderBy("number")
  //           .get();
  //   var commentFetch = [
  //     for (int i = 0; i < comments.size; i++)
  //       Map<String, dynamic>.from(comments.docs[i].data() as Map),
  //   ];

  //   List<int> updatedSongComments = [];
  //   for (int i = 0; i < widget.songComments.length; i++) {
  //     int commentN = widget.songComments[i];

  //     if (commentFetch[commentN]["likes"] <= commentInfo["likes"] &&
  //         !updatedSongComments.contains(widget.commentNumber)) {
  //       updatedSongComments.add(widget.commentNumber);
  //     }
  //     if (commentN != widget.commentNumber) {
  //       updatedSongComments.add(commentN);
  //     }
  //   }

  //   //끝까지 없을 때 그냥 맨 뒤에 추가해주기.
  //   if (!updatedSongComments.contains(widget.commentNumber)) {
  //     updatedSongComments.add(widget.commentNumber);
  //   }

  //   var songData =
  //       await FirebaseFirestore.instance
  //           .collection('songs')
  //           .doc('song${widget.songNumber}')
  //           .get();
  //   Map<String, dynamic> songInfo = Map<String, dynamic>.from(
  //     songData.data() as Map,
  //   );

  //   songInfo["comment_numbers"] = updatedSongComments;

  //   FirebaseFirestore.instance
  //       .collection('songs')
  //       .doc('song${widget.songNumber}')
  //       .set(songInfo);

  //   widget.parentSetStateFunc(updatedSongComments);
  // }
*/

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
    var screenSize = MediaQuery.of(context).size;
    return Expanded(
      child: Column(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "${widget.songComments.length}Comments",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: childBackToListViewFunc,
                    icon: Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
              if (isLoadComment && isLoadUser)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28 + 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 40),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, size: 15),
                              Text("$rating"),
                            ],
                          ),
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showFullText = !showFullText;
                              setState(() {});
                            },
                            child: SizedBox(
                              width: 250,
                              child: Text(
                                commentText,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(children: [SizedBox(height: 1)]),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 15),
          Expanded(
            child:
                (isLoadComment && isLoadUser)
                    ? ListView(
                      padding: EdgeInsets.zero,

                      cacheExtent: 100000 + 0.0, //픽셀단위
                      children: [
                        for (var replyNumber in replyNumbers)
                          ReplyWidgetNew(
                            replyInfo: commentFetch[replyNumber],
                            replyUserName:
                                userFetch[commentFetch[replyNumber]["user_number"]]["NAME"],
                          ),
                      ],
                    )
                    : SizedBox(),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 20),
                      SizedBox(
                        width: (screenSize.width < 450) ? 300 : 305,
                        height: 45,
                        child: TextField(
                          autofocus: replyTextFieldAutoFocus,
                          cursorColor: Colors.black,
                          style: TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black54,
                                width: 2,
                              ),
                            ),
                          ),
                          controller: replyController,
                        ),
                      ),
                      IconButton(
                        onPressed: addReplyFunc,
                        icon: Icon(Icons.arrow_forward),
                      ),

                      SizedBox(width: 10),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
