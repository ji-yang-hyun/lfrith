import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

// Stop and free resources

class MusicPlayerTestScreen extends StatefulWidget {
  const MusicPlayerTestScreen({super.key});

  @override
  State<MusicPlayerTestScreen> createState() => _MusicPlayerTestScreenState();
}

class _MusicPlayerTestScreenState extends State<MusicPlayerTestScreen> {
  final player = AudioPlayer(); // Create a player
  void init() async {
    final duration = await player.setUrl(
      // Load a URL
      'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',

      //원하는건 유튜브 링크인데 그거는 어떻게 해야할지 잘 모르겠음....
      //아니면 그냥 다른 라이브러리를 써야하려나? 잘 모르겠네 이거 ㅉㅉ
      //아니면 그냥 예전에 생각했던 방식대로 웹뷰를 파고 그걸 유튜브 뮤직이던 아니면 어떤거던 사용하는건 어떨까 싶다
      //사실 중요한건 ui디자인이랑 배경이니까는 ㅇㅇㅇ
    ); // Schemes: (https: | file: | asset: )
    player.play(); // Play without waiting for completion
    await player.play(); // Play while waiting for completion
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("data")));
  }
}

/*
아무리 봐도 이건 그냥 나중에 할 프로젝트로 남겨두고 지금 하던 음악 평점 앱을 마저 완성하는게 나을 것 같아 ㅇㅇ...
근데 이제 좀 계획이 바뀐거는 평점기능을 넣고싶다는거지 ㅇㅇ
*/
