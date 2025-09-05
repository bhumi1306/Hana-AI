import 'package:flutter/material.dart';
import 'package:hana_ai/UI/get_started.dart';

import 'Utility/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          onPrimary: AppColors.white,
          onSecondary: AppColors.black,
          primaryContainer: AppColors.shade1,
          secondaryContainer: AppColors.shade2,
          tertiaryContainer: AppColors.shade3,
        ),
        textTheme: const TextTheme(
        ),
      ),
      home: const GetStarted(),
    );
  }
}
