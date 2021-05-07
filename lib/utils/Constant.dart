import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
// Container Decoration

final meDecoration = BoxDecoration(
  color: Colors.orange.shade100,
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(10),
    bottomRight: Radius.circular(10),
    topRight: Radius.circular(10),
    bottomLeft: Radius.circular(0),
  ),
);
final otherDecoration = BoxDecoration(
  color: Colors.grey,
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(10),
    topRight: Radius.circular(10),
    bottomRight: Radius.circular(0),
    bottomLeft: Radius.circular(10),
  ),
);

// Shared Preferences

const ImageKey = "image_key";

// Document Alert Dialog

dialog(BuildContext context, String title, id, int chatType, {String url}) {
  return AlertDialog(
    title: Text(title),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("Hayır"),
      ),
      TextButton(
        onPressed: () async {
          switch (chatType) {
            case 0:
              await FirebaseFirestore.instance
                  .collection("chatMessage")
                  .doc(id)
                  .delete();
              Navigator.of(context).pop();
              break;
            case 1:
              await FirebaseFirestore.instance
                  .collection("chatMessage")
                  .doc(id)
                  .delete();

              // Storage url Regex
              var fileUrl = Uri.decodeFull(path.basename(url)).replaceAll(new RegExp(r'(\?alt).*'), '');

              await firebase_storage.FirebaseStorage.instance
                  .ref()
                  .child(fileUrl)
                  .delete()
                  .then(
                    (value) {
                        print("Silindi");
                    },
                  );
              Navigator.of(context).pop();
              break;
          }
        },
        child: Text("Evet"),
      ),
    ],
  );
}


// USER CONSTANT

const UserNameKey = "user_name_key";
const UserDescriptionKey = "user_description_key";
const UserImageKey = "user_image_key";
const UserToken = "user_token";


Widget userNameEdit(TextEditingController _controllerUserName) {
  return Container(

    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10,),
      color: Colors.white,
      border: Border.all(color: Colors.amber,width: 2.0,),
    ),
    margin: EdgeInsets.symmetric(horizontal: 20,),
    child: TextFormField(
      autofocus: true,
      cursorColor: Colors.red,
      controller: _controllerUserName,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.all(6),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
              )),
          labelStyle: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
          hintText: "Write Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          )),
    ),
  );
}

Widget userDescriptionEdit(BuildContext context,TextEditingController _controllerUserDescription) {
  return Container(
    padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10,),
      color: Colors.white,
      border: Border.all(color: Colors.amber,width: 2.0,),
    ),
    margin: EdgeInsets.symmetric(horizontal: 20,),
    child: TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: 5,
      cursorColor: Colors.red,
      controller: _controllerUserDescription,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.all(6),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
              )),
          labelStyle: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
          hintText: "Write User Bio",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          )),
    ),
  );
}