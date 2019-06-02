import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../SharedPref/SharedPref.dart';
import 'package:queue_control/Chat/chatPage.dart';
import 'package:intl/intl.dart';

class AdminQ extends StatefulWidget {
  final String serviceName;
  final String servicetype;
  final int phone;
  AdminQ({
    Key key,
    @required this.serviceName,
    @required this.servicetype,
    @required this.phone,
  });

  @override
  _AdminQState createState() => _AdminQState();
}

class _AdminQState extends State<AdminQ> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  var now;

  @override
  void initState() {
    print('${widget.servicetype}, ${widget.serviceName} , ${widget.phone}');
    getDate();
    super.initState();
  }

  getDate() {
    now = new DateTime.now();
    print(now);
    print(DateTime.parse(now.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('${widget.serviceName.toUpperCase()}'),
      ),
      body: new StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection("services")
              .document(widget.servicetype)
              .collection(widget.servicetype)
              .document(widget.serviceName)
              .collection('tokens')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Incorrect Service Name',
                    style: TextStyle(fontSize: 20, color: Colors.indigo[900]),
                  ),
                ],
              ));

            return snapshot.data.documents.length > 0
                ? ListView(
                    children: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return new Card(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: new Text(
                                  "${document['username'][0].toUpperCase()}${document['username'].substring(1)}"),
                              subtitle: new Text(document['uuid']),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.indigo[900],
                                iconSize: 40,
                                onPressed: () {
                                  deleteToken(
                                      document['uuid']);
                                },
                              ),
                            ),
                            ListTile(
                              title: new Text('Booking Time'),
                              subtitle: new Text(document['time'].toString()),
                            ),
                            ListTile(
                              title: new Text('Contact'),
                              subtitle: new Text(document['phone'].toString()),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.chat,
                                  color: Colors.indigo[900],
                                ),
                                iconSize: 30,
                                onPressed: () {
                                  print(widget.phone.runtimeType);
                                  print(widget.phone);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Chat(
                                                servicePhone: widget.phone,
                                                serviceName: widget.serviceName,
                                                userPhone: document['phone'],
                                                sender: 'service',
                                              )));
                                },
                              ),
                            ),
                            ListTile(
                              title: new Text('Address'),
                              subtitle:
                                  new Text(document['address'].toString()),
                            ),
                            ListTile(
                                title: new Text("Expected Time"),
                                subtitle: Text(DateFormat('dd MMM kk:mm')
                                    .format(calcTime(document['time'],
                                        document['averageWaitingTime']))),
                                trailing: now.isAfter(calcTime(document['time'],
                                        document['averageWaitingTime']))
                                    ? RaisedButton(
                                        onPressed: () {
                                          callFunction(document['phone'],widget.serviceName);
                                        },
                                        child: Text('notify'),
                                      )

                                    // Text('token expired')
                                    : Text('token expired')),
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
                        style:
                            TextStyle(fontSize: 20, color: Colors.indigo[900]),
                      ),
                    ],
                  ));
          }),
    );
  }

  callFunction(phone,service) async{
  //  dynamic res= await CloudFunctions.instance.call(
  //     functionName: 'helloWorld',
  //     // parameters: <String, dynamic>{
  //     //   'param1': 'this is just a test',
  //     //   'param2': 'hi there',
  //     // },
  //   );
  //   print('call function response:${res}');

    // CloudFunctions.instance.call(
    //                 functionName: "addUser",
    //                 parameters: {
    //                   "name": "sujit test",
    //                   "email": "sujit@gmail.com"
    //                 }
    //               );

    // add notify msg to firestore
    var documentReference = Firestore.instance
          .collection('notify')
          .document(DateTime.now().millisecondsSinceEpoch.toString());

           Firestore.instance.runTransaction((transaction) async {
        await transaction.//update(documentReference, {'phone': phone, 'service': service},);
        set(
          documentReference,
          {'phone': phone, 'service': service},
        );
      }).then((onValue){
        print('send notification :$phone , $service');
      });

  }

  dynamic calcTime(time, waitTime) {
    dynamic addedT = time.add(new Duration(minutes: 50));
    return addedT;
  }

  deleteToken(uuid) async {
    //delete from service
    var docRefServ = await Firestore.instance
        .collection('services')
        .document(widget.servicetype)
        .collection(widget.servicetype)
        .document(widget.serviceName)
        .collection('tokens')
        .document(uuid);

    Firestore.instance.runTransaction((transaction) async {
      await transaction.delete(docRefServ);
    }).then((onValue) async {
      print('deleted token in serv');
      //increment count
      var docRef = await Firestore.instance
          .collection('services')
          .document(widget.servicetype)
          .collection(widget.servicetype)
          .document(widget.serviceName);
      var queueLen; // = 0;

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
  }
}
