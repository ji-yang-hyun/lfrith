// database에는 0번이 포함되어있으니 유의하자!
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

int loginUserNumber = 1;

int latestSongNumber = 0;

int songScreenLoadCount = 0;

int showFullTextCommentNumber = -1;

int preLoadCount = 0;

int likeRequestCount = 0;

List<int> newLikedComments = [];
List<int> newUnLikedComments = [];

FocusNode searchTextFieldFocusNode = FocusNode();

List<Map<String, dynamic>> songsInfoPreLoad = [];
List<Map<String, dynamic>> usersInfoPreLoad = [];
List<Map<String, dynamic>> commentsInfoPreLoad = [];

Future<List<Map<String, dynamic>>> songsInfoPreLoadUpdate({
  int mode = 0,
}) async {
  var songsData =
      await FirebaseFirestore.instance
          .collection('songs')
          .orderBy("number")
          .get();
  var songsInfo = [
    for (int i = 0; i < songsData.size; i++)
      Map<String, dynamic>.from(songsData.docs[i].data() as Map),
  ]; //역대 모든 노래들 불러오기.

  if (mode == 0) {
    songsInfoPreLoad = List.from(songsInfo);
  }
  if (mode == 1) {
    preLoadCount += 1;
  }

  return songsInfo;
}

Future<List<Map<String, dynamic>>> commentsInfoPreLoadUpdate({
  int mode = 0,
}) async {
  var commentsData =
      await FirebaseFirestore.instance
          .collection('comments')
          .orderBy("number")
          .get();
  var commentsInfo = [
    for (int i = 0; i < commentsData.size; i++)
      Map<String, dynamic>.from(commentsData.docs[i].data() as Map),
  ]; //역대 모든 노래들 불러오기.
  if (mode == 0) {
    commentsInfoPreLoad = List.from(commentsInfo);
  }
  if (mode == 1) {
    preLoadCount += 1;
  }

  return commentsInfo;
}

Future<List<Map<String, dynamic>>> usersInfoPreLoadUpdate({
  int mode = 0,
}) async {
  var usersData =
      await FirebaseFirestore.instance
          .collection('users')
          .orderBy("number")
          .get();
  var usersInfo = [
    for (int i = 0; i < usersData.size; i++)
      Map<String, dynamic>.from(usersData.docs[i].data() as Map),
  ]; //역대 모든 노래들 불러오기.
  if (mode == 0) {
    usersInfoPreLoad = List.from(usersInfo);
  }
  if (mode == 1) {
    preLoadCount += 1;
  }

  return usersInfo;
}

List<dynamic> mostRecommendedSongsPreLoad = [];

double recommendPointFunc(
  int views,
  int commentCount,
  int likes,
  double rating,
  int reportCount,
) {
  return commentCount.toDouble();
}

Future<void> getNurak() async {
  var commentsData =
      await FirebaseFirestore.instance
          .collection('comments')
          .orderBy("number")
          .get();
  var commentsInfo = [
    for (int i = 0; i < commentsData.size; i++)
      Map<String, dynamic>.from(commentsData.docs[i].data() as Map),
  ]; //역대 모든 노래들 불러오기.
  List<int> nurakcomments = [];
  List<int> replys = [];

  for (Map<String, dynamic> commentInfo in commentsInfo) {
    for (var replyNum in commentInfo["replys"]) {
      replys.add(replyNum);
    }
  }
  List<int> comments = [for (int i = 0; i < commentsInfo.length; i++) i];
  List<int> annurakComments = [];
  var songsData =
      await FirebaseFirestore.instance
          .collection('songs')
          .orderBy("number")
          .get();

  var songsInfo = [
    for (int i = 0; i < songsData.size; i++)
      Map<String, dynamic>.from(songsData.docs[i].data() as Map),
  ]; //역대 모든 노래들 불러오기.

  for (Map<String, dynamic> songInfo in songsInfo) {
    if (songInfo["number"] != 4) {
      print("a");
      for (int commentNum in songInfo["comment_numbers"]!) {
        annurakComments.add(commentNum);
      }
    }
  }
  for (int commentNum in comments) {
    if (!annurakComments.contains(commentNum) && !replys.contains(commentNum)) {
      nurakcomments.add(commentNum);
    }
  }

  print(nurakcomments);
}

//
bool validImage = true;
