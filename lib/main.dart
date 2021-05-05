import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera_camera/camera_camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/screen/chat/MessageManager.dart';
import 'package:flutter_app/screen/login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => Login(),
        "/home": (context) => Home(),
      },
      theme: ThemeData(
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.cyan.shade700,
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _controller;
  ScrollController _scrollController;
  final currentUser = FirebaseAuth.instance.currentUser.email;
  final isMe = null;
  var resultImageList;
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();
  FlutterSoundRecorder _recorder;
  File _file;

  @override
  void dispose() {
    if (_recorder != null) {
      _recorder.closeAudioSession();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = new TextEditingController();
    _scrollController = new ScrollController();

    getToken();
    _recorder = new FlutterSoundRecorder();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: 'launch_background',
              ),
            ));
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent.ceilToDouble(),
          duration: Duration(milliseconds: 300),
          curve: Curves.elasticOut);
    } else {
      Timer(Duration(milliseconds: 400), () => _scrollToBottom());
    }
  }
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

              var token = await FirebaseMessaging.instance.getToken();

              try {
                var link;
                var reference = await firebase_storage.FirebaseStorage.instance
                    .ref()
                    .child("/uploads/image/" +_file.path);
                var storage = await reference.putFile(new File(_file.path));
                var referenceNetwork =
                    await reference.getDownloadURL().then((value) => link = value);

                var collection = FirebaseFirestore.instance.collection("chatMessage");
                collection.add({
                  "timestamp": Timestamp.now(),
                  "userEmail": FirebaseAuth.instance.currentUser.email,
                  "messageType": "photo",
                  "imageUrl": reference.fullPath,
                  "downloadLink": link,
                });
              } catch (e) {
                print("Hata VARRRRRRRRRRRRRRRRRRRRRRRRRrr");
              }

              var data = {
                "to": token,
                "notification": {
                  "title": FirebaseAuth.instance.currentUser.email,
                  "body": _file.path,
                },
              };
              var response = await http.post(
                Uri.parse("https://fcm.googleapis.com/fcm/send"),
                headers: {
                  'Content-type': 'application/json',
                  'Authorization':
                  'key=AAAAdDzidd4:APA91bFgqjMPKJEGzJzrudyZ1P_g5ruNfIzTNWV7x1lj3bHXMw76APkmFwyLGNwsQEITvFJKrsgAgTqGVBwX_nHY0qVx--EwJsNd-WvSrdk1b9ZX_kZsz-JBYj3tZY7Qgq9VF7ePWgN0',
                },
                body: jsonEncode(
                  data,
                ),
              );
              if (response.statusCode == 401) {
                print("authorization");
              }
              if (response.statusCode == 200) {
                print("Success");
              }

              Navigator.pop(context);




            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.cyan.shade700,
          title: Text(
            "ChatTo",
            style: TextStyle(
                fontSize: 24,
                letterSpacing: 0.8,
                wordSpacing: 1.0,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                print("Search");
              },
              child: Container(
                margin: EdgeInsets.only(
                  right: 10.0,
                ),
                child: Icon(
                  Icons.search_sharp,
                  size: 28,
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            GestureDetector(
              child: Icon(Icons.water_damage_sharp),
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Çıkmak İstiyormusun?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Hayır"),
                          ),
                          TextButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              final GoogleSignIn googleSignIn = GoogleSignIn();
                              googleSignIn.signOut();
                              Navigator.pushNamed(context, "/");
                            },
                            child: Text("Evet"),
                          ),
                        ],
                      );
                    });
              },
            ),
            SizedBox(
              width: 12,
            ),
          ],
        ),
        drawerEnableOpenDragGesture: true,
        drawer: Drawer(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 180.0,
                color: Colors.cyan.shade700,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        top: 24.0,
                      ),
                      child: ListTile(
                        leading: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                "https://iasbh.tmgrup.com.tr/bf926b/366/218/0/0/768/458?u=https://isbh.tmgrup.com.tr/sbh/2018/02/26/steve-jobs-kimdir--1519649351565.jpg",
                              ),
                            ),
                          ),
                        ),
                        trailing: Icon(
                          Icons.wb_incandescent_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 40.0,
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(
                            8.0,
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Suat Canbay",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                "0552 652 7895",
                                style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              )
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () {},
                          icon: FaIcon(
                            FontAwesomeIcons.arrowDown,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.all(
                    10.0,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.people_alt_sharp,
                          color: Colors.grey,
                          size: 24,
                        ),
                        title: Text("New Group"),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.person_outline_sharp,
                          color: Colors.grey,
                          size: 24,
                        ),
                        title: Text("Contacts"),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.phone,
                          color: Colors.grey,
                          size: 24,
                        ),
                        title: Text("Calls"),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.workspaces_outline,
                          color: Colors.grey,
                          size: 24,
                        ),
                        title: Text("Yakındaki Kişiler"),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.settings,
                          color: Colors.grey,
                          size: 24,
                        ),
                        title: Text("Settings"),
                      ),
                      Divider(
                        height: 2.0,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.person_add_outlined,
                          color: Colors.grey,
                          size: 24,
                        ),
                        title: Text("Invite Friends"),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.question_answer_sharp,
                          color: Colors.grey,
                          size: 24,
                        ),
                        title: Text("ChatTo FAQ"),
                      ),
                    ],
                  )),
            ],
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Flexible(
                  child: StreamBuilder(
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
                        controller: _scrollController,
                        children:
                            snapshot.data.docs.map((DocumentSnapshot document) {
                          return MessageManager(
                            document.data()["userEmail"],
                            document.data()["message"],
                            document.data()["messageType"],
                            document.data()["downloadLink"],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    child: Container(
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              onTap: () {
                                Timer(Duration(seconds: 1), () {
                                  _scrollController.jumpTo(_scrollController
                                      .position.maxScrollExtent);
                                });
                              },
                              cursorColor: Colors.red,
                              controller: _controller,
                              decoration: InputDecoration(
                                  icon: FaIcon(
                                    FontAwesomeIcons.smile,
                                    size: 28,
                                    color: Colors.grey.shade500,
                                  ),
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
                                  hintText: "Enter the message",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  )),
                            ),
                          ),
                          Container(
                            width: 50,
                            child: GestureDetector(
                              onTap: () async {
                                var token =
                                    await FirebaseMessaging.instance.getToken();
                                var collection = FirebaseFirestore.instance
                                    .collection("chatMessage");

                                if (_controller.value.text.isEmpty) {
                                  Toast.show("Alanı baş bırakmayın", context,
                                      gravity: Toast.CENTER);
                                } else {
                                  collection.add({
                                    "message": _controller.value.text,
                                    "timestamp": Timestamp.now(),
                                    "userEmail":
                                        FirebaseAuth.instance.currentUser.email,
                                    "messageType": "message"
                                  });

                                  var data = {
                                    "to": token,
                                    "notification": {
                                      "title": FirebaseAuth
                                          .instance.currentUser.email,
                                      "body": _controller.value.text,
                                    },
                                  };
                                  var response = await http.post(
                                    Uri.parse(
                                        "https://fcm.googleapis.com/fcm/send"),
                                    headers: {
                                      'Content-type': 'application/json',
                                      'Authorization':
                                          'key=AAAAdDzidd4:APA91bFgqjMPKJEGzJzrudyZ1P_g5ruNfIzTNWV7x1lj3bHXMw76APkmFwyLGNwsQEITvFJKrsgAgTqGVBwX_nHY0qVx--EwJsNd-WvSrdk1b9ZX_kZsz-JBYj3tZY7Qgq9VF7ePWgN0',
                                    },
                                    body: jsonEncode(
                                      data,
                                    ),
                                  );
                                  if (response.statusCode == 401) {
                                    print("authorization");
                                  }
                                  if (response.statusCode == 200) {
                                    print("Success");
                                  }
                                  _controller.text = "";

                                  _scrollController.animateTo(
                                      _scrollController.position.maxScrollExtent
                                              .ceilToDouble() +
                                          50,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.elasticOut);
                                }
                              },
                              child: FaIcon(
                                FontAwesomeIcons.paperPlane,
                                size: 22,
                                color: Colors.cyan.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FabCircularMenu(
          key: fabKey,
          animationDuration: Duration(seconds: 1),
          alignment: Alignment(1.0, 0.84),
          fabOpenIcon: Icon(
            Icons.add,
            color: Colors.white,
          ),
          fabCloseIcon: Icon(
            Icons.cancel,
            color: Colors.white,
          ),
          fabColor: Colors.grey.shade800,
          ringColor: Colors.grey.shade800,
          children: [
            GestureDetector(
              onTap: () async {
                var result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowCompression: true,
                );
                var token = await FirebaseMessaging.instance.getToken();

                if (result == null) {
                  Toast.show("Seçilemedi", context, gravity: Toast.BOTTOM);
                  Navigator.pushNamed(context, "/home");
                } else {
                  try {
                    var link;
                    var reference = await firebase_storage
                        .FirebaseStorage.instance
                        .ref()
                        .child("/uploads/image/" + result.files.first.path);
                    var storage = await reference
                        .putFile(new File(result.files.first.path));
                    var referenceNetwork = await reference
                        .getDownloadURL()
                        .then((value) => link = value);

                    var collection =
                        FirebaseFirestore.instance.collection("chatMessage");
                    collection.add({
                      "timestamp": Timestamp.now(),
                      "userEmail": FirebaseAuth.instance.currentUser.email,
                      "messageType": "photo",
                      "imageUrl": reference.fullPath,
                      "downloadLink": link,
                    });
                  } catch (e) {
                    print("Hata VARRRRRRRRRRRRRRRRRRRRRRRRRrr");
                  }

                  var data = {
                    "to": token,
                    "notification": {
                      "title": FirebaseAuth.instance.currentUser.email,
                      "body": result.files.first.path,
                    },
                  };
                  var response = await http.post(
                    Uri.parse("https://fcm.googleapis.com/fcm/send"),
                    headers: {
                      'Content-type': 'application/json',
                      'Authorization':
                          'key=AAAAdDzidd4:APA91bFgqjMPKJEGzJzrudyZ1P_g5ruNfIzTNWV7x1lj3bHXMw76APkmFwyLGNwsQEITvFJKrsgAgTqGVBwX_nHY0qVx--EwJsNd-WvSrdk1b9ZX_kZsz-JBYj3tZY7Qgq9VF7ePWgN0',
                    },
                    body: jsonEncode(
                      data,
                    ),
                  );
                  if (response.statusCode == 401) {
                    print("authorization");
                  }
                  if (response.statusCode == 200) {
                    print("Success");
                  }
                  if (fabKey.currentState.isOpen) {
                    fabKey.currentState.close();
                  }
                  _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent
                              .ceilToDouble() +
                          200,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.elasticOut);
                }
              },
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.shade500,
                ),
                child: Icon(
                  Icons.photo,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade500,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.insert_drive_file,
                  size: 40,
                  color: Colors.white,
                ),
                onPressed: () async {
                  FilePickerResult result = await FilePicker.platform.pickFiles(
                    type: FileType.any,
                    allowMultiple: true,
                    allowCompression: true,
                  );
                },
              ),
            ),
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade500,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.white,
                ),
                onPressed: () async {
                  FilePickerResult result = await FilePicker.platform.pickFiles(
                    type: FileType.any,
                    allowMultiple: true,
                    allowCompression: true,
                  );
                },
              ),
            ),
            GestureDetector(
              onTap: () async {
                openCamera();
                if(fabKey.currentState.isOpen) {
                  fabKey.currentState.close();
                }
              },
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.brown.shade500,
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            GestureDetector(
              onLongPress: () async {
                var hasPermission = await Permission.microphone.isGranted;
                if (!hasPermission) {
                  await Permission.microphone.request().isGranted;
                }
                Directory appDocDir = await getApplicationDocumentsDirectory();
                String appDocPath = appDocDir.path;
                print("*********************************");

                await _recorder.openAudioSession().then((value) {
                  _recorder.startRecorder(
                    codec: Codec.aacADTS,
                    toFile: appDocPath +
                        "/" +
                        DateTime.now().millisecondsSinceEpoch.toString() +
                        ".aac",
                  );
                  if (_recorder.isRecording) {
                    Toast.show("Kaydediliyor", context);
                  }
                });
              },
              onLongPressEnd: (value) async {
                String path = await _recorder.stopRecorder();
                await _recorder.closeAudioSession();
                if (_recorder.isStopped) {
                  Toast.show("Stop Recording : Path > " + path, context,
                      gravity: Toast.BOTTOM);
                }
                try {
                  var link;
                  var reference = await firebase_storage
                      .FirebaseStorage.instance
                      .ref()
                      .child("/uploads/sound/" + path);
                  var storage = await reference.putFile(new File(path));
                  var referenceNetwork = await reference
                      .getDownloadURL()
                      .then((value) => link = value);

                  var collection =
                      FirebaseFirestore.instance.collection("chatMessage");
                  collection.add({
                    "timestamp": Timestamp.now(),
                    "userEmail": FirebaseAuth.instance.currentUser.email,
                    "messageType": "sound",
                    "imageUrl": reference.fullPath,
                    "downloadLink": link,
                  });

                  var token = await FirebaseMessaging.instance.getToken();

                  var data = {
                    "to": token,
                    "notification": {
                      "title": FirebaseAuth.instance.currentUser.email,
                      "body": "Ses Kaydedildi",
                    },
                  };
                  var response = await http.post(
                    Uri.parse("https://fcm.googleapis.com/fcm/send"),
                    headers: {
                      'Content-type': 'application/json',
                      'Authorization':
                          'key=AAAAdDzidd4:APA91bFgqjMPKJEGzJzrudyZ1P_g5ruNfIzTNWV7x1lj3bHXMw76APkmFwyLGNwsQEITvFJKrsgAgTqGVBwX_nHY0qVx--EwJsNd-WvSrdk1b9ZX_kZsz-JBYj3tZY7Qgq9VF7ePWgN0',
                    },
                    body: jsonEncode(
                      data,
                    ),
                  );
                  if (response.statusCode == 401) {
                    print("authorization");
                  }
                  if (response.statusCode == 200) {
                    print("Success");
                  }

                  if (fabKey.currentState.isOpen) {
                    fabKey.currentState.close();
                  }
                  _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent
                              .ceilToDouble() +
                          50,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.elasticOut);
                } catch (e) {
                  print("Hata VARRRRRRRRRRRRRRRRRRRRRRRRRrr");
                }
              },
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.shade500,
                ),
                child: Icon(
                  Icons.mic,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

getToken() async {
  String token = await FirebaseMessaging.instance.getToken();
  print("Token :" + token);
  return token;
}
