import 'package:barberbud_rider_project/auth/auth.dart';
import 'package:barberbud_rider_project/auth/login_Register_Page.dart';
import 'package:barberbud_rider_project/home.dart';
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges, // check if user is logged in or not
      builder: (context, snapshot) {
        // Check for loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(
            color: Colors.blueAccent,
          ));  // Show loading indicator while waiting
        }

        // Check for errors
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // If user data exists (user is logged in)
        if (snapshot.hasData) {
          return HomePage();
        }

        // If user is not logged in
        return LoginPage();
      },
    );
  }
}
