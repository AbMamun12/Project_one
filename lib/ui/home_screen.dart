import 'package:flutter/material.dart';
import 'package:mvc/widget/app_bar.dart'; // তোমার TMAppBar এখানে আছে

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TMAppBar(), // 🔹 AppBar-এ নাম + ইমেইল দেখাবে
      body: const Center(
        child: Text(
          "Welcome to Home Screen!",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
