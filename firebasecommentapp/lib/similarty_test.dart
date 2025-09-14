import 'package:plagiarism_checker_plus/plagiarism_checker_plus.dart';
import 'package:translator/translator.dart';

void main() async {
  final checker = PlagiarismCheckerPlus();
  // final text1 = "Chikyu o ataeru";
  final text1 = "ルーマー";
  final text2 = "루머";
  final translator = GoogleTranslator();
  var outputText1T = await translator.translate(text1, from: 'ja', to: 'en');
  String outputText1 = outputText1T.toString();
  var outputText2T = await translator.translate(text2, to: 'en');
  String outputText2 = outputText2T.toString().toLowerCase();

  print(outputText1);
  print(outputText2);
  final result = checker.check(outputText1, outputText2);
  print(result.similarityScore);
}
