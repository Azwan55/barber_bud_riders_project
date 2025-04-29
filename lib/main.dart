import 'package:barberbud_rider_project/screens/qrCodeScreen.dart';
import 'package:barberbud_rider_project/screens/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //initialize the app
  await Firebase.initializeApp(); //initialize firebase
  runApp(MyApp()); //run the app
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => SplashScreenMain(),
        "qrCode": (context) => QrCodeScreen(),
      },
    );
  }
}
