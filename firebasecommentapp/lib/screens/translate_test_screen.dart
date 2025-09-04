import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class TranslateTestScreen extends StatefulWidget {
  const TranslateTestScreen({super.key});

  @override
  State<TranslateTestScreen> createState() => _TranslateTestScreenState();
}

class _TranslateTestScreenState extends State<TranslateTestScreen> {
  String inputText = "사랑";
  String outputText = "";

  void translate() async {
    final translator = GoogleTranslator();
    var outputTextT = await translator.translate(inputText, to: 'ja');
    print(outputTextT);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(inputText),
            IconButton(onPressed: translate, icon: Icon(Icons.abc)),
            Text(outputText),
          ],
        ),
      ),
    );
  }
}
