import 'dart:typed_data';
import 'package:barberbud_rider_project/auth/auth.dart';
import 'package:barberbud_rider_project/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Uint8List? _image;

  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userCollection = FirebaseFirestore.instance.collection('Barbers');

  //edit field
  void Function()? onPressed;

  pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      return await _file.readAsBytes();
    }

    print('No image selected.');
  }

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Edit Username',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        content: TextField(
          cursorColor: Colors.white,
          autofocus: true,
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Enter new username',
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyan),
            ),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          //cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),

          //save button

          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue),
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
    //update in firestore
    if (newValue.trim().length > 0) {
      //only update if there something in textfield
      await userCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() => _image = img);
    _image = img;
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Barbers")
            .doc(currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          // get user data
          if (snapshot.hasData) {
            final userData =
                snapshot.data?.data() as Map<String, dynamic>? ?? {};

            return Wrap(
              direction:
                  Axis.vertical, //set direction to vertical(up and down),
              spacing: 40, //space between widget

              children: [
                Container(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    textAlign: TextAlign.left,
                    'Profile',
                    style: const TextStyle(
                      fontSize: 27,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              backgroundImage: MemoryImage(_image!),
                              maxRadius: 50,
                              minRadius: 40,
                            )
                          : Stack(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      AssetImage("asset/images/sea image.png"),
                                  maxRadius: 50,
                                  minRadius: 40,
                                ),
                                Positioned(
                                  child: IconButton(
                                    onPressed: selectImage,
                                    icon: Icon(
                                      Icons.add_a_photo,
                                      color: Colors.grey,
                                      size: 35,
                                    ),
                                  ),
                                  bottom: -10,
                                  left: 60,
                                ),
                              ],
                            ),
                      SizedBox(width: 20),
                      Wrap(
                        direction: Axis.vertical,
                        children: [
                          Row(
                            children: [
                              Text(
                                userData['username'] ?? 'No username',
                                style: TextStyle(
                                  color: SecondaryColor,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(width: 10),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                onPressed: () => editField('username'),
                              ),
                            ],
                          ),
                          Text(
                            currentUser.email!,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, top: 20),
                  child: Wrap(
                    direction: Axis.vertical,
                    spacing: 20,
                    children: [
                      InkWell(
                        child: Text(
                          textAlign: TextAlign.left,
                          'Change Password',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () async {
                          String newPassword = "";
                          String confirmPassword = "";
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.grey[900],
                              title: Text(
                                'Change Password',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    cursorColor: Colors.white,
                                    autofocus: true,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Enter new password',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.cyan),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      newPassword = value;
                                    },
                                    obscureText: true,
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    cursorColor: Colors.white,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Confirm new password',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.cyan),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      confirmPassword = value;
                                    },
                                    obscureText: true,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (newPassword.length >= 6 && newPassword == confirmPassword) {
                                      try {
                                        await currentUser.updatePassword(newPassword);
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Password changed successfully!'),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                              'Error: ${e.toString()}',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        );
                                      }
                                    } else if (newPassword != confirmPassword) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            'Passwords do not match!',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            'Password must be at least 6 characters!',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text('Save', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      InkWell(
                        child: Text(
                          textAlign: TextAlign.left,
                          'About Barber Bud',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, 'aboutBarberBud');
                        },
                      ),
                      Spacer(),
                      InkWell(
                        child: SizedBox(
                          width: 350,
                          height: 50,
                          child: Card(
                            color: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Center(
                              child: Text(
                                'Log Out',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          signOut();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          return Center(
            child: CircularProgressIndicator(
              color: Colors.cyanAccent,
            ),
          );
        },
      ),
    );
  }
}
