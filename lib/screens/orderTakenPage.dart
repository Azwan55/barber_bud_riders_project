import 'package:barberbud_rider_project/resources/constant.dart';
import 'package:flutter/material.dart';

class OrderTakenPage extends StatefulWidget {
  const OrderTakenPage({super.key});

  @override
  State<OrderTakenPage> createState() => _OrderTakenPageState();
}

class _OrderTakenPageState extends State<OrderTakenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrimaryColor,
      
      body: Center(
        
        child: Text(
          'Your are not taken any order yet',
          style: TextStyle(fontSize: 18, color: SecondaryColor),
        ),
      ),
    );
  }
}