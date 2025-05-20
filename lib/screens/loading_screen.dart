import 'dart:async';
import 'package:flutter/material.dart';
import 'sign-up.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a loading process
    Timer(const Duration(seconds: 1), () { // Adjust time if needed
      // Navigate to the Sign-Up screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SignUpScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 94, 140), 
      body: Center(
        child: Image.asset(
          'assets/loading.png',
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}
