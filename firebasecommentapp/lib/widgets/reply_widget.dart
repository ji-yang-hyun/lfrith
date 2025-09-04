import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasecommentapp/screens/user_screen.dart';
import 'package:flutter/material.dart';

class ReplyWidget extends StatefulWidget {
  const ReplyWidget({super.key, required this.replyNumber});
  final int replyNumber;

  @override
  State<ReplyWidget> createState() => _ReplyWidgetState();
}

class _ReplyWidgetState extends State<ReplyWidget> {
  int replyReportCount = 0;
  String replyText = "";
  int replyUserNumber = 0;
  String replyUserName = "";

  void retReplyInfo() async {
    var replyData =
        await FirebaseFirestore.instance
            .collection('comments')
            .doc('comment${widget.replyNumber}')
            .get();
    Map<String, dynamic> replyInfo = Map<String, dynamic>.from(
      replyData.data() as Map,
    );

    replyReportCount = replyInfo["report_count"];
    replyUserNumber = replyInfo["user_number"];
    replyText = replyInfo["text"];

    var replyUserData =
        await FirebaseFirestore.instance
            .collection('users')
            .doc('user$replyUserNumber')
            .get();

    Map<String, dynamic> replyUserInfo = Map<String, dynamic>.from(
      replyUserData.data() as Map,
    );

    replyUserName = replyUserInfo["NAME"];

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    retReplyInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (replyReportCount > 10) {
      return SizedBox(height: 0, width: 0);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          UserScreen(userNumber: replyUserNumber),
                ),
              );
            },
            child: Text(
              replyUserName,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Text("  $replyText"),
        ],
      ),
    );
  }
}
