import 'package:barberbud_rider_project/resources/constant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  List<Map<String, dynamic>> allOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }


Future<void> _checkLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
  }
}

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

  // Function to filter orders where orderTaken == "Not yet"
  List<Map<String, dynamic>> filterOrders(List<Map<String, dynamic>> orders) {
    return orders.where((order) => order['orderTaken'] == 'Not yet').toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text("No orders yet",
                  style: TextStyle(color: SecondaryColor)));
        }

        final allOrders = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data;
        }).toList();

        // Filter the orders to display only those with orderTaken == "Not yet"
        final filteredOrders = filterOrders(allOrders);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            double originalTotal =
                double.tryParse(order['total']?.toString() ?? '0') ?? 0;
            double deductedTotal = originalTotal;
            // only deduct on eWallet because barber need to collect full cash
            // and Barber Bud will deduct their percentage after order completed
            if (order['paymentMethod'] == 'eWallet') {
              deductedTotal = originalTotal * 0.85; // 15% deduction for eWallet
            }

            String address = order['address'] ?? 'N/A';
            String userPhoneNumber = order['userPhoneNumber'] ?? 'N/A';
            double latitude = order['latitude'] ?? 0.0;
            double longitude = order['longitude'] ?? 0.0;

            return InkWell(
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: SecondaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: ${order['id'] ?? 'N/A'}',
                        style: const TextStyle(
                            fontSize: 16,
                            color: PrimaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Items: ${(order['items'] as List<dynamic>).map((item) => '${item['name']} (x${item['qty']})').join(', ')}',
                        style:
                            const TextStyle(fontSize: 14, color: PrimaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text('Address: $address',
                          style: const TextStyle(
                              fontSize: 14, color: PrimaryColor)),
                      Text('Customer Number: $userPhoneNumber',
                          style: const TextStyle(
                              fontSize: 14, color: PrimaryColor)),

                      // Display "Collect Cash" if user pays with cash
                      if (order['paymentMethod'] == 'Cash')
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Collect Cash',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold),
                          ),
                        ),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Total: RM ${deductedTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 24, color: Colors.green),
                          ),
                          const Spacer(),
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
                              child: const Icon(Icons.map, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              onLongPress: () async {
                final orderId = order['id'];
                final docRef = FirebaseFirestore.instance
                    .collection('orders')
                    .doc(orderId);

                await docRef.update({'orderTaken': 'Yes'});

                Geolocator.getPositionStream(
                  locationSettings: const LocationSettings(
                    accuracy: LocationAccuracy.high,
                    distanceFilter: 10,
                  ),
                ).listen((Position position) async {
                  await docRef.update({
                    'barberLatitude': position.latitude,
                    'barberLongitude': position.longitude,
                    'lastUpdated': Timestamp.now(),
                  });
                });
              },
            );
          },
        );
      },
    );
  }
}
