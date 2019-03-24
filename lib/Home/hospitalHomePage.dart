//after getting vendor type='hopital' && vendor verfication status in hospital/$phone/success

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../SharedPref/SharedPref.dart';
import 'package:intl/intl.dart';
import '../Verification/verification.dart';

class Hospital extends StatefulWidget {
  @override
  _HospitalState createState() => _HospitalState();
}

class Choice {
  const Choice({this.title, this.icon});
  final String title;
  final IconData icon;
}

class _HospitalState extends State<Hospital> {
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Home',
          ),
          actions: <Widget>[
            new Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
            ),
            PopupMenuButton<Choice>(
              onSelected: onItemMenuPress,
              itemBuilder: (BuildContext context) {
                return choices.map((Choice choice) {
                  return PopupMenuItem<Choice>(
                      value: choice,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            choice.icon,
                          ),
                          Container(
                            width: 10.0,
                          ),
                          Text(
                            choice.title,
                          ),
                        ],
                      ));
                }).toList();
              },
            ),
          ],
        ),
        body: new StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance
                .collection("vendors")
                .document(pref.phone)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return Center(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "NO waiting list available for ${snapshot}",
                        style: TextStyle(color: Colors.indigo[900], fontSize:20),
                      )
                    ],
                  ),
                ),
              );
              // ListView.builder(
              //   shrinkWrap: true,
              //   itemCount: snapshot.data.data['queue'].length,
              //   padding: const EdgeInsets.all(2.0),
              //   itemBuilder: (context, position) {
              //     return !snapshot.data.data['queue'][position]['status']
              //         ? Container(
              //             padding: EdgeInsets.all(10),
              //             color: Colors.indigo[500],
              //             child: Column(
              //               children: <Widget>[
              //                 Row(children: <Widget>[
              //                   Text(
              //                     'Name  : ' +
              //                         snapshot.data.data['queue'][position]
              //                             ['name'],
              //                     style: TextStyle(
              //                         color: Colors.white, fontSize: 18),
              //                   ),
              //                 ]),
              //                 Row(children: <Widget>[
              //                   Text(
              //                     'Time   : ' +
              //                         snapshot
              //                             .data.data['queue'][position]['time']
              //                             .toString(),
              //                     style: TextStyle(
              //                         color: Colors.white, fontSize: 18),
              //                   ),
              //                 ]),
              //                 Row(children: <Widget>[
              //                   Text(
              //                     'Phone : ' +
              //                         snapshot.data.data['queue'][position]
              //                             ['phone'],
              //                     style: TextStyle(
              //                         color: Colors.white, fontSize: 18),
              //                   )
              //                 ]),
              //                 RaisedButton(
              //                   color: Colors.indigo[900],
              //                   child: Text(
              //                     'Done',
              //                     style: TextStyle(
              //                         color: Colors.white, fontSize: 18),
              //                   ),
              //                   onPressed: () {
              //                     updateStatus(
              //                         snapshot.data.data['queue'][position]
              //                             ['time'],
              //                         position);
              //                   },
              //                 )
              //               ],
              //             ))
              //         : SizedBox(
              //             height: 0,
              //             width: 0,
              //           );
              //   },
              // );
            }));
  }

  updateStatus(d, idx) async {
    var date = d;
    print(date.toString());
    String result = await vrf.updateStatus(d, idx);
    print(result);
  }

  Widget time(time) {
    int tm = int.parse(time);
    print(tm);
    return Text("");
  }

  String readTimestamp(timestamp) {
    var now = new DateTime.now();
    var format = new DateFormat('HH:mm a');
    var date =
        timestamp; // new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    }

    return time;
  }

  void onItemMenuPress(Choice choice) {
    if (choice.title == 'Log out') {
      logout();
    }
  }

  logout() async {
    FirebaseAuth.instance.signOut().then((action) {
      // clearSharedPref();
      pref.clearUser();
      Navigator.pushReplacementNamed(context, '/loginpage');
    }).catchError((e) {
      print("*err:*" + e);
    });
  }
}
