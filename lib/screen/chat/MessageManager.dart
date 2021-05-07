import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_app/screen/chat/type/MessageBubble.dart';
import 'package:flutter_app/screen/chat/type/PhotoBubble.dart';
import 'package:flutter_app/screen/chat/type/SoundBubble.dart';

// ignore: must_be_immutable
class MessageManager extends StatefulWidget {
  String _userEmail;
  String _message;
  String _messageType;
  String _imageUrl;
  String _id;

  MessageManager(this._userEmail, this._message, this._messageType, this._imageUrl,this._id);

  String get image => this._imageUrl;

  @override
  _MessageState createState() => _MessageState();
}
class _MessageState extends State<MessageManager> {
  var _indirmeBaglantisi;

  String getDownloadUrl(String path) {

    String url = firebase_storage.FirebaseStorage.instance
        .ref(path)
        .getDownloadURL() as String;
    return url;
  }

  @override
  initState() {
    super.initState();
    _indirmeBaglantisi = this.widget._imageUrl;
  }
  // ignore: missing_return
  Widget messageType(String type){
    switch(type){
      case "message":
        return MessageBubble(this.widget._userEmail, this.widget._message,this.widget._id);
        break;
      case "photo":
        return PhotoBubble(this.widget._userEmail, _indirmeBaglantisi,this.widget._id);
        break;
      case "sound":
        return SoundBubble(this.widget._userEmail, _indirmeBaglantisi,this.widget._id);
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return messageType(this.widget._messageType);
  }

}
