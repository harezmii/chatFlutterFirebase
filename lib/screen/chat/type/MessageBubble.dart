import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/Constant.dart';

// ignore: must_be_immutable
class MessageBubble extends StatelessWidget {
  String _userEmail;
  String _message;
  String _id;

  MessageBubble(this._userEmail, this._message, this._id);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
           return  dialog(context, "Silmek istiyor musunuz?", this._id,0);
          },
        );
      },
      child: Column(
        crossAxisAlignment:
            FirebaseAuth.instance.currentUser.email == _userEmail
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
        children: [
          Container(
            margin: FirebaseAuth.instance.currentUser.email == _userEmail
                ? EdgeInsets.only(
                    left: 10,
                    top: 10,
                  )
                : EdgeInsets.only(
                    top: 10,
                    right: 10,
                  ),
            height: 70,
            width: 280,
            decoration: FirebaseAuth.instance.currentUser.email == _userEmail
                ? meDecoration
                : otherDecoration,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userEmail,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    _message == null ? "test" : _message,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              margin: EdgeInsets.only(left: 8, top: 8),
            ),
          ),
        ],
      ),
    );
  }
}
