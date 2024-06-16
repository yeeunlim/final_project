import 'package:flutter/material.dart';

class DrawingPoints {
  Paint paint;
  Offset points;

  DrawingPoints({required this.paint, required this.points});
}

class DrawingData {
  int? id;
  List<DrawingPoints> points;

  DrawingData({this.id, required this.points});
}

class DrawingProvider with ChangeNotifier {
  Map<int, DrawingData> _drawings = {};
  int _currentStep = 0;

  Map<int, DrawingData> get drawings => _drawings;
  int get currentStep => _currentStep;

  void saveDrawing(int step, DrawingData data) {
    _drawings[step] = data;
    notifyListeners();
  }

  void setCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  DrawingData getDrawing(int step) {
    return _drawings[step] ?? DrawingData(points: []);
  }

  void removeDrawing(int step) {
    if (_drawings.containsKey(step)) {
      _drawings.remove(step);
      notifyListeners();
    }
  }
}
