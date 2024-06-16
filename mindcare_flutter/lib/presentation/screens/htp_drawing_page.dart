import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:mindcare_flutter/core/services/drawing_provider.dart';
import 'package:mindcare_flutter/core/constants/colors.dart';
import 'package:mindcare_flutter/core/constants/urls.dart';
import 'package:mindcare_flutter/presentation/widgets/alert_dialog.dart';
import '../../core/services/api_service.dart';
import 'chatbot_diary_entry_screen.dart';
import 'htp_result_page.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_app_bar.dart';

class HTPDrawingPage extends StatefulWidget {
  final String token;

  const HTPDrawingPage({super.key, required this.token});

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
  List<String> _drawingIds = [];
  double _devicePixelRatio = 1.0;

  final List<String> _stepsText = [
    "집을 그려주세요",
    "나무를 그려주세요",
    "사람을 그려주세요"
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    });
  }

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
      await Future.delayed(const Duration(milliseconds: 100));
      final boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();
      final base64Image = base64Encode(buffer);

      var response = await ApiService.sendAuthenticatedRequest(
        context,
        '$htpTestUrl/upload_drawing/',
        'POST',
        body: {
          'image': base64Image,
          'type': _stepsText[_step],
        },
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final drawingProvider = Provider.of<DrawingProvider>(context, listen: false);

        final oldDrawing = drawingProvider.getDrawing(_step);
        if (oldDrawing.id != null) {
          _drawingIds.remove(oldDrawing.id.toString());
        }

        _drawingIds.add(responseData['id'].toString());

        setState(() {});

        drawingProvider.saveDrawing(_step, DrawingData(id: responseData['id'], points: _points));
      }
    } catch (e) {
      // Error handling
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
    HTPAlertDialogHelper.showLoadingDialog(context, '진단 중입니다...');

    var response = await ApiService.sendAuthenticatedRequest(
      context,
      '$htpTestUrl/finalize_diagnosis/',
      'POST',
      body: {
        'drawingIds': _drawingIds,
      },
    );
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(jsonDecode(response.body));
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
        // Error handling
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
        return Dialog(
          backgroundColor: primaryColor,
          child: Container(
            width: 300,
            height: 150,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: primaryColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'HTP 검사를 종료하시겠습니까?',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const ChatbotDiaryEntryScreen()),
                              (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text('종료', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 8.0),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('취소', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: primaryColor,
        child: Container(
          width: 300,
          height: 180,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: primaryColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '그림이 지워집니다',
                style: const TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                '뒤로 가면 현재 그린 그림이 모두 지워집니다. 그래도 이동하시겠습니까?',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('취소', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 8.0),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('확인', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final drawingProvider = Provider.of<DrawingProvider>(context);
    final double fixedSize = 700.0;
    final bool isScreenSmall = MediaQuery.of(context).size.width < 600 || MediaQuery.of(context).size.height < 600;

    return WillPopScope(
      onWillPop: () async {
        if (_step > 0) {
          final shouldExit = await _showExitConfirmationDialog();
          if (shouldExit) {
            setState(() {
              _step--;
              _points = drawingProvider.getDrawing(_step).points;
            });
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: const CustomAppBar(),
        drawer: CustomDrawer(token: widget.token),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < fixedSize || constraints.maxHeight < fixedSize) {
              return Center(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(ImageUrls.mainPageBackground),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        ImageUrls.sadRabbit,
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '그림을 그리기에 캔버스 크기가 너무 작습니다. \n정확한 진단을 위해 화면(해상도 700x700이상)을 조정해주세요.',
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(ImageUrls.mainPageBackground),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Container(
                  width: fixedSize,
                  height: fixedSize,
                  padding: const EdgeInsets.all(16.0),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            'HTP 검사 - ${_stepsText[_step]}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                                      width: fixedSize,
                                      height: fixedSize,
                                      color: Colors.white,
                                      child: GestureDetector(
                                        onPanStart: (details) {
                                          setState(() {
                                            RenderBox renderBox = _globalKey.currentContext!.findRenderObject() as RenderBox;
                                            Offset localPosition = renderBox.globalToLocal(details.globalPosition);

                                            _points.add(DrawingPoints(
                                              points: localPosition,
                                              paint: Paint()
                                                ..color = _isErasing ? Colors.white : _color
                                                ..strokeCap = StrokeCap.round
                                                ..isAntiAlias = true
                                                ..strokeWidth = _isErasing ? _eraserSize : _brushSize,
                                            ));
                                          });
                                        },
                                        onPanUpdate: (details) {
                                          setState(() {
                                            RenderBox renderBox = _globalKey.currentContext!.findRenderObject() as RenderBox;
                                            Offset localPosition = renderBox.globalToLocal(details.globalPosition);

                                            if (localPosition.dx >= 0 &&
                                                localPosition.dx <= renderBox.size.width &&
                                                localPosition.dy >= 0 &&
                                                localPosition.dy <= renderBox.size.height) {
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
                                          setState(() {
                                            _points.add(DrawingPoints(
                                              points: Offset.infinite,
                                              paint: Paint()..color = Colors.transparent,
                                            ));
                                          });
                                        },
                                        child: CustomPaint(
                                          size: Size(fixedSize, fixedSize),
                                          painter: DrawingPainter(pointsList: _points),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!isScreenSmall)
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text("Pen: "),
                                          IconButton(
                                            icon: const Icon(Icons.create),
                                            onPressed: () {
                                              setState(() {
                                                _isErasing = false;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      Slider(
                                        value: _brushSize,
                                        min: 1.0,
                                        max: 20.0,
                                        onChanged: (value) {
                                          _changeBrushSize(value);
                                        },
                                      ),
                                      Row(
                                        children: [
                                          const Text("Color: "),
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text("Select Color"),
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
                                              margin: const EdgeInsets.only(bottom: 16.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text("Eraser: "),
                                          IconButton(
                                            icon: const Icon(Icons.brush),
                                            onPressed: _enableEraser,
                                          ),
                                        ],
                                      ),
                                      Slider(
                                        value: _eraserSize,
                                        min: 5.0,
                                        max: 25.0,
                                        onChanged: (value) {
                                          _changeEraserSize(value);
                                        },
                                      ),
                                    ],
                                  ),
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('취소'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: secondaryColor,
                            ),
                            child: Text(_step < 2 ? '다음' : '진단'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
      if (pointsList[i].points != Offset.infinite && pointsList[i + 1].points != Offset.infinite) {
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points, pointsList[i].paint);
      } else if (pointsList[i].points != Offset.infinite && pointsList[i + 1].points == Offset.infinite) {
        canvas.drawPoints(ui.PointMode.points, [pointsList[i].points], pointsList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
