import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';

class EwalletPage extends StatefulWidget {
  @override
  State<EwalletPage> createState() =>
      _EwalletPageState(); // Create state for EwalletPage
}

class _EwalletPageState extends State<EwalletPage> {
  final currentUser = FirebaseAuth.instance.currentUser!; // Get current user

  final userCollection = FirebaseFirestore.instance
      .collection('Barbers'); // Reference to user collection

  // Function to handle top-up
  Future<void> editField() async {
    String newValue = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Enter Top-Up Amount',
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
        content: TextField(
          keyboardType: TextInputType.number,
          cursorColor: Colors.white,
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter Amount',
            hintStyle: TextStyle(color: Colors.grey),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyan),
            ),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue),
            child: Text('Top Up', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (newValue.trim().isNotEmpty) {
      double? amount = double.tryParse(newValue);
      if (amount != null && amount > 0) {
        QuerySnapshot walletSnapshot = await FirebaseFirestore.instance
            .collection('Barbers')
            .doc(currentUser.email)
            .collection('ewallet')
            .limit(1)
            .get();

        DocumentReference walletRef = walletSnapshot.docs.first.reference;

        FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot<Object?> snapshot = await transaction.get(walletRef);
          if (snapshot.exists) {
            double currentBalance = (snapshot['balance'] ?? 0).toDouble();
            double updatedBalance = currentBalance + amount;
            transaction.update(walletRef, {'balance': updatedBalance});
          }
        });
        // Save transaction details
        await userCollection
            .doc(currentUser.email)
            .collection('transactions')
            .add({
          'details': 'Top-up',
          'amount': amount,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  String qrCodeResult = "Not Yet Scanned";
  Future<void> scanQrCode() async {
    try {
      final qrcodeResult = await FlutterBarcodeScanner.scanBarcode(
        "#00FFFF",
        "Cancel",
        true,
        ScanMode.QR,
      );

      if (!mounted) return;

      setState(() {
        qrCodeResult = qrcodeResult;
      });

      if (qrcodeResult == "myapp://transfer") {
        _showTransferDialog();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $message"),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _showTransferDialog() async {
    String newValue = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Enter Transfer Amount',
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
        content: TextField(
          keyboardType: TextInputType.number,
          cursorColor: Colors.white,
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter Amount',
            hintStyle: TextStyle(color: Colors.grey),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyan),
            ),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              _transferBalance(newValue);
            },
            child: Text('Transfer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _transferBalance(String value) async {
    if (value.trim().isNotEmpty) {
      double? amount = double.tryParse(value);
      if (amount != null && amount > 0) {
        QuerySnapshot walletSnapshot = await FirebaseFirestore.instance
            .collection('Barbers')
            .doc(currentUser.email)
            .collection('ewallet')
            .limit(1)
            .get();

        DocumentReference walletRef = walletSnapshot.docs.first.reference;

        FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(walletRef);
          if (snapshot.exists) {
            double currentBalance = (snapshot['balance'] ?? 20).toDouble();
            double updatedBalance = currentBalance - amount;

            transaction.update(walletRef,
                {'balance': updatedBalance}); // try to fix this later
          }
        });

        await userCollection
            .doc(currentUser.email)
            .collection('transactions')
            .add({
          'details': 'QR Transfer',
          'amount': amount,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Transfer successful!',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance // set up stream to listen to wallet data
                .collection('Barbers')
                .doc(currentUser.email)
                .collection('ewallet')
                .limit(1)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Colors.cyanAccent,
            ));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading wallet data',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.docs.isNotEmpty) {
            // Check if wallet data is empty
            return Center(
              child: Text(
                'No wallet data found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Fetch user wallet data safely
          final userData =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;
          String balance = userData['balance']?.toStringAsFixed(1) ?? '0.00';

          return Wrap(
            direction: Axis.horizontal,
            runSpacing: 40,
            children: [
              Container(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Ewallet',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 27, color: Colors.white),
                ),
              ),
              Center(
                child: Wrap(
                  direction: Axis.vertical,
                  children: [
                    // Wallet Card
                    SizedBox(
                      width: 350,
                      height: 200,
                      child: Card(
                        color: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Wrap(
                          direction: Axis.vertical,
                          spacing: 15,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                'Balance',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 100),
                              child: Text(
                                "RM $balance", // Safely displaying balance
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
                              ),
                            ),
                            Theme(
                              data: Theme.of(context).copyWith(
                                iconTheme: IconThemeData(
                                    color: Colors.white, size: 30),
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  spacing: 60,
                                  children: [
                                    _buildActionButton(
                                        CupertinoIcons.add_circled,
                                        'Top Up',
                                        editField),
                                    _buildActionButton(
                                        Icons.call_received, 'Receive', () {
                                      Navigator.pushNamed(context, 'qrCode');
                                    }),
                                    _buildActionButton(Icons.qr_code, 'Scan',
                                        () {
                                      scanQrCode();
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Recent Transactions Card
                    SizedBox(
                      width: 350,
                      height: 330,
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  child: Row(
                                children: [
                                  Text(
                                    'Transactions',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18),
                                  ),
                              
                              
                                ],
                              )),
                              SizedBox(height: 10),
                              Expanded(
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('Barbers')
                                      .doc(currentUser.email)
                                      .collection('transactions')
                                      .orderBy('timestamp',
                                          descending: true) // Sort by latest
                                      
                                      .snapshots(),
                                  builder: (context, transactionSnapshot) {
                                    if (transactionSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator(
                                              color: Colors.cyanAccent));
                                    }

                                    if (transactionSnapshot.hasError) {
                                      return Center(
                                          child: Text(
                                              'Error loading transactions'));
                                    }

                                    if (!transactionSnapshot.hasData ||
                                        transactionSnapshot
                                            .data!.docs.isEmpty) {
                                      return Center(
                                          child:
                                              Text('No recent transactions'));
                                    }

                                    // Filter transactions to exclude those where paymentMethod is 'Cash'
                                    var filteredTransactions =
                                        transactionSnapshot.data!.docs
                                            .where((doc) {
                                      final transactionData =
                                          doc.data() as Map<String, dynamic>;
                                      return transactionData['paymentMethod'] !=
                                          'Cash';
                                    }).toList();

                                    if (filteredTransactions.isEmpty) {
                                      return Center(
                                          child: Text(
                                              'No recent transactions available'));
                                    }

                                    return ListView(
                                      children: filteredTransactions.map((doc) {
                                        final transactionData =
                                            doc.data() as Map<String, dynamic>;

                                        return ListTile(
                                          title: Text(
                                            transactionData['details'] ==
                                                    'Top-up'
                                                ? "Top-Up"
                                                : transactionData['details'] ==
                                                        'QR Transfer'
                                                    ? "QR Transfer"
                                                    : transactionData[
                                                                'details'] ==
                                                            'cancel'
                                                        ? "Cancel Refund"
                                                        : "Order ID: ${transactionData['orderId'] ?? 'N/A'}",
                                            style:
                                                TextStyle(color: Colors.black, fontSize: 14,),
                                          ),
                                          trailing: Text(
                                            transactionData['details'] ==
                                                    'Top-up'
                                                ? "+ RM ${transactionData['amount'].toString()}"
                                                : transactionData['details'] ==
                                                        'cancel'
                                                    ? "+ RM ${transactionData['amount'].toString()}"
                                                    : (transactionData[
                                                                    'orderId'] !=
                                                                null &&
                                                            transactionData[
                                                                    'isDeduction'] ==
                                                                'Yes')
                                                        ? "- RM ${transactionData['amount'].toString()}"
                                                        : "+ RM ${transactionData['amount'].toString()}",
                                            style: TextStyle(
                                              color: transactionData[
                                                          'details'] ==
                                                      'Top-up'
                                                  ? Colors.green
                                                  : transactionData[
                                                              'details'] ==
                                                          'cancel'
                                                      ? Colors
                                                          .green // Change color to green for "Cancelled"
                                                      : (transactionData[
                                                                      'orderId'] !=
                                                                  null &&
                                                              transactionData[
                                                                      'isDeduction'] ==
                                                                  'Yes')
                                                          ? Colors
                                                              .red // Red color for negative amounts with deduction
                                                          : Colors
                                                              .green, // Default to red for other cases
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper function to build icon buttons
  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
      ],
    );
  }
}
