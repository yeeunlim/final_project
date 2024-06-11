import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/constants/image_urls.dart';

class LoadingScreen extends StatelessWidget {
  final bool isLoading;

  const LoadingScreen({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return const SizedBox.shrink();
    }
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Image.network(ImageUrls.loadingImage),
          ],
        ),
      ),
    );
  }
}
