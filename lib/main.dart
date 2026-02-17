import 'package:flutter/material.dart';
import 'constants.dart';
import 'views/splash.dart';

void main() {
  runApp(const ConnectWorkApp());
}

class ConnectWorkApp extends StatelessWidget {
  const ConnectWorkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConnectWork',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Splash(),
    );
  }
}