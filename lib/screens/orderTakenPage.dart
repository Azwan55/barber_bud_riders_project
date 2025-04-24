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
      appBar: AppBar(
        title: Text('Order Taken'),
      ),
      body: Center(
        child: Text(
          'Your order has been taken!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}