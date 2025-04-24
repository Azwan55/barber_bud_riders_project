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

  int index = 0;
  final screens = [
    /* 
                        screens will show which page to go base on index on tapped
                        bottom navigation bar that link to body screen[index] 
                           */
    HomePageBody(),
    OrderTakenPage(),
    EwalletPage(),
    MissionPage(),
    ProfilePage(),
  ];

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
      ),
      body: screens[index],
      /*
                              the screen will take index that been put by set state
                              in bottom navigation bar and dispaly the screen[] base
                              on its index.
                            */
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(top: 15),
        child: Theme(
          //bottom navigation bar
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
