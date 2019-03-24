import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'SharedPref/SharedPref.dart';

class Status extends StatefulWidget {
  final ScrollController hideButtonController;

  Status({@required this.hideButtonController, Key key}) : super(key: key);

  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Status',
          ),
        ),
        body: new StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection("users")
                .document(pref.phone)
                .collection('tokens')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return snapshot.data.documents.length > 0
                  ?
                  // Expanded(
                  //     child:
                  ListView(
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return new Card(
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                // ${s[0].toUpperCase()}${s.substring(1)}
                                title: new Text(
                                    "${document['serviceType'][0].toUpperCase()}${document['serviceType'].substring(1)}"),
                                subtitle: new Text(document['servicename']),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  color: Colors.indigo[900],
                                  iconSize: 40,
                                  onPressed: () {
                                    // print('delete this token from Queue');
                                    deleteToken(
                                        document['serviceType'],
                                        document['servicename'],
                                        document['uuid']);
                                  },
                                ),
                              ),
                              ListTile(
                                title: new Text('Booked At'),
                                subtitle: new Text(document['time'].toString()),
                              ),
                              ListTile(
                                title: new Text('Average Waiting Time'),
                                subtitle: new Text(
                                    document['averageWaitingTime'].toString() +
                                        " Minutes"),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
    }).then((onValue) async{
      print('deleted token in serv');
       //increment count
        var docRef = await Firestore.instance
            .collection('services')
            .document(type)
            .collection(type)
            .document(name);
        var queueLen;// = 0;

        await docRef.get().then((onValue) async {
          print(onValue.data['queuelength']);
          queueLen = onValue.data['queuelength'];
        });

        print(queueLen);

        Firestore.instance.runTransaction((transaction) async {
          await transaction.update(
            docRef,
            {
              'queuelength': queueLen - 1,
            },
          );
        });
    });

    //delete from user
    var docRefUser = await Firestore.instance
        .collection('users')
        .document(pref.phone)
        .collection('tokens')
        .document(uuid);
         Firestore.instance.runTransaction((transaction) async {
      await transaction.delete(docRefUser);
    }).then((onValue){
      print('deleted token');
    });
  }
}
