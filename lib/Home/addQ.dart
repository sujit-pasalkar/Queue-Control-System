import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
import 'package:queue_control/SharedPref/SharedPref.dart';
import 'package:queue_control/Profile/profilePage.dart';

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
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('${widget.serviceName.toUpperCase()}'),
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
              return //Text('${snapshot.data.data}');
                  !loading
                      ? new Column(
                          // crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                        padding: EdgeInsets.all(8.0),
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
                                        child: Text(
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

  addInService() async {
    try {
      String uuid = Uuid().v1();
      print(
          'get token: $uuid  and type: ${widget.servicetype} name : ${widget.serviceName}');

//in service name
      var documentReference = Firestore.instance
          .collection('services')
          .document(widget.servicetype)
          .collection(widget.servicetype)
          .document(widget.serviceName)
          .collection('tokens')
          .document(uuid);

      print('docref set');

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'uuid': uuid,
            'username': pref.name,
            'address': pref.address,
            'phone': pref.phone,
            'time': FieldValue.serverTimestamp(),
          },
        );
      }).then((onValue) async {
        print('added');
        final snackBar = SnackBar(
            content: Text("Token added in Queue"),
            backgroundColor: Colors.green);
        _scaffoldKey.currentState.showSnackBar(snackBar);

        //increment count
        var docRef = await Firestore.instance
            .collection('services')
            .document(widget.servicetype)
            .collection(widget.servicetype)
            .document(widget.serviceName);

        var queueLen = 0;

        await docRef.get().then((onValue) async {
          print(onValue.data['queuelength']);
          queueLen = onValue.data['queuelength'];
        });

        print(queueLen);

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
              'averageWaitingTime':queueLen*timePerService
            },
          );
        }).then((onValue) async {});

        setState(() {
          this.loading = false;
        });
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
      // addInService();

    } else {
      print('user profile updated');
      addInService();
    }
  }
}
