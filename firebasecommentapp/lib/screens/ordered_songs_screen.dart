import 'package:firebasecommentapp/widgets/bottom_navigation_bar.dart';
import 'package:firebasecommentapp/widgets/mini_music_widget.dart';
import 'package:flutter/material.dart';

class OrderedSongsScreen extends StatelessWidget {
  const OrderedSongsScreen({
    super.key,
    required this.orderByText,
    required this.songsList,
    required this.songsInfo,
  });
  final List<dynamic> songsList;
  final String orderByText;
  final List<Map<String, dynamic>> songsInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Hero(
        tag: "bar",
        child: myBottomNavigationBar(currentWidgetName: "HOME"),
      ),

      appBar: AppBar(
        title: Text(
          orderByText,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            for (int i in songsList)
              MiniMusicWidget(
                musicInfo: songsInfo[i],
                musicNumber: i,
                screenNumber: 1,
              ),
          ],
        ),
      ),
    );
  }
}
