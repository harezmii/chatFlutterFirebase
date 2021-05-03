import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screen/login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

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

  //var timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

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

  @override
  void initState() {
    super.initState();
    _controller = new TextEditingController();
    _scrollController = new ScrollController();
    getToken();

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

  @override
  Widget build(BuildContext context) {
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
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, "/");
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
        body: Container(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height - 150,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatMessage")
                      .orderBy("timestamp")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    return ListView(
                      children:
                          snapshot.data.docs.map((DocumentSnapshot document) {
                        return Column(
                          crossAxisAlignment:
                              FirebaseAuth.instance.currentUser.email ==
                                      document.data()["userEmail"]
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                          children: [
                            Container(
                              margin: FirebaseAuth.instance.currentUser.email ==
                                      document.data()["userEmail"]
                                  ? EdgeInsets.only(
                                      left: 10,
                                      top: 10,
                                    )
                                  : EdgeInsets.only(
                                      top: 10,
                                      right: 10,
                                    ),
                              height: 50,
                              width: 280,
                              decoration:
                                  FirebaseAuth.instance.currentUser.email ==
                                          document.data()["userEmail"]
                                      ? meDecoration
                                      : otherDecoration,
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      document.data()["userEmail"],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      document.data()["message"],
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                margin: EdgeInsets.only(left: 8, top: 8),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      child: Container(
                        child: TextFormField(
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
                        padding: EdgeInsets.all(10),
                        height: 70,
                        width: 330,
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 16,
                      child: GestureDetector(
                        onTap: () async {
                          var token =
                              await FirebaseMessaging.instance.getToken();
                          var collection = FirebaseFirestore.instance
                              .collection("chatMessage");

                          if (_controller.value.text.isEmpty) {
                            Toast.show("Alanı baş bırakmayın", context,
                                gravity: Toast.BOTTOM);
                          } else {
                            collection.add({
                              "message": _controller.value.text,
                              "timestamp": Timestamp.now(),
                              "userEmail":
                                  FirebaseAuth.instance.currentUser.email
                            });

                            var data = {
                              "to": token,
                              "notification": {
                                "title":
                                    FirebaseAuth.instance.currentUser.email,
                                "body": _controller.value.text,
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
                            _controller.text = "";

                            _scrollController.jumpTo(_scrollController
                                    .position.maxScrollExtent
                                    .ceilToDouble() +
                                50);
                          }
                        },
                        child: Container(
                          child: FaIcon(
                            FontAwesomeIcons.paperPlane,
                            size: 22,
                            color: Colors.cyan.shade700,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 60,
                      child: GestureDetector(
                        onTap: () {
                          //  Toast.show(path.current.toString()+ ""+ DateTime.now().millisecondsSinceEpoch.toString(), context);
                        },
                        onLongPress: () async {
                          if (await Permission.storage.isDenied) {
                            await Permission.storage.request();
                          }
                          if (true) {
                          } else {
                            Toast.show(
                                "Ses kaydetme iznini vermelisiniz", context);
                          }
                        },
                        onLongPressEnd: (detail) async {},
                        child: Icon(
                          Icons.keyboard_voice_outlined,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
