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
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
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
              String paymentMethod = data['paymentMethod'] ?? '';
              String orderStatus = data['status'] ?? '';
              double barberBudPercentage =
                  originalTotal * 0.15; // 15% deduction for Cash
              if (paymentMethod == 'eWallet') {
                deductedTotal =
                    originalTotal * 0.85; // 15% deduction for eWallet
              }

              double latitude = data['latitude'] ?? 0.0;
              double longitude = data['longitude'] ?? 0.0;

              return InkWell(
                onLongPress: orderStatus == 'Completed'
                    ? null
                    : () async {
                        try {
                          final orderId = doc.id;

                          // Update the order status to 'Completed'
                          await FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId)
                              .update({'status': 'Completed'});

                          // If payment method is eWallet, update barber's eWallet balance
                          if (paymentMethod == 'eWallet') {
                            final barberEwalletRef = FirebaseFirestore.instance
                                .collection('Barbers')
                                .doc(currentUser.email)
                                .collection('ewallet');

                            final ewalletDocs =
                                await barberEwalletRef.limit(1).get();

                            if (ewalletDocs.docs.isNotEmpty) {
                              final ewalletDoc = ewalletDocs.docs.first;
                              final currentBalance =
                                  (ewalletDoc.data()['balance'] ?? 0)
                                      .toDouble();
                              final newBalance = currentBalance + deductedTotal;

                              await barberEwalletRef.doc(ewalletDoc.id).update({
                                'balance': newBalance,
                              });
                            } else {
                              // No existing eWallet doc -> Create one
                              await barberEwalletRef.add({
                                'balance': deductedTotal,
                              });
                            }
                              // Save transaction details to Firestore
                            await FirebaseFirestore.instance
                                .collection('Barbers')
                                .doc(currentUser.email)
                                .collection('transactions')
                                .add({
                              'amount': deductedTotal,
                              'total': originalTotal,
                              'orderId': orderId,
                              'isDeduction': 'No',
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                          } else if (paymentMethod == 'Cash') {
                            // Else for Cash Payment Method
                            final barberEwalletRef = FirebaseFirestore.instance
                                .collection('Barbers')
                                .doc(currentUser.email)
                                .collection('ewallet');

                            final ewalletDocs =
                                await barberEwalletRef.limit(1).get();

                            if (ewalletDocs.docs.isNotEmpty) {
                              final ewalletDoc = ewalletDocs.docs.first;
                              final currentBalance =
                                  (ewalletDoc.data()['balance'] ?? 0)
                                      .toDouble();

                              final newBalance =
                                  currentBalance - barberBudPercentage;

                              await barberEwalletRef.doc(ewalletDoc.id).update({
                                'balance': newBalance,
                              });
                            } else {
                              // No existing eWallet doc -> Create one
                              await barberEwalletRef.add({
                                'balance': deductedTotal,
                              });
                            }

                            // Save transaction details to Firestore
                            await FirebaseFirestore.instance
                                .collection('Barbers')
                                .doc(currentUser.email)
                                .collection('transactions')
                                .add({
                              'amount': barberBudPercentage,
                              'total': originalTotal,
                              'orderId': orderId,
                              'isDeduction': 'Yes',
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Order completed and eWallet updated!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                child: Card(
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
                          style: const TextStyle(
                              fontSize: 14, color: PrimaryColor),
                        ),
                        SizedBox(height: 8),
                        Text("Address: ${data['address'] ?? 'N/A'}",
                            style:
                                TextStyle(color: PrimaryColor, fontSize: 14)),
                        SizedBox(height: 8),
                        Text("Customer Number: ${userPhoneNumber}",
                            style:
                                TextStyle(color: PrimaryColor, fontSize: 14)),
                        SizedBox(height: 8),

                        // ✅ Collect Cash Red Color if paymentMethod == Cash
                        if (paymentMethod == 'Cash')
                          Text(
                            "Collect Cash from Customer",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                        // ✅ Display "Order Completed" if orderStatus == Completed
                        if (orderStatus == 'Completed')
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Order Completed",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),

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
                                padding: const EdgeInsets.all(12),
                              ),
                              onPressed: () => _makePhoneCall(userPhoneNumber),
                              child: const Icon(Icons.phone,
                                  size: 25, color: Colors.white),
                            ),
                            SizedBox(width: 8),
                            Container(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () =>
                                    _launchMaps(latitude, longitude),
                                child: const Icon(Icons.map,
                                    size: 25, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
