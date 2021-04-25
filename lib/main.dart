import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screen/login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
        body: Center(
          child: Row(
            children: [
              RaisedButton(
                child: Text("Register"),
                onPressed: () async {},
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.cyan.shade700,
          onPressed: () {
            print("Float");
          },
          child: Icon(
            Icons.edit,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
