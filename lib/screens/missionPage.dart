import 'package:flutter/material.dart';

class MissionPage extends StatefulWidget {
  const MissionPage({super.key});

  @override
  State<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends State<MissionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mission Page'),
      ),
      body: Center(
        child: Text(
          'This is the mission page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}