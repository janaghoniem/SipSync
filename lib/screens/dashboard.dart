import 'package:flutter/material.dart';
import '../user-data.dart';

class UserDashboard extends StatelessWidget {
  final User user;

  const UserDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome, ${user.name}!")),
      body: Center(child: Text("This is your dashboard.")),
    );
  }
}
