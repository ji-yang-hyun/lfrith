import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasecommentapp/global_vars.dart';
import 'package:firebasecommentapp/screens/artist_screen.dart';
import 'package:firebasecommentapp/screens/home_screen.dart';
import 'package:firebasecommentapp/screens/login_screen.dart';
import 'package:firebasecommentapp/screens/search_screen.dart';
import 'package:firebasecommentapp/screens/user_screen.dart';
import 'package:firebasecommentapp/widgets/comment_widget_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

int commentNumberToShow = 0;
bool replyTextFieldAutoFocus = false;

class SongScreen extends StatefulWidget {
  const SongScreen({
    super.key,
    required this.songNumber,
    required this.targetUserNumber,
  });
  final int songNumber;
  final int targetUserNumber;

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  Map<String, dynamic> songInfo = {};
  bool showCommentTextfield = true;
  TextEditingController commentController = TextEditingController();
  int commentRating = 1;
  bool loadMyComment = false;
  int buildCount = 0;

  void gotoLogin() {
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
        pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
      ),
    );
  }

  void logFunc() async {
    if (loginUserNumber == -1) {
      return;
    }
    usersInfoPreLoad[loginUserNumber]["user_visit_log"].add(widget.songNumber);

    var userData =
        await FirebaseFirestore.instance
            .collection('users')
            .doc("user$loginUserNumber")
            .get();
    var userInfo = Map<String, dynamic>.from(userData.data() as Map);
    userInfo["user_visit_log"].add(widget.songNumber);
    FirebaseFirestore.instance
        .collection('users')
        .doc('user$loginUserNumber')
        .set(userInfo);
  }

  Future<void> likeFunc() async {
    if (loginUserNumber == -1) {
      gotoLogin();
      return;
    }

    print("like request start");
    var commentsDataDB =
        await FirebaseFirestore.instance
            .collection('comments')
            .orderBy("number")
            .get();
    List<Map<String, dynamic>> commentsInfoDB = [
      for (int i = 0; i < commentsDataDB.size; i++)
        Map<String, dynamic>.from(commentsDataDB.docs[i].data() as Map),
    ]; //역대 모든 노래들 불러오기.

    var usersDataDB =
        await FirebaseFirestore.instance
            .collection('users')
            .orderBy("number")
            .get();
    List<Map<String, dynamic>> usersInfoDB = [
      for (int i = 0; i < usersDataDB.size; i++)
        Map<String, dynamic>.from(usersDataDB.docs[i].data() as Map),
    ]; //역대 모든 노래들 불러오기.

    for (int commentNum in newLikedComments) {
      print(commentNum);
      commentsInfoDB[commentNum]["likes"] += 1;
      usersInfoDB[loginUserNumber]["liked_comment"].add(commentNum);
    }

    for (int commentNum in newUnLikedComments) {
      print(commentNum);
      commentsInfoDB[commentNum]["likes"] -= 1;
      usersInfoDB[loginUserNumber]["liked_comment"].remove(commentNum);
    }

    List<int> changedComments =
        [
          newUnLikedComments,
          newLikedComments,
        ].expand((x) => x).toSet().toList();

    for (int commentNum in changedComments) {
      await FirebaseFirestore.instance
          .collection('comments')
          .doc('comment$commentNum')
          .set(commentsInfoDB[commentNum]);
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc('user$loginUserNumber')
        .set(usersInfoDB[loginUserNumber]);

    newLikedComments = [];
    newUnLikedComments = [];
    print("like request done");
  }

  void exitFunc() async {
    latestSongNumber = widget.songNumber;
    await likeFunc();

    print("sorting start");

    var commentsDataDB =
        await FirebaseFirestore.instance
            .collection('comments')
            .orderBy("number")
            .get();
    var commentsInfoDB = [
      for (int i = 0; i < commentsDataDB.size; i++)
        Map<String, dynamic>.from(commentsDataDB.docs[i].data() as Map),
    ]; //역대 모든 댓글들 불러오기.

    // 다른 유저에 의한 변경점 있을 수도 있으니 불러오기.
    var songDataDB =
        await FirebaseFirestore.instance
            .collection('songs')
            .doc("song${widget.songNumber}")
            .get();
    Map<String, dynamic> songInfoNew = Map<String, dynamic>.from(
      songDataDB.data() as Map,
    );
    //   albumCoverImgUrl = newSongInfo["albumcover"];
    //   artist = newSongInfo["artist"];
    //   commentNumbers = newSongInfo["comment_numbers"];
    //   likes = newSongInfo["likes"];
    //   reportCount = newSongInfo["report_count"];
    //   titleLarge = newSongInfo["title"];
    //   views = newSongInfo["views"];
    //   musicUrl = newSongInfo["youtube_url"];
    //   rating = double.parse(newSongInfo["rating"].toString());

    // print(songInfoNew["comment_numbers"]);
    songInfoNew["comment_numbers"].sort((a, b) {
      if (commentsInfoDB[a]["likes"] < commentsInfoDB[b]["likes"]) {
        return 1;
      } else {
        return -1;
      }
    });
    // print(songInfoNew["comment_numbers"]);

    FirebaseFirestore.instance
        .collection('songs')
        .doc('song${widget.songNumber}')
        .set(songInfoNew);

    print("sorting done");
  }

  void gotoYoutube() async {
    if (Platform.isIOS) {
      if (await canLaunchUrl(Uri.parse(songInfo["youtube_url"]))) {
        await launchUrl(
          Uri.parse(songInfo["youtube_url"]),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (await canLaunchUrl(Uri.parse(songInfo["youtube_url"]))) {
          await launchUrl(Uri.parse(songInfo["youtube_url"]));
        } else {
          throw 'Could not launch https://www.youtube.com/channel/UCwXdFgeE9KYzlDdR7TG9cMw';
        }
      }
    } else {
      const url = 'https://www.youtube.com/channel/UCwXdFgeE9KYzlDdR7TG9cMw';
      if (await canLaunchUrl(Uri.parse(songInfo["youtube_url"]))) {
        await launchUrl(Uri.parse(songInfo["youtube_url"]));
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  void showCommentTextfieldFunc() {
    showCommentTextfield = !showCommentTextfield;
    setState(() {});
  }

  void setStateForChild() {
    setState(() {});
  }

  void addCommentFrontEnd(Map<String, dynamic> commentData) {
    HapticFeedback.mediumImpact();
    int newCommentNumber = commentsInfoPreLoad.length;
    commentData["number"] = newCommentNumber;
    songsInfoPreLoad[widget.songNumber]["comment_numbers"].add(
      newCommentNumber,
    );
    commentsInfoPreLoad.add(commentData);
    usersInfoPreLoad[loginUserNumber]["commented_songs"].add(widget.songNumber);
    songsInfoPreLoad[widget.songNumber]["rating"] = double.parse(
      ((songsInfoPreLoad[widget.songNumber]["rating"] *
                      songsInfoPreLoad[widget.songNumber]["comment_numbers"]
                          .length +
                  commentData["rating"]) /
              (songsInfoPreLoad[widget.songNumber]["comment_numbers"].length +
                  1))
          .toStringAsFixed(3),
    );
    setState(() {});
  }

  void addCommentBackEnd(Map<String, dynamic> commentData) async {
    //preLoad안한 그 갭 사이에 추가된걸 덮어쓰면 안되니 여기서는 preLoad사용 금지.

    //user정보에 이 노래에 이미 댓글 달았다고 표시하기
    var userData =
        await FirebaseFirestore.instance
            .collection('users')
            .doc("user$loginUserNumber")
            .get();
    var userInfo = Map<String, dynamic>.from(userData.data() as Map);
    userInfo["commented_songs"].add(widget.songNumber);
    FirebaseFirestore.instance
        .collection('users')
        .doc('user$loginUserNumber')
        .set(userInfo);

    var comments =
        await FirebaseFirestore.instance
            .collection('comments')
            .orderBy("number")
            .get();
    int commentCount = comments.size - 1; // 제일 마지막 코멘트, 즉 코멘트 현재 개수
    int newCommentNumber = commentCount + 1;

    var songsDataDB =
        await FirebaseFirestore.instance
            .collection('songs')
            .orderBy("number")
            .get();

    List<Map<String, dynamic>> songsInfoDB = [
      for (int i = 0; i < songsDataDB.size; i++)
        Map<String, dynamic>.from(songsDataDB.docs[i].data() as Map),
    ]; //역대 모든 노래들 불러오기.

    Map<String, dynamic> songInfoNew = Map.from(songsInfoDB[widget.songNumber]);

    songInfoNew["rating"] = double.parse(
      ((songInfoNew["rating"] * songInfoNew["comment_numbers"].length +
                  commentData["rating"]) /
              (songInfoNew["comment_numbers"].length + 1))
          .toStringAsFixed(3),
    );
    songInfoNew["comment_numbers"].add(newCommentNumber);

    FirebaseFirestore.instance
        .collection('songs')
        .doc('song${widget.songNumber}')
        .set(songInfoNew);

    //이제 comments에 저장.
    commentData["number"] = newCommentNumber;
    FirebaseFirestore.instance
        .collection('comments')
        .doc('comment$newCommentNumber')
        .set(commentData);

    // 최근 댓글 달림 저장
    var commentedData =
        await FirebaseFirestore.instance
            .collection('home')
            .doc('home_screen_data')
            .get();

    Map<String, dynamic> commentedInfo = Map<String, dynamic>.from(
      commentedData.data() as Map,
    );

    commentedInfo["lately_commented"].add(widget.songNumber);

    FirebaseFirestore.instance
        .collection('home')
        .doc('home_screen_data')
        .set(commentedInfo);

    print("DB updated");
  }

  //////////////////////////////
  void addComment() {
    if (loginUserNumber == -1) {
      gotoLogin();
      return;
    }

    int commentRatingCopy = commentRating;
    String commentText = commentController.text;

    FocusScope.of(context).unfocus();
    commentRating = 1;
    commentController.clear();

    Map<String, dynamic> commentData = {
      "likes": 0,
      "rating": commentRatingCopy,
      "replys": [],
      "report_count": 0,
      "text": commentText,
      "user_number": loginUserNumber,
      "number": 0,
    };

    if (commentText.isEmpty) {
      return;
    }

    addCommentFrontEnd(commentData);
    addCommentBackEnd(commentData);
  }

  List<int> getMyComments() {
    // 내가 쓴 댓글을 모아서 맨 위에서 볼 수 있게!
    //addcomments에서 따로 추가해주니까 여기서는 굳이 초기화필요성 x
    List<int> myComments = [];
    if (loginUserNumber == -1) {
      return myComments;
    }
    for (int i in songInfo["comment_numbers"]) {
      int commentUserNumber = commentsInfoPreLoad[i]["user_number"];
      if (commentUserNumber == loginUserNumber) {
        myComments.add(i);
      }
    }

    return myComments;
  }

  List<int> getTargetComments() {
    // 내가 쓴 댓글을 모아서 맨 위에서 볼 수 있게!
    List<int> targetComments = [];
    if (widget.targetUserNumber == loginUserNumber) {
      return targetComments;
    }
    for (int i in songInfo["comment_numbers"]) {
      int commentUserNumber = commentsInfoPreLoad[i]["user_number"];
      if (commentUserNumber == widget.targetUserNumber) {
        targetComments.add(i);
      }
    }

    return targetComments;
  }

  List<int> getCommentListToShow() {
    List<int> myComments = getMyComments();
    List<int> targetComments = getTargetComments();
    List<int> commentsToShow = List.from(targetComments);
    if (myComments.isNotEmpty && targetComments.isNotEmpty) {
      for (int commentNumber in songInfo["comment_numbers"]) {
        if (!myComments.contains(commentNumber) &&
            !targetComments.contains(commentNumber)) {
          commentsToShow.add(commentNumber);
        }
      }
    }
    if (myComments.isNotEmpty && targetComments.isEmpty) {
      for (int commentNumber in songInfo["comment_numbers"]) {
        if (!myComments.contains(commentNumber)) {
          commentsToShow.add(commentNumber);
        }
      }
    }
    if (myComments.isEmpty && targetComments.isNotEmpty) {
      for (int commentNumber in songInfo["comment_numbers"]) {
        if (!targetComments.contains(commentNumber)) {
          commentsToShow.add(commentNumber);
        }
      }
    }
    if (myComments.isEmpty && targetComments.isEmpty) {
      for (int commentNumber in songInfo["comment_numbers"]) {
        commentsToShow.add(commentNumber);
      }
    }
    return [myComments, commentsToShow].expand((x) => x).toSet().toList();
  }

  void getcomments() {
    getMyComments();
    if (widget.targetUserNumber != loginUserNumber) {
      getTargetComments();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    songInfo = songsInfoPreLoad[widget.songNumber];
    latestSongNumber = widget.songNumber;
    getcomments();
    setState(() {});
    logFunc();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    buildCount += 1;
    var screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      // onDoubleTap: () {
      //   exitFunc();
      //   Navigator.of(context).pop();
      // },
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: Hero(
          tag: "bar",
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    exitFunc();
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
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                HomeScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.home, color: Colors.black54),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.album, color: Colors.blue),
                ),
                IconButton(
                  onPressed: () {
                    exitFunc();
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
                                SearchScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.search, color: Colors.black54),
                ),
                IconButton(
                  onPressed: () {
                    if (loginUserNumber == -1) {
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
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  LoginScreen(),
                        ),
                      );
                      return;
                    }
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
                                UserScreen(userNumber: loginUserNumber),
                      ),
                    );
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.circleUser,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                height: (screenSize.width < 450) ? 270 : 290,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(songInfo["albumcover"]),
                    fit: BoxFit.fitHeight,
                  ),
                ),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.black.withValues(alpha: 0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                    height: 140,
                                    width: 140,
                                    child: GestureDetector(
                                      onTap: () {
                                        gotoYoutube();
                                      },
                                      child: Image.network(
                                        songInfo["albumcover"],
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 250,
                                      child: GestureDetector(
                                        onTap: () {
                                          for (var artistInfo
                                              in artistsInfoPreLoad) {
                                            if (artistInfo["name"] ==
                                                songInfo["artist"]) {
                                              Navigator.of(
                                                context,
                                              ).pushReplacement(
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
                                                    var end = const Offset(
                                                      0,
                                                      0,
                                                    );
                                                    // Curves.ease: 애니메이션이 부드럽게 동작하도록 명령
                                                    var curve = Curves.ease;
                                                    // 애니메이션의 시작과 끝을 담당한다.
                                                    var tween = Tween(
                                                      begin: begin,
                                                      end: end,
                                                    ).chain(
                                                      CurveTween(curve: curve),
                                                    );
                                                    return SlideTransition(
                                                      position: animation.drive(
                                                        tween,
                                                      ),
                                                      child: child,
                                                    );
                                                  },
                                                  pageBuilder:
                                                      (
                                                        context,
                                                        animation,
                                                        secondaryAnimation,
                                                      ) => ArtistScreen(
                                                        artistInfo: artistInfo,
                                                        screenNumber: 2,
                                                      ),
                                                ),
                                              );
                                              break;
                                            }
                                          }
                                        },
                                        child: Text(
                                          songInfo["artist"],
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 250,
                                      height: 30,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          "${songInfo["title"]}      ",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.white),
                                        Text(
                                          songInfo["rating"].toString(),
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        Icon(
                                          Icons.remove_red_eye,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "${(songInfo["views"] / 10000).toStringAsFixed(1)}만",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        Icon(
                                          Icons.thumb_up_rounded,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "${(songInfo["likes"] / 1000).toStringAsFixed(1)}천",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "${songInfo["comment_numbers"].length}Comments",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: RepaintBoundary(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          children: [
                            for (int commentNumber in getCommentListToShow())
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 4,
                                ),
                                child: CommentWidgetNew(
                                  commentInfo:
                                      commentsInfoPreLoad[commentNumber],
                                  userInfo:
                                      usersInfoPreLoad[commentsInfoPreLoad[commentNumber]["user_number"]],
                                  parentSetStateFunc: setStateForChild,
                                  myUserInfo:
                                      (loginUserNumber != -1)
                                          ? usersInfoPreLoad[loginUserNumber]
                                          : {"number": -1},
                                ),
                              ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 20),
                                  SizedBox(
                                    width: (screenSize.width < 450) ? 270 : 290,
                                    height: 45,
                                    child: TextField(
                                      cursorColor: Colors.black,
                                      style: TextStyle(fontSize: 17),
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
                                      controller: commentController,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 35,
                                    child: GestureDetector(
                                      onTap: () {
                                        HapticFeedback.mediumImpact();
                                        commentRating += 1;
                                        if (commentRating > 5) {
                                          commentRating = 1;
                                        }
                                        setState(() {});
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.star, size: 20),
                                          Text(
                                            " $commentRating",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 3,
                                    ),
                                    child: IconButton(
                                      onPressed: addComment,
                                      icon: Icon(Icons.arrow_forward),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ),
                    ],
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

// legacy

// void backToListViewFunc() {
//   showCommentTextfield = true;
//   getcomments();
//   setState(() {});
// }

// void parentSetStateFunc(List<dynamic> updatedCommentsList) {
//   //코멘트 위젯에서 이미 파이어베이스에 추가는 했다.
//   //songInfo는 처음에 받아올 때만 사용하므로 굳이 바꿔줄 필요가 없다.
//   commentNumbers = updatedCommentsList;
//   setState(() {});
// }

// if (!showCommentTextfield)
//   FullCommentWidget(
//     commentNumber: commentNumberToShow,
//     songNumber: widget.songNumber,
//     songComments: commentNumbers,
//     backToListViewFunc: backToListViewFunc,
//   ),

// SizedBox(
//   height:
//       (MediaQuery.of(context).viewInsets.bottom > 70)
//           ? MediaQuery.of(context).viewInsets.bottom
//           : 0,
// ),

// Future<void> getSongInfo() async {
//   var newSongData =
//       await FirebaseFirestore.instance
//           .collection('songs')
//           .doc("song${widget.songNumber}")
//           .get();
//   Map<String, dynamic> newSongInfo = Map<String, dynamic>.from(
//     newSongData.data() as Map,
//   );
//   albumCoverImgUrl = newSongInfo["albumcover"];
//   artist = newSongInfo["artist"];
//   commentNumbers = newSongInfo["comment_numbers"];
//   likes = newSongInfo["likes"];
//   reportCount = newSongInfo["report_count"];
//   title = newSongInfo["title"];
//   views = newSongInfo["views"];
//   musicUrl = newSongInfo["youtube_url"];
//   rating = double.parse(newSongInfo["rating"].toString());
//   setState(() {});
// }

// String albumCoverImgUrl = "";
// String artist = "";
// List<dynamic> commentNumbers = [];
// int likes = 0;
// int reportCount = 0;
// String title = "";
// int views = 0;
// String musicUrl = "";
// double rating = 0;

//   ////////////////////////////// preLoad쓰기 전 addComment
// void addComment() async {
//   int commentRatingCopy = commentRating;
//   String commentText = commentController.text;

//   FocusScope.of(context).unfocus();
//   commentRating = 1;
//   commentController.clear();

//   Map<String, dynamic> commentData = {
//     "likes": 0,
//     "rating": commentRatingCopy,
//     "replys": [],
//     "report_count": 0,
//     "text": commentText,
//     "user_number": loginUserNumber,
//     "number": 0,
//   };

//   if (commentText.isEmpty) {
//     return;
//   }

//   addCommentFrontEnd(commentData);

//   //user정보에 이 노래에 이미 댓글 달았다고 표시하기
//   var userData =
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc("user$loginUserNumber")
//           .get();
//   var userInfo = Map<String, dynamic>.from(userData.data() as Map);
//   userInfo["commented_songs"].add(widget.songNumber);
//   FirebaseFirestore.instance
//       .collection('users')
//       .doc('user$loginUserNumber')
//       .set(userInfo);

//   var comments =
//       await FirebaseFirestore.instance
//           .collection('comments')
//           .orderBy("number")
//           .get();
//   var commentCount = comments.size - 1; //지금까지 있던 모든 노래의 댓글 수

//   print(widget.songNumber);
//   print(commentData);

//   /*
//   songInfo는 사실 변경해도 상관 없는데 final변수니까 뭔가 그걸 바꾸는게 좀 맘에 걸리고
//   될 때 안될 때가 있어서 그냥 songInfo는 처음에 받아올 때만 쓰도록 하자.
//   근데 그러면 다시 업로드 할 때는 어떡하지??
//   근데 이러면 진짜 많이 고쳐야 겠는데
//   */

//   Map<String, dynamic> songInfoCopy = widget.songInfoCopy;

//   songInfoCopy["rating"] = double.parse(
//     ((rating * commentNumbers.length + commentData["rating"]) /
//             (commentNumbers.length + 1))
//         .toStringAsFixed(3),
//   );

//   songInfoCopy["comment_numbers"].add(commentCount + 1);
//   rating = widget.songInfoCopy["rating"];
//   commentNumbers = songInfoCopy["comment_numbers"];

//   await FirebaseFirestore.instance
//       .collection('songs')
//       .doc('song${widget.songNumber}')
//       .set(songInfoCopy);

//   commentData["number"] = commentCount + 1;
//   FirebaseFirestore.instance
//       .collection('comments')
//       .doc('comment${commentCount + 1}')
//       .set(commentData);

//   // initState(); //songInfo만 수정했으므로 로컬변수들을 다시 할당해주기 위해서
//   //위젯이 만들어진 후에 initstate는 쓸 수 없다.

//   //최근 댓글달린거 저장
//   var commentedData =
//       await FirebaseFirestore.instance
//           .collection('home')
//           .doc('home_screen_data')
//           .get();

//   Map<String, dynamic> commentedInfo = Map<String, dynamic>.from(
//     commentedData.data() as Map,
//   );

//   commentedInfo["lately_commented"].removeAt(0);
//   commentedInfo["lately_commented"].add(widget.songNumber);

//   FirebaseFirestore.instance
//       .collection('home')
//       .doc('home_screen_data')
//       .set(commentedInfo);

//   myComments.add(commentCount + 1);

//   //commentNumbers와 myComments에 각각 잘 저장해줬다.

//   //댓글단 정보가 songsInfoPreLoad에 저장 안되므로 저장해주기.
//   var songsData =
//       await FirebaseFirestore.instance
//           .collection('songs')
//           .orderBy("number")
//           .get();
//   songsInfoPreLoad = [
//     for (int i = 0; i < songsData.size; i++)
//       Map<String, dynamic>.from(songsData.docs[i].data() as Map),
//   ];

//   await getcomments();
//   setState(() {});
// }

// void getMyComments() async {
//   // 내가 쓴 댓글을 모아서 맨 위에서 볼 수 있게!
//   //addcomments에서 따로 추가해주니까 여기서는 굳이 초기화필요성 x

//   for (int i in songInfo["comment_numbers"]) {
//     int commentUserNumber = commentsInfoPreLoad[i]["user_number"];
//     if (commentUserNumber == loginUserNumber) {
//       myComments.add(i);
//     }
//   }

//   loadMyComment = true;
//   setState(() {});
// }

// void getTargetComments() async {
//   // 내가 쓴 댓글을 모아서 맨 위에서 볼 수 있게!

//   for (int i in songInfo["comment_numbers"]) {
//     int commentUserNumber = commentsInfoPreLoad[i]["user_number"];
//     if (commentUserNumber == widget.targetUserNumber) {
//       targetComments.add(i);
//     }
//   }
//   setState(() {});
// }

// List<int> getCommentListToShow() {
//   List<int> commentsToShow = List.from(targetComments);
//   for (int commentNumber in songInfo["comment_numbers"]) {
//     if (!myComments.contains(commentNumber) &&
//         !targetComments.contains(commentNumber)) {
//       commentsToShow.add(commentNumber);
//     }
//   }
//   return commentsToShow;
// }

// Future<void> getcomments() async {
//   // var comments =
//   //     await FirebaseFirestore.instance
//   //         .collection('comments')
//   //         .orderBy("number")
//   //         .get();
//   // commentsInfoPreLoad = [
//   //   for (int i = 0; i < comments.size; i++)
//   //     Map<String, dynamic>.from(comments.docs[i].data() as Map),
//   // ]; //역대 모든 댓글들 불러오기.

//   commentsInfoPreLoad = List.from(commentsInfoPreLoad);
//   // var users =
//   //     await FirebaseFirestore.instance
//   //         .collection('users')
//   //         .orderBy("number")
//   //         .get();
//   // usersInfoPreLoad = [
//   //   for (int i = 0; i < users.size; i++)
//   //     Map<String, dynamic>.from(users.docs[i].data() as Map),
//   // ]; //역대 모든 댓글들 불러오기.

//   usersInfoPreLoad = List.from(usersInfoPreLoad);

//   getMyComments();
//   if (widget.targetUserNumber != loginUserNumber) {
//     getTargetComments();
//   }
// }



    //  if (!(loadMyComment &&
    //                       ((widget.targetUserNumber == loginUserNumber) ||
    //                           targetComments.isNotEmpty)))
    //                     Expanded(child = Text("")),