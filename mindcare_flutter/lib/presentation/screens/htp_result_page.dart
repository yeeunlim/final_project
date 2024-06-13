import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class ResultPage extends StatelessWidget {
  final String token;
  final List<String> drawingIds;
  final List<Map<String, dynamic>> results;

  ResultPage({required this.token, required this.drawingIds, required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            var result = results[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type: ${result['type']}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('Result: ${result['result']}'),
                    SizedBox(height: 10),
                    result['result_image_url'] != null
                        ? Image.network(result['result_image_url'])
                        : Container(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
