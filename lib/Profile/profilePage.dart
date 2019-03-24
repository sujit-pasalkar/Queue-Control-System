import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:queue_control/Home/homePage.dart';
import 'package:queue_control/SharedPref/SharedPref.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text('Profile')),
        body: new StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance
                .collection("users")
                .document(pref.phone)
                .get()
                .asStream(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return //Text('${snapshot.data.data}');
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                    new Expanded(
                        child: ListView(children: <Widget>[
                      Form(
                        key: _formKey,
                        autovalidate: _autoValidate,
                        child: Column(
                          children: <Widget>[
                            Container(
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: TextFormField(
                                enabled: true,
                                initialValue: snapshot.data.data['name'],
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hasFloatingPlaceholder: true,
                                  labelText: "Your Full Name",
                                  labelStyle: TextStyle(
                                    color: Colors.blue[500],
                                  ),
                                ),
                                validator: (String arg) {
                                  if (arg.length < 2)
                                    return 'Name must be more than 2 charater';
                                  else
                                    return null;
                                },
                                onSaved: (String val) {
                                  pref.name = val;
                                },
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: TextFormField(
                                enabled: true,
                                // controller: nameController,
                                initialValue: snapshot.data.data['addr'],
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  // border: InputBorder.none,
                                  hasFloatingPlaceholder: true,
                                  labelText: "Your Address",
                                  labelStyle: TextStyle(
                                    color: Colors.blue[500],
                                  ),
                                ),
                                validator: (String arg) {
                                  if (arg.length < 2)
                                    return 'Address must be more than 2 charater';
                                  else
                                    return null;
                                },
                                onSaved: (String val) {
                                  pref.address = val;
                                },
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: TextFormField(
                                enabled: true,
                                // controller: nameController,
                                initialValue: snapshot.data.data['email'],
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hasFloatingPlaceholder: true,
                                  labelText: "Your Email ",
                                  labelStyle: TextStyle(
                                    color: Colors.blue[500],
                                  ),
                                ),
                                validator: (String arg) {
                                  return _validateEmail(arg);
                                },
                                onSaved: (String val) {
                                  pref.email = val;
                                },
                              ),
                            ),
                            new SizedBox(
                              height: 10.0,
                            ),
                            new SizedBox(
                              height: 50.0,
                              child: new RaisedButton(
                                color: Colors.indigo[900],
                                onPressed: _validateInputs,
                                child: new Text(
                                  'Rigister',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]))
                  ]);
            }));
  }

  String _validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Enter Valid Email';
    } else {
      // pref.email = value;
      return null;
    }
  }

  void _validateInputs() async {
    // print('$selectedType');
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      String result = await registerUser();
      print('register result : $result');
      if (result == 'saved') {
        print('form registered');
        final snackBar = SnackBar(
            content: Text("Your Profile is submitted Successfully."),
            backgroundColor: Colors.green);
        _scaffoldKey.currentState.showSnackBar(snackBar);
      } else if (result == 'error' || result == null) {
        final snackBar = SnackBar(
            content: Text("Something went wrong"), backgroundColor: Colors.red);
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    } else {
      setState(() {
        print('not validated');
        _autoValidate = true;
      });
      // if (selectedType == null) {
      final snackBar = SnackBar(
        content: Text("Something went wrong"),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      // }
    }
  }

  Future<String> registerUser() async {
    try {
      print('${pref.name} , ${pref.email} , ${pref.phone} , ${pref.address}');
      String ret = await Firestore.instance
          .collection('users')
          .document(pref.phone)
          .updateData({
        'name': pref.name,
        'email': pref.email,
        'addr': pref.address
      }).then((onValue) {
        return 'saved';
      });
      return ret;
    } catch (e) {
      return 'error';
    }
  }
}
