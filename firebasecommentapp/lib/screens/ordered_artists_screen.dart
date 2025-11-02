import 'package:firebasecommentapp/widgets/bottom_navigation_bar.dart';
import 'package:firebasecommentapp/widgets/mini_artist_widget.dart';
import 'package:firebasecommentapp/widgets/mini_music_widget.dart';
import 'package:flutter/material.dart';

class OrderedArtistsScreen extends StatelessWidget {
  const OrderedArtistsScreen({
    super.key,
    required this.orderByText,
    required this.artistsList,
    required this.artistsInfo,
  });
  final List<dynamic> artistsList;
  final String orderByText;
  final List<Map<String, dynamic>> artistsInfo;

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
            for (int i in artistsList)
              MiniArtistWidget(
                artistInfo: artistsInfo[i],
                artistNumber: artistsInfo[i]["number"],
                screenNumber: 1,
              ),
          ],
        ),
      ),
    );
  }
}
