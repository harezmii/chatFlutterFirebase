import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Constant.dart';

class SharedPreferencesProcess {
    // Image Shared Preferences
    Future<bool> saveImage() async{
        final prefs =  await SharedPreferences.getInstance();
        return await prefs.setString(ImageKey,"");
    }
    Future<String> getImage() async{
        final prefs =  await SharedPreferences.getInstance();
        return prefs.getString(ImageKey);
    }
    Future<bool> empty() async{
        final prefs =  await SharedPreferences.getInstance();
        return await prefs.clear();
    }
    String base64String(Uint8List data) {
        return base64Encode(data);
    }
    imageFrom64BaseString(String base64String) {
        return Image.memory(
            base64Decode(base64String),
            fit: BoxFit.fill,
        );
    }

    // User Name Shared Preferences

    Future<bool> saveUserName(String userName) async{
        final prefs =  await SharedPreferences.getInstance();
        return await prefs.setString(UserNameKey,userName);
    }
    Future<String> getUserName() async{
        final prefs =  await SharedPreferences.getInstance();
        return prefs.getString(UserNameKey);
    }

    // User Description Shared Preferences
    Future<bool> saveUserDescription(String userDescription) async{
        final prefs =  await SharedPreferences.getInstance();
        return await prefs.setString(UserNameKey,userDescription);
    }
    Future<String> getUserDescription() async{
        final prefs =  await SharedPreferences.getInstance();
        return prefs.getString(UserNameKey);
    }
}