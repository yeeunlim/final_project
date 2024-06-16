import 'package:flutter/material.dart';
import 'htp_second_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mindcare_flutter/presentation/widgets/custom_drawer.dart';
import 'package:mindcare_flutter/presentation/widgets/custom_app_bar.dart';
import 'package:mindcare_flutter/presentation/widgets/common_button.dart';
import 'package:mindcare_flutter/core/constants/colors.dart';
import 'package:mindcare_flutter/core/constants/urls.dart';

class HTPMainPage extends StatefulWidget {
  final String token;

  const HTPMainPage({Key? key, required this.token}) : super(key: key);
  
  @override
  _HTPTestResultsState createState() => _HTPTestResultsState(token: token);
} 

class _HTPTestResultsState extends State<HTPMainPage> {
  final String token;

  _HTPTestResultsState({required this.token});

  List<dynamic> testResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTestResults();
  }

  Future<void> _fetchTestResults() async {
    final response = await http.get(
      Uri.parse('$htpTestUrl/results/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        testResults = json.decode(utf8.decode(response.bodyBytes));
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showResultDialog(dynamic result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // 검사 항목에 따른 결과 제목 설정
        String resultTitle;
        switch (result['type']) {
          case 'person':
            resultTitle = '사람 그림 검사 결과';
            break;
          case 'house':
            resultTitle = '집 그림 검사 결과';
            break;
          case 'tree':
            resultTitle = '나무 그림 검사 결과';
            break;
          default:
            resultTitle = '그림 검사 결과';
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // 좌측 이미지 박스
                Expanded(
                  flex: 1,
                  child: Container(
                    height: double.infinity,
                    color: Colors.white,
                    child: result['result_image_url'] != null
                      ? Image.network(result['result_image_url'], fit: BoxFit.contain)
                      : Container(),
                  ),
                ),
                SizedBox(width: 16),
                // 우측 텍스트 박스
                Expanded(
                  flex: 1,
                  child: Container(
                    height: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    color: Colors.grey[200],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resultTitle,
                          style: const TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                result['result'],
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: Text('닫기', style: TextStyle(color: primaryColor)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('삭제', style: TextStyle(color: primaryColor)), // 버튼 텍스트 색깔 설정
                              onPressed: () async {
                                final response = await http.delete(
                                  Uri.parse('$htpTestUrl/results/${result['id']}/'),
                                  headers: {'Authorization': 'Bearer $token'},
                                );
                                if (response.statusCode == 204) {
                                  setState(() {
                                    testResults.remove(result);
                                  });
                                  Navigator.of(context).pop();
                                } else {
                                  // 오류 처리
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteResult(int id) async {
    final response = await http.delete(
      Uri.parse('$htpTestUrl/results/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      setState(() {
        testResults.removeWhere((result) => result['id'] == id);
      });
    } else {
      // Handle error
    }
  }

  // HTP 검사 결과 리스트 불러오기
  Widget _buildTestSection(String type, String title) {
    List<dynamic> filteredResults = testResults.where((result) => result['type'] == type).toList();
  
    return ExpansionTile(
      title: Text(title),
      children: filteredResults.map((result) {
        return GestureDetector(
          onTap: () => _showResultDialog(result),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            child: ListTile(
              title: Text('검사 [${result['created_at'].split('T')[0]}]'),
              subtitle: Text('검사항목: ${result['type']}'),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 너비와 높이를 감지합니다.
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 특정 크기 이하일 때 버튼과 이미지를 숨깁니다.
    final isScreenSmall = screenWidth < 550 || screenHeight < 300;

    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: CustomDrawer(token: token),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(ImageUrls.mainPageBackground),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              width: screenWidth * 0.8,
              height: screenHeight * 0.8,
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: screenHeight * 0.8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300, width: 0.5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(
                                      ImageUrls.normalRabbit,
                                      width: 70,
                                      height: 70,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            'HTP 검사란?',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Flexible(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '\nHTP(House, Tree, Person) 검사'
                                          '\n벅(Buck, 1948)이 고안한 투사적 그림검사로서 집, 나무, 사람을 각각 그리게 하여 '
                                          '내담자의 성격, 행동 양식 및 대인관계를 파악할 수 있습니다. 피험자의 성격적 특징뿐만 아니라 지적 수준을 평가하고 '
                                          '또한 정신장애 및 신경증의 부분적 양상을 파악하는데 널리 사용되기도 합니다.'
                                          '\n\n집은 자기 지각, 가정생활의 질, 또는 가족 내에서의 자신에 대한 지각을 반영합니다.'
                                          '\n\n나무는 수많은 기억으로부터 가장 감정 이입적으로 동일시했던 나무를 선택하여'
                                          '그리게 됩니다. 자기 자신에 대한 무의식적이고 원시적인 자아 개념의 투사와 관련이 있습니다.'
                                          '\n\n사람은 집이나 나무보다 더 직접적으로 자기상을 나타냅니다. 사람 그림은 자화상이 될 수도'
                                          '있고, 이상적 자아, 중요한 타인, 혹은 인간을 어떻게 인지하고 있느지를 나타내기도 합니다.'
                                          '\n\n이곳에서 하는 HTP검사는 한계가 있기에 크게 의미를 두지 말고 가볍게 생각하시고'
                                          '\n본격적인 진단을 원하신다면 전문적인 심리상담사를 찾아가 제대로 검사를'
                                          '받으시는 것을 추천드립니다.',
                                          style: TextStyle(fontSize: 17),
                                        ),
                                        const SizedBox(height: 40),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, width: 0.5),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (testResults.isEmpty)
                              const Text(
                                '검사 기록이 없습니다.',
                                style: TextStyle(fontSize: 18),
                              )
                            else
                              const Text(
                                ' ▶ HTP 검사 리스트',
                                style: TextStyle(fontSize: 18),
                              ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: isLoading
                                  ? const Center(child: Text('로딩 중'))
                                  : ListView(
                                      children: [
                                        _buildTestSection('house', 'House'),
                                        _buildTestSection('tree', 'Tree'),
                                        _buildTestSection('person', 'Person'),
                                      ],
                                    ),
                            ),
                            if (!isScreenSmall) ...[
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    ImageUrls.normalRabbit,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(width: 10),
                                  Flexible(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: 100, // 버튼의 최소 너비
                                        maxWidth: 200, // 버튼의 최대 너비
                                      ),
                                      child: CommonButton(
                                        text: '다음',
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => HTPSecondPage(token: widget.token)),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

