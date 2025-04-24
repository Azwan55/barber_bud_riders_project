import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;
  var _isObscured;

  void initState() {
    super.initState();
    _isObscured = true;
    // Ensure the ewallet document exists for the current user
    checkAndCreateWalletDocument();
  }

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final userCollection = FirebaseFirestore.instance.collection('Barbers'); // Reference to user collection

  Future<void> checkAndCreateWalletDocument() async {
    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Check if currentUser is not null
    if (currentUser != null) {
      // Reference to the user's ewallet collection (assuming only one document in the collection)
      CollectionReference walletCollection = FirebaseFirestore.instance
          .collection('Barbers')
          .doc(currentUser.email)
          .collection('ewallet');

      // Get all documents in the ewallet collection
      QuerySnapshot snapshot = await walletCollection.get();

      // Check if any document exists
      if (snapshot.docs.isEmpty) {
        // No document found, create the first document with a default balance of 20
        await walletCollection.add({
          'balance': 20.0,
        });

        print('Wallet document created with default balance of 20');
      } else {
        print('Wallet document already exists');
      }
    } else {
      print('No user is logged in');
    }
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      //after creating user , create new document in cloud firestore called Barbers
      FirebaseFirestore.instance
          .collection('Barbers')
          .doc(userCredential.user!.email)
          .set({
        'username': _controllerEmail.text.split('@')[0],
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return Center(
      child: const Text(
        'Getting Started',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      style: TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
        labelStyle: const TextStyle(
          color: Colors.white,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.cyan),
        ),
      ),
    );
  }

  Widget _errorMessage() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Text(
        errorMessage == '' ? '' : ' $errorMessage',
        style: TextStyle(
          color: Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed:
          isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(
        isLogin ? 'Login' : 'Register',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin; // related to submit button function above
        });
      },
      child: Text(
        isLogin
            ? 'New User? Register instead'
            : 'Have Account Already? Login instead',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: _title(),
        backgroundColor: Colors.black,
      ),
      body: Form(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "asset/images/barber_bud_rider_logo.png",
                  width: 250,
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: _entryField('Email', _controllerEmail),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    controller: _controllerPassword,
                    obscureText: _isObscured,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscured
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                _errorMessage(),
                _submitButton(),
                _loginOrRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
