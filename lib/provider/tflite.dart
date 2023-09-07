import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as imglib;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum TfliteState { none, loading }

class Tflite extends ChangeNotifier {
  late final WebViewController controller;
  var loadingPercentage = 0;
  File? img;
  String? predLabel;
  List result = [];
  bool isLoading = false;
  XFile? imagePicked;
  List<String> allLabel = [];
  Interpreter? interpreterInstance;
  TfliteState state = TfliteState.none;
  double truncateToDecimal(num value, int fractionalDigits) =>
      (value * math.pow(10, fractionalDigits)).truncate() /
      math.pow(10, fractionalDigits);

  void loadAsset() async {
    String loadedString = await rootBundle.loadString('assets/label.txt');
    allLabel = loadedString.split('\n');
    notifyListeners();
  }

  Future<Interpreter> get _interpreter async {
    interpreterInstance ??= await Interpreter.fromAsset(
      'assets/model.tflite',
    );
    notifyListeners();
    return interpreterInstance!;
  }

  Future predict(imglib.Image img) async {
    final imageInput = imglib.copyResize(
      img,
      width: 224,
      height: 224,
    );

    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );

    result = await _runInference(imageMatrix);
    predLabel = getLabel(result);

    notifyListeners();
  }

  Future<List<num>> _runInference(
    List<List<List<num>>> imageMatrix,
  ) async {
    final interpreter = await _interpreter;
    final input = [imageMatrix];
    final output = List.filled(1 * allLabel.length, 0.0).reshape(
      [1, allLabel.length],
    );

    interpreter.run(input, output);
    notifyListeners();
    return output.first;
  }

  String getLabel(List? diagnoseScores) {
    int bestInd = 0;

    if (diagnoseScores != null) {
      num maxScore = 0;
      for (int i = 0; i < diagnoseScores.length; ++i) {
        if (maxScore < diagnoseScores[i]) {
          maxScore = diagnoseScores[i];
          bestInd = i;
        }
      }
    }
    notifyListeners();
    return allLabel[bestInd];
  }

  Future getImage(ImageSource source) async {
    isLoading = true;

    imagePicked = await ImagePicker().pickImage(source: source);
    if (imagePicked != null) {
      img = File(imagePicked!.path);
    } else {
      isLoading = false;
    }
    notifyListeners();
  }

  Future btnAction(source) async {
    await getImage(source);
    if (imagePicked != null) {
      await predict(imglib.decodeImage(File(img!.path).readAsBytesSync())!);
      await Future.delayed(const Duration(seconds: 1));
      isLoading = false;
    }
    notifyListeners();
    changeState(TfliteState.none);
  }

  changeState(TfliteState s) {
    state = s;
    notifyListeners();
  }
}
