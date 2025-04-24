import 'dart:async';
import 'package:barberbud_rider_project/widgetTree.dart';
import 'package:flutter/material.dart';

class SplashScreenMain extends StatefulWidget {
  @override
  Splash createState() => Splash();
}

class Splash extends State<SplashScreenMain> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Timer(
        Duration(seconds: 2),
        () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => WidgetTree())));
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "asset/images/barber_bud_rider_logo.png",
              width: 350,
              
            ),
          ],
        ),
      ),
    );
  }
}
