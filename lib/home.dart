import 'package:barberbud_rider_project/auth/auth.dart';
import 'package:barberbud_rider_project/resources/constant.dart';
import 'package:barberbud_rider_project/screens/EwalletPage.dart';
import 'package:barberbud_rider_project/screens/homePageBody.dart';
import 'package:barberbud_rider_project/screens/missionPage.dart';
import 'package:barberbud_rider_project/screens/orderTakenPage.dart';
import 'package:barberbud_rider_project/screens/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? get user => Auth().currentUser;
  bool showOrders = true;

  int index = 0;

  @override
  void initState() {
    super.initState();
  }

  final items = <Widget>[
    //Icon widget for bottom navigation bar
    Icon(Icons.home, size: 40),
    Icon(Icons.list_alt, size: 40),
    Icon(Icons.account_balance_wallet, size: 40),
    Icon(Icons.stars, size: 40),
    Icon(Icons.person, size: 40),
  ];

  @override
  Widget build(
    BuildContext context,
  ) {
    
    return Scaffold(
      backgroundColor: PrimaryColor,
      appBar: AppBar(
        backgroundColor: PrimaryColor,
        centerTitle: true,
        title: Text(
          'Barber Bud Rider',
          style: TextStyle(
            color: SecondaryColor,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Switch(
              inactiveTrackColor: SecondaryColor,
              activeTrackColor: Colors.blueAccent,
              value: showOrders,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  showOrders = value;
                });
              },
            ),
          ),
        ],
      ),

      /* the screen will take index that been put by set state
          in bottom navigation bar and dispaly the screen[] base
           on its index.*/
      body: IndexedStack( /* indexstack is used to preserve state
                            of the page even not visible making loading the page more efficient.*/
        index: index,
        children: [
          showOrders
              ? const HomePageBody()
              : const Center(
                  child: Text(
                    'Start taking order now',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
          OrderTakenPage(),
          EwalletPage(),
          MissionPage(),
          ProfilePage(),
        ],
      ),

     // // This is the bottom navigation bar that will be displayed at the bottom of the screen.
      bottomNavigationBar: Padding(   
        padding: EdgeInsets.only(top: 15),
        child: Theme(
          
          data: Theme.of(context).copyWith(
            iconTheme: IconThemeData(color: Colors.black),
          ),
          child: CurvedNavigationBar(
            backgroundColor: Colors.transparent,
            buttonBackgroundColor: Colors.blueAccent,
            color: const Color.fromARGB(255, 240, 239, 239),
            items: items,
            animationCurve: Curves.easeInOut,
            animationDuration: Duration(milliseconds: 300),
            height: 60,
            index: index,
            onTap: (index) {
              setState(() {
                //set current index as index for screens[] to use.
                this.index = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
