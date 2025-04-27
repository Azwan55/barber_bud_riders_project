import 'package:barberbud_rider_project/resources/constant.dart';
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
      backgroundColor: PrimaryColor,
    
      body: Center(
        child: Text(
          'There is no mission yet',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}