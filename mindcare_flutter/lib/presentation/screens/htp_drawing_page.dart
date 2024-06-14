import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../widgets/custom_app_bar.dart';
import 'package:mindcare_flutter/core/services/api_service.dart';
import 'package:mindcare_flutter/core/services/auth_service.dart';
import 'chatbot_diary_entry_screen.dart';
import 'htp_result_page.dart';


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


class HTPDrawingPage extends StatefulWidget {
  final String token;

  HTPDrawingPage({required this.token});

  @override
  _HTPDrawingPageState createState() => _HTPDrawingPageState();
}

class _HTPDrawingPageState extends State<HTPDrawingPage> {
  final GlobalKey _globalKey = GlobalKey();
  double _brushSize = 5.0;
  double _eraserSize = 5.0;
  Color _color = Colors.black;
  List<DrawingPoints> _points = [];
  bool _isErasing = false;
  int _step = 0;
  String _result = '';
  List<String> _drawingIds = [];

  final List<String> _stepsText = [
    "집을 그려주세요",
    "나무를 그려주세요",
    "사람을 그려주세요"
  ];

  void _changeColor(Color color) {
    setState(() {
      _color = color;
      _isErasing = false;
    });
  }

  void _changeBrushSize(double size) {
    setState(() {
      _brushSize = size;
    });
  }

  void _changeEraserSize(double size) {
    setState(() {
      _eraserSize = size;
    });
  }

  Future<void> _nextStep() async {
    try {
      await Future.delayed(Duration(milliseconds: 100));
      final boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();
      final base64Image = base64Encode(buffer);

      var response = await HTPApiService.uploadDrawingBase64(base64Image, _stepsText[_step]);
      if (response != null) {
        final drawingProvider = Provider.of<DrawingProvider>(context, listen: false);

        // Remove the old drawing ID for this step if it exists
        final oldDrawing = drawingProvider.getDrawing(_step);
        if (oldDrawing.id != null) {
          _drawingIds.remove(oldDrawing.id.toString());
        }

        // Add new drawing ID
        _drawingIds.add(response['id'].toString());

        setState(() {
          _result = '그림이 저장되었습니다.';
        });
        print("Current drawing IDs: $_drawingIds");

        // Save current drawing data with new ID
        drawingProvider.saveDrawing(_step, DrawingData(id: response['id'], points: _points));
      }
    } catch (e) {
      print("Error in _nextStep: $e");
    }

    if (_step < 2) {
      setState(() {
        _step++;
        _points = [];
      });
      final drawingProvider = Provider.of<DrawingProvider>(context, listen: false);
      drawingProvider.setCurrentStep(_step);
    } else {
      _finalizeDiagnosis();
    }
  }

  Future<void> _finalizeDiagnosis() async {
    setState(() {
      _result = '진단 중입니다...';
    });

    var response = await HTPApiService.finalizeDiagnosis(_drawingIds);
    if (response != null) {
      List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(response);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            drawingIds: _drawingIds,
            results: results,
            token: widget.token,
          ),
        ),
      );
    } else {
      setState(() {
        _result = '진단 실패. 다시 시도해주세요.';
      });
    }
  }

  void _clearDrawing() {
    setState(() {
      _points.clear();
    });
  }

  void _enableEraser() {
    setState(() {
      _isErasing = true;
    });
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('HTP 검사를 종료하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => ChatbotDiaryEntryScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text('종료'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final drawingProvider = Provider.of<DrawingProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        if (drawingProvider.currentStep > 0) {
          setState(() {
            _step = drawingProvider.currentStep - 1;
            _points = drawingProvider.getDrawing(_step).points;
          });
          drawingProvider.setCurrentStep(_step);
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: CustomAppBar(),
        drawer: HTPCustomDrawer(token: widget.token),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/main_page.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'HTP 검사 - ${_stepsText[_step]}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: RepaintBoundary(
                            key: _globalKey,
                            child: Stack(
                              children: [
                                Container(
                                  color: Colors.white,
                                  child: GestureDetector(
                                    onPanUpdate: (details) {
                                      setState(() {
                                        RenderBox renderBox = context.findRenderObject() as RenderBox;
                                        Offset localPosition = renderBox.globalToLocal(details.localPosition);
                                        if (localPosition.dx > 0 &&
                                            localPosition.dx < renderBox.size.width &&
                                            localPosition.dy > 0 &&
                                            localPosition.dy < renderBox.size.height) {
                                          _points.add(DrawingPoints(
                                            points: localPosition,
                                            paint: Paint()
                                              ..color = _isErasing ? Colors.white : _color
                                              ..strokeCap = StrokeCap.round
                                              ..isAntiAlias = true
                                              ..strokeWidth = _isErasing ? _eraserSize : _brushSize,
                                          ));
                                        }
                                      });
                                    },
                                    onPanEnd: (details) {
                                      _points.add(DrawingPoints(
                                          points: Offset.zero,
                                          paint: Paint()..color = Colors.transparent));
                                    },
                                    child: CustomPaint(
                                      size: Size.infinite,
                                      painter: DrawingPainter(pointsList: _points),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("Brush Size: "),
                                  Expanded(
                                    child: Slider(
                                      value: _brushSize,
                                      min: 1.0,
                                      max: 20.0,
                                      onChanged: (value) {
                                        _changeBrushSize(value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Pen: "),
                                  IconButton(
                                    icon: Icon(Icons.create),
                                    onPressed: () {
                                      setState(() {
                                        _isErasing = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Color: "),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text("Select Color"),
                                          content: SingleChildScrollView(
                                            child: BlockPicker(
                                              pickerColor: _color,
                                              onColorChanged: (color) {
                                                _changeColor(color);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      color: _color,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Eraser Size: "),
                                  Expanded(
                                    child: Slider(
                                      value: _eraserSize,
                                      min: 1.0,
                                      max: 20.0,
                                      onChanged: (value) {
                                        _changeEraserSize(value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Eraser: "),
                                  IconButton(
                                    icon: Icon(Icons.brush),
                                    onPressed: _enableEraser,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _confirmCancel,
                        child: Text('취소'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _nextStep,
                        child: Text(_step < 2 ? '다음' : '진단'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(_result, style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoints> pointsList;

  DrawingPainter({required this.pointsList});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i].points != Offset.zero && pointsList[i + 1].points != Offset.zero) {
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points, pointsList[i].paint);
      } else if (pointsList[i].points != Offset.zero && pointsList[i + 1].points == Offset.zero) {
        canvas.drawPoints(ui.PointMode.points, [pointsList[i].points], pointsList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class DrawingPoints {
  Paint paint;
  Offset points;

  DrawingPoints({required this.points, required this.paint});
}

class HTPCustomDrawer extends StatelessWidget {
  final String token;

  HTPCustomDrawer({required this.token});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xff110f12),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _drawerItem(icon: Icons.home, text: 'Home', onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            }),
            _drawerItem(icon: Icons.person, text: 'Profile', onTap: () {
              Navigator.pushReplacementNamed(context, '/profile');
            }),
            _drawerItem(icon: Icons.settings, text: 'Settings', onTap: () {
              Navigator.pushReplacementNamed(context, '/settings');
            }),
            _drawerItem(icon: Icons.logout, text: 'Logout', onTap: () {
              AuthHelpers.logout(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({required IconData icon, required String text, required GestureTapCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
