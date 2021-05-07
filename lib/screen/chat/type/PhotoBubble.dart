import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/Constant.dart';

// ignore: must_be_immutable
class PhotoBubble extends StatelessWidget {
  String _userEmail;
  String _downloadUrl;
  String _id;

  PhotoBubble(this._userEmail,this._downloadUrl,this._id);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: (){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return  dialog(context, "Silmek istiyor musunuz?", this._id,1,url: this._downloadUrl);
          },
        );
      },
      child: Column(
        crossAxisAlignment: FirebaseAuth.instance.currentUser.email ==
            _userEmail
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Column(
            children: [
              Container(
                margin: FirebaseAuth.instance.currentUser.email ==
                    _userEmail
                    ? EdgeInsets.only(left: 10, top: 10)
                    : EdgeInsets.only(
                  top: 10,
                  right: 10,
                ),
                height: 24,
                width: 230,
                decoration: BoxDecoration(
                  color: FirebaseAuth.instance.currentUser.email ==
                      _userEmail
                      ? Colors.orange.shade100
                      : Colors.grey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      6,
                    ),
                    topRight: Radius.circular(
                      6,
                    ),
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.only(
                    left: 5,
                    top: 3,
                  ),
                  child: Text(_userEmail == null
                      ? ""
                      : _userEmail),
                ),
              ),
              Container(
                margin: FirebaseAuth.instance.currentUser.email ==
                    _userEmail
                    ? EdgeInsets.only(left: 10, top: 0)
                    : EdgeInsets.only(
                  top: 0,
                  right: 10,
                ),
                height: 320,
                width: 230,
                child: _downloadUrl == null
                    ? Center(
                  child: CircularProgressIndicator(),
                )
                    : CachedNetworkImage(
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  imageUrl: _downloadUrl,
                  fit: BoxFit.cover,
                ),
                //Image.network(_indirmeBaglantisi,fit: BoxFit.cover,),
              ),
              Container(
                margin: FirebaseAuth.instance.currentUser.email ==
                    _userEmail
                    ? EdgeInsets.only(left: 10, top: 0)
                    : EdgeInsets.only(
                  top: 0,
                  right: 10,
                ),
                height: 24,
                width: 230,
                decoration: BoxDecoration(
                  color: FirebaseAuth.instance.currentUser.email ==
                      _userEmail
                      ? Colors.orange.shade100
                      : Colors.grey,
                  borderRadius: FirebaseAuth.instance.currentUser.email ==
                      _userEmail
                      ? BorderRadius.only(
                      bottomLeft: Radius.circular(
                        0,
                      ),
                      bottomRight: Radius.circular(
                        6,
                      ))
                      : BorderRadius.only(
                      bottomLeft: Radius.circular(
                        6,
                      ),
                      bottomRight: Radius.circular(
                        0,
                      )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

