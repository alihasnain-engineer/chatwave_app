import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const ChatWave());
}

class ChatWave extends StatelessWidget {
  const ChatWave({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
