import 'dart:io';

import 'package:camera_camera/camera_camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_app/utils/Constant.dart';
class UserProfile extends StatefulWidget {
  const UserProfile({Key key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  TextEditingController _controllerUserName = new TextEditingController();
  TextEditingController _controllerUserDescription = new TextEditingController();
  File _file;
  final _updateUserName = false;
  final _updateUserDescription = false;

  openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CameraCamera(
            onFile: (file) async {
              setState(() {
                _file = file;
              });

              try {
                var link;
                var reference = await firebase_storage.FirebaseStorage.instance
                    .ref()
                    .child("/uploads/image/" + _file.path);
                var storage = await reference.putFile(new File(_file.path));
                var referenceNetwork = await reference
                    .getDownloadURL()
                    .then((value) => link = value);

                var collection =
                FirebaseFirestore.instance.collection("chatMessage");
                collection.add({
                  "timestamp": Timestamp.now(),
                  "userEmail": FirebaseAuth.instance.currentUser.email,
                  "messageType": "userImage",
                  "imageUrl": reference.fullPath,
                  "downloadLink": link,
                });
              } catch (e) {
                print("Hata VARRRRRRRRRRRRRRRRRRRRRRRRRrr");
              }

              setState(() {
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          color: Colors.cyan.shade700,
          child: ListView(
              children: [
                Container(
                  height: 180,
                  width: 180,
                  margin: EdgeInsets.only(top: 40,left: 90,right: 90),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage("images/suat.jpg"),
                    ),
                    border: Border.all(width: 2, color: Colors.amber),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.lightGreen.shade700,
                          ),
                          child: Icon(Icons.add,color: Colors.white,),
                        ),
                        bottom: 0,
                        right: 0,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                userNameEdit(_controllerUserName),
                SizedBox(height: 30,),
                userDescriptionEdit(context, _controllerUserDescription),
                SizedBox(height: 30,),
                GestureDetector(
                  onTap: (){
                    print("Güncellendi");
                  },
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 20,),
                    child: Center(child: Text("Güncelle",style: TextStyle(fontSize: 18,color: Colors.white,letterSpacing: 1.0 ),),),
                    decoration: BoxDecoration(
                      color: Colors.lightGreen.shade700,
                      borderRadius: BorderRadius.circular(10,),
                      border: Border.all(
                        color: Colors.amber,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}
