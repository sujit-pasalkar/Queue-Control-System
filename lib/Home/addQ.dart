import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:queue_control/SharedPref/SharedPref.dart';
import 'package:queue_control/Profile/profilePage.dart';
import 'package:queue_control/Chat/chatPage.dart';

var uuid = new Uuid();

class AddQ extends StatefulWidget {
  final String serviceName;
  final String servicetype;
  AddQ({
    Key key,
    @required this.serviceName,
    @required this.servicetype,
  });

  @override
  _AddQState createState() => _AddQState();
}

class _AddQState extends State<AddQ> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool loading = false;
  int timePerService;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('${widget.serviceName.toUpperCase()}'),
        actions: <Widget>[],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection('services')
            .document('${widget.servicetype}')
            .collection('${widget.servicetype}')
            .document('${widget.serviceName}')
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new CircularProgressIndicator();
            default:
              return !loading
                  ? new Column(
                      children: <Widget>[
                        Container(
                            height: 200,
                            width: width,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    snapshot.data.data['imageurl']),
                              ),
                              border: Border.all(color: Colors.black),
                              // borderRadius: BorderRadius.circular(10.0),
                            ),
                            // child: Image.network(snapshot.data.data['imageUrl']),
                            child: Stack(children: <Widget>[
                              Positioned(
                                bottom: 0.0,
                                left: 0.0,
                                right: 0.0,
                                child: Container(
                                    padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: <Color>[
                                          Colors.black.withOpacity(0.60),
                                          Colors.black.withOpacity(0.35),
                                        ],
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Text(
                                          '${snapshot.data.data['address']}',
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            decorationStyle:
                                                TextDecorationStyle.solid,
                                            decoration: TextDecoration.none,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.chat,
                                            color: Colors.white,
                                          ),
                                          iconSize: 30,
                                          onPressed: () {
                                            print(pref.phone);
                                            startChat(snapshot);
                                          },
                                        )
                                      ],
                                    )),
                              )
                            ])),
                        Expanded(
                          child: ListView(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        'Contact',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                        child: Text(
                                      '${snapshot.data.data['phone']}',
                                      style: TextStyle(fontSize: 18),
                                    )),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        'Email',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                        child: Text(
                                      '${snapshot.data.data['email']}',
                                      style: TextStyle(fontSize: 18),
                                    )),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        'Opening Time',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                        child: Text(
                                      '${snapshot.data.data['open']}',
                                      style: TextStyle(fontSize: 18),
                                    )),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        'Closing Time',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                        child: Text(
                                      '${snapshot.data.data['close']}',
                                      style: TextStyle(fontSize: 18),
                                    )),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        'Number Of People in Queue',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                        child: Text(
                                      '${snapshot.data.data['queuelength']}',
                                      style: TextStyle(fontSize: 18),
                                    )),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        'Average Waiting Time Of Queue',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                        child: totalWait(
                                            snapshot.data.data['queuelength'],
                                            snapshot
                                                .data.data['timeperservice'])),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          child: SizedBox(
                            height: 50.0,
                            width: width,
                            child: RaisedButton(
                              color: Colors.indigo[800],
                              child: Text(
                                'Get Token',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              onPressed: () {
                                setState(() {
                                  loading = true;
                                });

                                timePerService =
                                    snapshot.data.data['timeperservice'];

                                //check user profile first if complete..
                                checkUserProfile();
                                // addInService();
                                //else tell user to complete profile first
                              },
                            ),
                          ),
                        )
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    );
          }
        },
      ),
    );
  }

  Widget totalWait(len, timePer) {
    print(len.runtimeType);
    print(timePer.runtimeType);
    int totWait = len * timePer;

    return Text(
      '${totWait.toString()} Minutes',
      style: TextStyle(fontSize: 18),
    );
  }

  addInService() async {
    try {
      String uuid = Uuid().v1();

//in service name
      var documentReference = Firestore.instance
          .collection('services')
          .document(widget.servicetype)
          .collection(widget.servicetype)
          .document(widget.serviceName)
          .collection('tokens')
          .document(uuid);

      // print('docref set');
      // dynamic d = FieldValue.serverTimestamp().toString();
      // print('d type: ${d}');

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'uuid': uuid,
            'username': pref.name,
            'address': pref.address,
            'phone': pref.phone,
            'time': FieldValue.serverTimestamp()
          },
        );
      }).then((onValue) async {
        //increment count
        var docRef = await Firestore.instance
            .collection('services')
            .document(widget.servicetype)
            .collection(widget.servicetype)
            .document(widget.serviceName);

        var queueLen = 0;

        await docRef.get().then((onValue) async {
          // print(onValue.data['queuelength']);
          queueLen = onValue.data['queuelength'];
        });

        Firestore.instance.runTransaction((transaction) async {
          await transaction.update(
            docRef,
            {
              'queuelength': queueLen + 1,
            },
          );
        });

        //in user side
        var userDocRef = Firestore.instance
            .collection('users')
            .document(pref.phone)
            .collection('tokens')
            .document(uuid);

        Firestore.instance.runTransaction((transaction) async {
          await transaction.set(
            userDocRef,
            {
              'uuid': uuid,
              'serviceType': widget.servicetype,
              'servicename': widget.serviceName,
              // 'phone': pref.phone,
              'time': FieldValue.serverTimestamp(),
              'averageWaitingTime': queueLen * timePerService
            },
          );
        }).then((onValue) async {});

        setState(() {
          this.loading = false;
        });
        // print('added');
        final snackBar = SnackBar(
            content: Text("Token added in Queue"),
            backgroundColor: Colors.green);
        _scaffoldKey.currentState.showSnackBar(snackBar);
      });
    } catch (e) {
      print('Got Err : $e');
    }
  }

  checkUserProfile() async {
    setState(() {
      this.loading = false;
    });
    print('user profile: ${pref.name}, ${pref.address}');
    if ((pref.name == '' || pref.address == '') ||
        (pref.name == null || pref.address == null)) {
      // Navigator.of(context).push(ProfilePage());
      print('usre not profile updated');
      final snackBar = SnackBar(
          content: Text("Update Your Profile Fisrt!"),
          backgroundColor: Colors.red);
      _scaffoldKey.currentState.showSnackBar(snackBar);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProfilePage()));
      // addInService()
    } else {
      print('user profile updated');
      addInService();
    }
  }

  startChat(snapshot) {
    print(pref.name);
    print('user profile: ${pref.name}, ${pref.address}');
    if ((pref.name == '' || pref.address == '') ||
        (pref.name == null || pref.address == null)) {
      print('usre not profile updated');
      final snackBar = SnackBar(
          content: Text("Update Your Profile Fisrt!"),
          backgroundColor: Colors.red);
      _scaffoldKey.currentState.showSnackBar(snackBar);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProfilePage()));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Chat(
                    servicePhone: snapshot.data.data['phone'],
                    serviceName: widget.serviceName,
                    userPhone: pref.phone,
                    sender: 'user',
                  )));
    }
  }
}
