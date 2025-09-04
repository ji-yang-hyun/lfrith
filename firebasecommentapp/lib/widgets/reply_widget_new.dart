import 'package:firebasecommentapp/screens/user_screen.dart';
import 'package:flutter/material.dart';

class ReplyWidgetNew extends StatelessWidget {
  const ReplyWidgetNew({
    super.key,
    required this.replyInfo,
    required this.replyUserName,
  });
  final Map<String, dynamic> replyInfo;
  final String replyUserName;

  @override
  Widget build(BuildContext context) {
    if (replyInfo["report_count"] > 10) {
      return SizedBox(height: 0, width: 0);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          UserScreen(userNumber: replyInfo["user_number"]),
                ),
              );
            },
            child: SizedBox(
              width: 200,
              child: Text(
                replyUserName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Text("${replyInfo["text"]}"),
        ],
      ),
    );
  }
}
