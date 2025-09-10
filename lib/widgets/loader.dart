import 'package:flutter/material.dart';

class LoadingHelper extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;

  // Constructor to pass screen height and width
  const LoadingHelper({super.key, required this.screenHeight, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: screenWidth,
          height: screenHeight,
          color: Colors.black.withOpacity(0.5), // Grey transparent background
        ),
        Center(
          child: Image.asset('assets/images/loader.gif',
          width: screenWidth * 0.7,
          ),
        ),
      ],
    );
  }
}
