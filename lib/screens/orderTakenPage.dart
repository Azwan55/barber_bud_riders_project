import 'package:barberbud_rider_project/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderTakenPage extends StatefulWidget {
  const OrderTakenPage({super.key});

  @override
  State<OrderTakenPage> createState() => _OrderTakenPageState();
}

class _OrderTakenPageState extends State<OrderTakenPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  // Function to launch Google Maps
  void _launchMaps(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Function to make a phone call
  // Phone number is pass at widget build
  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrimaryColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('barberEmail', isEqualTo: currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: SecondaryColor));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'You have not taken any orders yet.',
                style: TextStyle(fontSize: 18, color: SecondaryColor),
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.all(12),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              double originalTotal =
              double.tryParse(data['total']?.toString() ?? '0') ?? 0;
              double deductedTotal = originalTotal;

              String userPhoneNumber = data['userPhoneNumber'] ?? 'N/A';
              // only deduct on eWallet because barber need to collect full cash
              // and Barber Bud will deduct their percentage after order completed
              if (data['paymentMethod'] == 'eWallet') {
                deductedTotal =
                    originalTotal * 0.85; // 15% deduction for eWallet
              }

              double latitude = data['latitude'] ?? 0.0;
              double longitude = data['longitude'] ?? 0.0;
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                color: SecondaryColor.withOpacity(0.9),
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Order ID: ${doc.id}",
                          style: TextStyle(
                              color: PrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      SizedBox(height: 8),
                      Text(
                        'Items: ${(data['items'] as List<dynamic>).map((item) => '${item['name']} (x${item['qty']})').join(', ')}',
                        style:
                            const TextStyle(fontSize: 14, color: PrimaryColor),
                      ),
                      SizedBox(height: 8),
                      Text("Address: ${data['address'] ?? 'N/A'}",
                          style: TextStyle(color: PrimaryColor, fontSize: 14)),
                      SizedBox(height: 8),
                      Text(
                          "Customer Number: ${data['userPhoneNumber'] ?? 'N/A'}",
                          style: TextStyle(color: PrimaryColor, fontSize: 14)),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Total: RM ${deductedTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.green),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(
                                  12), // Makes it nicely sized
                            ),
                            onPressed: () => _makePhoneCall(
                                userPhoneNumber), // pass phone number to the function
                            child: const Icon(Icons.phone,
                                size: 25, color: Colors.white),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Container(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => _launchMaps(latitude, longitude),
                              child: const Icon(Icons.map,
                                  size: 25, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
