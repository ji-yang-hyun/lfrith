import 'package:firebasecommentapp/widgets/top_music_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';

class OrderedSongsTopWidget extends StatelessWidget {
  const OrderedSongsTopWidget({
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
    return Column(
      children: [
        SizedBox(height: 60),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                orderByText,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 27),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 500,
          width: 500,
          child: CarouselSlider(
            unlimitedMode: true,
            // slideTransform: ZoomOutSlideTransform(zoomOutScale: 0.8),
            enableAutoSlider: true,
            autoSliderDelay: Duration(milliseconds: 5000),
            autoSliderTransitionTime: Duration(milliseconds: 800),
            children: [
              for (int i
                  in (songsList.length >= 5)
                      ? songsList.sublist(0, 3)
                      : songsList)
                TopMusicWidget(musicInfo: songsInfo[i], musicNumber: i),
            ],
          ),
        ),
      ],
    );
  }
}
