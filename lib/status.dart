import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Review/review.dart';
import 'SharedPref/SharedPref.dart';
import 'package:intl/intl.dart';

class Status extends StatefulWidget {
  final ScrollController hideButtonController;

  Status({@required this.hideButtonController, Key key}) : super(key: key);

  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime now;
  @override
  void initState() {
    getDate();
    super.initState();
  }

  getDate() {
    now = new DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Your Appointment Status',
          ),
        ),
        body: new StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection("users")
                .document(pref.phone)
                .collection('tokens')
                .orderBy('time')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return snapshot.data.documents.length > 0
                  ? ListView(
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                            return new Card(
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                      title: new Text(
                                          "${document['serviceType'][0].toUpperCase()}${document['serviceType'].substring(1)}"),
                                      subtitle:
                                          new Text(document['servicename']),
                                      trailing: RaisedButton(
                                        color: Colors.indigo[900],
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          deleteToken(
                                              document['serviceType'],
                                              document['servicename'],
                                              document['uuid']);
                                        },
                                      )),
                                  ListTile(
                                      title: new Text('Booking Time'),
                                      subtitle: Text(DateFormat('dd MMM kk:mm')
                                          .format(document['time'])),
                                      trailing: now.isAfter(calcTime(
                                              document['time'],
                                              document['averageWaitingTime']))
                                          ? RaisedButton(
                                              color: Colors.indigo,
                                              child: Text(
                                                'Add Review',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              onPressed: () {
                                                // document
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Review(
                                                                document:
                                                                    document)));
                                              },
                                            )
                                          : Text('')),
                                  ListTile(
                                    title: new Text('Average Waiting Time'),
                                    subtitle: new Text(
                                        document['averageWaitingTime']
                                                .toString() +
                                            " Minutes"),
                                  ),
                                  ListTile(
                                      title: new Text('Your Timing'),
                                      subtitle: Text(DateFormat('dd MMM kk:mm')
                                          .format(calcTime(document['time'],
                                              document['averageWaitingTime']))),
                                      trailing: now.isAfter(calcTime(
                                              document['time'],
                                              document['averageWaitingTime']))
                                          ? Text('Token Expired')
                                          : Text('')),
                                ],
                              ),
                            );
                          })
                          .toList()
                          .reversed
                          .toList()
                      // ),
                      )
                  : Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'No Status Found Yet.',
                          style: TextStyle(
                              fontSize: 20, color: Colors.indigo[900]),
                        ),
                      ],
                    ));
            }));
  }

  DateTime calcTime(DateTime time, int waitTime) {
    DateTime addedT = time.add(new Duration(minutes: waitTime));
    return addedT;
  }

  deleteToken(type, name, uuid) async {
    //delete from service
    var docRefServ = await Firestore.instance
        .collection('services')
        .document(type)
        .collection(type)
        .document(name)
        .collection('tokens')
        .document(uuid);

    Firestore.instance.runTransaction((transaction) async {
      await transaction.delete(docRefServ);
    }).then((onValue) async {
      print('deleted token in serv');
      //increment count
      var docRef = await Firestore.instance
          .collection('services')
          .document(type)
          .collection(type)
          .document(name);
      int queueLen = 0;

      await docRef.get().then((onValue) async {
        print(onValue.data['queuelength']);
        queueLen = onValue.data['queuelength'];
      });

      print('queueLen :$queueLen');

      if (queueLen < 0) {
        Firestore.instance.runTransaction((transaction) async {
          await transaction.update(
            docRef,
            {
              'queuelength': 0,
            },
          );
        });
      } else {
        Firestore.instance.runTransaction((transaction) async {
          await transaction.update(
            docRef,
            {
              'queuelength': queueLen - 1,
            },
          );
        });
      }

      //delete from user
      var docRefUser = await Firestore.instance
          .collection('users')
          .document(pref.phone)
          .collection('tokens')
          .document(uuid);
      Firestore.instance.runTransaction((transaction) async {
        await transaction.delete(docRefUser);
      }).then((onValue) {
        print('deleted token');
        final snackBar = SnackBar(
            content: Text('Appointment token deleted'),
            backgroundColor: Colors.green);
        _scaffoldKey.currentState.showSnackBar(snackBar);
      });
    }).catchError((onError) {
      final snackBar =
          SnackBar(content: Text(onError), backgroundColor: Colors.red);
      _scaffoldKey.currentState.showSnackBar(snackBar);
    });
  }
}
