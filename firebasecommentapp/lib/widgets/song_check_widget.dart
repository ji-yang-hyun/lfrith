import 'package:firebasecommentapp/global_vars.dart';
import 'package:flutter/material.dart';

class SongCheckWidget extends StatelessWidget {
  const SongCheckWidget({
    super.key,
    required this.title,
    required this.artist,
    required this.albumCoverImgUrl,
  });
  final String title;
  final String artist;
  final String albumCoverImgUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: Image.network(
              albumCoverImgUrl,
              errorBuilder: (context, error, stackTrace) {
                validImage = false;
                return Image.network(
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_rqQVUrNowKczeqwa1EGdyyY1FdcdkzuGcA&s",
                );
              },
            ),
          ),
          SizedBox(height: 13),
          Text(
            title,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            artist,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
