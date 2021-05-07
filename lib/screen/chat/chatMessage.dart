// ignore: camel_case_types
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screen/chat/MessageManager.dart';
import 'package:toast/toast.dart';

// ignore: camel_case_types
class chatMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatMessage")
                  .orderBy("timestamp")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  Toast.show("Hata Var", context);
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView(

                  children: snapshot.data.docs.map((DocumentSnapshot document) {
                    return MessageManager(
                      document.data()["userEmail"],
                      document.data()["message"],
                      document.data()["messageType"],
                      document.data()["downloadLink"],
                      document.id
                    );
                  }).toList(),
                );
              },
            );

  }
}
