import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:queue_control/Home/homePage.dart';
import 'package:queue_control/status.dart';
import 'SharedPref/SharedPref.dart';
// import 'Map/map.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ScrollController hideButtonController;
  bool isBottomBarVisible;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  PageStorageKey homeKey = PageStorageKey('home');
  PageStorageKey statusKey = PageStorageKey('status');

  @override
  void initState() {
    super.initState();
    getUserProfile();

    // currentIndex = 0;
    isBottomBarVisible = true;
    hideButtonController = new ScrollController();
    hideButtonController.addListener(() {
      if (hideButtonController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          isBottomBarVisible = false;
        });
      }
      if (hideButtonController.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          isBottomBarVisible = true;
        });
      }
      if (hideButtonController.offset == 0.0) {
        setState(() {
          isBottomBarVisible = true;
        });
      }
    });

    //#fcm
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      var documentReference = Firestore.instance
          .collection('userTokens')
          .document(pref.phone);

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {'token': token, 'id': pref.phone},
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: bottomBar(),
      body: WillPopScope(
        child: buildBody(),
        onWillPop: onBackPress,
      ),
    );
  }

  bottomBar() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      height: isBottomBarVisible ? 60.0 : 0.0,
      child: isBottomBarVisible
          ? BottomNavigationBar(
              currentIndex: pref.currentIndex,
              type: BottomNavigationBarType.shifting,
              onTap: (int index) {
                setState(() {
                  pref.currentIndex = index;
                });
              },
              items: <BottomNavigationBarItem>[
                // BottomNavigationBarItem(
                //   backgroundColor: Colors.indigo[900],
                //   icon: Icon(
                //     Icons.map,
                //     color: Colors.grey,
                //   ),
                //   activeIcon: Icon(
                //     Icons.map,
                //     color: Colors.white,
                //     size: 40.0,
                //   ),
                //   title: SizedBox(
                //     height: 0.0,
                //     width: 0.0,
                //   ),
                // ),

                BottomNavigationBarItem(
                  backgroundColor: Colors.indigo[900],
                  icon: Icon(
                    Icons.home,
                    color: Colors.grey,
                  ),
                  activeIcon: Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 40.0,
                  ),
                  title: SizedBox(
                    height: 0.0,
                    width: 0.0,
                  ),
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.indigo[900],
                  icon: Icon(
                    Icons.assignment,
                    color: Colors.grey,
                  ),
                  activeIcon: Icon(
                    Icons.assignment,
                    color: Colors.white,
                    size: 40.0,
                  ),
                  title: SizedBox(
                    height: 0.0,
                    width: 0.0,
                  ),
                ),
              ],
            )
          : Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
            ),
    );
  }

  buildBody() {
    switch (pref.currentIndex) {
      // case 0:
      //   return GMap(
      //     hideButtonController: hideButtonController,
      //     key: homeKey,
      //   );
      //   break;

      case 0:
        return HomePage(
          hideButtonController: hideButtonController,
          key: homeKey,
        );
        break;

      case 1:
        return Status(
          hideButtonController: hideButtonController,
          key: statusKey,
        );
        break;
    }
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: Colors.indigo[900],
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }

  getUserProfile()async{
    // var documentReference = 
    await Firestore.instance
          .collection('users')
          .document(pref.phone).get().then((onValue){
            print('----------------------------------------------------------');

            print(onValue.data['addr']);
            print(onValue.data['email']);

            pref.setAddr(onValue.data['addr']);
            pref.setEmail(onValue.data['email']);
            pref.setName(onValue.data['name']);
          });

  }
}
