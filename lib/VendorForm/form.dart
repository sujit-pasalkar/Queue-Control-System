//Admin login form page
import 'package:flutter/material.dart';
import 'package:queue_control/Home/adminQ.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../SharedPref/SharedPref.dart';
import '../Verification/verification.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  TextEditingController passCtrl = new TextEditingController();
  TextEditingController serviceNameCtrl = new TextEditingController();

  // String name, address, verify, phone, email;
  // String adminPass, serviceName;
  List<DropdownMenuItem<String>> selectType = [];
  String selectedType;

  @override
  void initState() {
    super.initState();
    selectType.add(
      new DropdownMenuItem(child: new Text('Clinic'), value: 'clinic'),
    );
    selectType.add(
      new DropdownMenuItem(child: new Text('Bank'), value: 'bank'),
    );
    // selectType.add(
    //   new DropdownMenuItem(child: new Text('ATM'), value: 'atm'),
    // );
  }

  // String _validateEmail(String value) {
  //   Pattern pattern =
  //       r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  //   RegExp regex = new RegExp(pattern);
  //   if (!regex.hasMatch(value)) {
  //     return 'Enter Valid Email';
  //   } else {
  //     return null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Admin Login'),
          actions: <Widget>[
            // IconButton(
            //   icon: Icon(Icons.close),
            //   onPressed: () {
            //     logout();
            //   },
            // )
          ],
        ),
        body: new Column(
          children: <Widget>[
            Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: Column(
                children: <Widget>[
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: DropdownButton(
                      value: selectedType,
                      items: selectType,
                      hint: new Text(
                        'Select type of service',
                        style: TextStyle(color: Colors.black38),
                      ),
                      onChanged: (value) {
                        print(value);
                        setState(() {
                          selectedType = value;
                        });
                      },
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: TextFormField(
                      enabled: true,
                      controller: serviceNameCtrl,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hasFloatingPlaceholder: true,
                        labelText: "Type Your Service Name",
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
                      onSaved: (String val) {},
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: TextFormField(
                      enabled: true,
                      controller: passCtrl,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hasFloatingPlaceholder: true,
                        labelText: "Password",
                        labelStyle: TextStyle(
                          color: Colors.blue[500],
                        ),
                      ),
                      validator: (String arg) {
                        if (arg != 'admin')
                          return 'Incorrect password';
                        else
                          return null;
                      },
                      onSaved: (String val) {},
                    ),
                  ),
                  new SizedBox(
                    height: 20.0,
                  ),
                  new SizedBox(
                    height: 50.0,
                    child: new RaisedButton(
                      color: Colors.indigo[900],
                      onPressed: _validateInputs,
                      child: new Text(
                        'Access',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        )
        /*  StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance
                .collection("vendors")
                .document(pref.phone)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Expanded(
                    child: ListView(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(
                            Icons.format_align_justify,
                            color: Colors.indigo[900],
                          ),
                          title: snapshot.data.data['submission']
                              ? Text('Your form is submitted.')
                              : Text('Your form is not submitted.'),
                          subtitle: snapshot.data.data['submission']
                              ? Text('wait for admin acceptance')
                              : Text('submit form to go ahead!'),
                          trailing: snapshot.data.data['submission']
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: DropdownButton(
                            value: selectedType == null
                                ? snapshot.data.data['type']
                                : selectedType, //,
                            items: selectType,
                            hint: new Text(
                              'Select type of service',
                              style: TextStyle(color: Colors.black38),
                            ),
                            onChanged: (value) {
                              print(value);
                              setState(() {
                                selectedType = value;
                              });
                            },
                          ),
                        ),
                        snapshot.data.data['type'] == 'clinic' ||
                                selectedType == 'clinic'
                            ? clinicForm(snapshot)
                            : snapshot.data.data['type'] == 'bank'
                                ? Form()
                                : snapshot.data.data['type'] == 'bank'
                                    ? Form()
                                    : SizedBox()
                      ],
                    ),
                  )
                ],
              );
            }) */
        );
  }

  void _validateInputs() async {
    if (_formKey.currentState.validate() && selectedType != null) {
      _formKey.currentState.save();
      // String result = await vrf.registerVendor(
      //     name, email, address, selectedType, clinic_name);
      print('register result : ${serviceNameCtrl.text}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AdminQ(
                  serviceName: serviceNameCtrl.text,
                  servicetype: selectedType)));
      // if (result == 'saved') {
      //   print('form registered');
      //   final snackBar = SnackBar(
      //       content: Text("Your Form is submitted Successfully."),
      //       backgroundColor: Colors.green);
      //   _scaffoldKey.currentState.showSnackBar(snackBar);
      // } else if (result == 'error' || result == null) {
      //   final snackBar = SnackBar(
      //       content: Text("Something went wrong"), backgroundColor: Colors.red);
      //   _scaffoldKey.currentState.showSnackBar(snackBar);
      // }
    } else {
      setState(() {
        print('not validated');
        _autoValidate = true;
      });
      if (selectedType == null) {
        final snackBar = SnackBar(
          content: Text("select type of service"),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
  }

  // logout() async {
  //   FirebaseAuth.instance.signOut().then((action) {
  //     pref.clearUser();
  //     Navigator.pushReplacementNamed(context, '/loginpage');
  //   }).catchError((e) {
  //     print("*err:*" + e);
  //   });
  // }

  // Widget clinicForm(snapshot) {
  //   return Form(
  //     key: _formKey,
  //     autovalidate: _autoValidate,
  //     child: Column(
  //       children: <Widget>[
  //         Container(
  //           color: Colors.white,
  //           padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
  //           child: TextFormField(
  //             enabled: true,
  //             // controller: nameController,
  //             initialValue: snapshot.data.data['name'],
  //             style: TextStyle(
  //               color: Colors.black,
  //             ),
  //             decoration: InputDecoration(
  //               // border: InputBorder.none,
  //               hasFloatingPlaceholder: true,
  //               labelText: "Doctor Name",
  //               labelStyle: TextStyle(
  //                 color: Colors.blue[500],
  //               ),
  //             ),
  //             validator: (String arg) {
  //               if (arg.length < 2)
  //                 return 'Name must be more than 2 charater';
  //               else
  //                 return null;
  //             },
  //             onSaved: (String val) {
  //               name = val;
  //             },
  //           ),
  //         ),

  //         Container(
  //           color: Colors.white,
  //           padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
  //           child: TextFormField(
  //             enabled: true,
  //             // controller: nameController,
  //             initialValue: snapshot.data.data['clinic_name'] != null
  //                 ? snapshot.data.data['clinic_name']
  //                 : "",
  //             style: TextStyle(
  //               color: Colors.black,
  //             ),
  //             decoration: InputDecoration(
  //               // border: InputBorder.none,
  //               hasFloatingPlaceholder: true,
  //               labelText: "Clinic Name",
  //               labelStyle: TextStyle(
  //                 color: Colors.blue[500],
  //               ),
  //             ),
  //             validator: (String arg) {
  //               if (arg.length < 2)
  //                 return 'Name must be more than 2 charater';
  //               else
  //                 return null;
  //             },
  //             onSaved: (String val) {
  //               clinic_name = val;
  //             },
  //           ),
  //         ),

  //         Container(
  //           color: Colors.white,
  //           padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
  //           child: TextFormField(
  //             enabled: false,
  //             initialValue: snapshot.data.data['phone'],
  //             style: TextStyle(
  //               color: Colors.black,
  //             ),
  //             decoration: InputDecoration(
  //               border: InputBorder.none,
  //               hasFloatingPlaceholder: true,
  //               labelText: "Phone",
  //               labelStyle: TextStyle(
  //                 color: Colors.blue[500],
  //               ),
  //             ),
  //           ),
  //         ),

  //         Container(
  //           color: Colors.white,
  //           padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
  //           child: TextFormField(
  //             enabled: true,
  //             initialValue: snapshot.data.data['email'],
  //             style: TextStyle(
  //               color: Colors.black,
  //             ),
  //             decoration: InputDecoration(
  //               // border: InputBorder.none,
  //               hasFloatingPlaceholder: true,
  //               labelText: "Email",
  //               labelStyle: TextStyle(
  //                 color: Colors.blue[500],
  //               ),
  //             ),
  //             validator: (String arg) {
  //               return _validateEmail(arg);
  //             },
  //             onSaved: (String val) {
  //               email = val;
  //             },
  //           ),
  //         ),

  //         Container(
  //           color: Colors.white,
  //           padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
  //           child: TextFormField(
  //             enabled: true,
  //             initialValue: snapshot.data.data['address'],
  //             style: TextStyle(
  //               color: Colors.black,
  //             ),
  //             decoration: InputDecoration(
  //               // border: InputBorder.none,
  //               hasFloatingPlaceholder: true,
  //               labelText: "Address",
  //               labelStyle: TextStyle(
  //                 color: Colors.blue[500],
  //               ),
  //             ),
  //             validator: (String arg) {
  //               if (arg.length < 2)
  //                 return 'Name must be more than 2 charater';
  //               else
  //                 return null;
  //             },
  //             onSaved: (String val) {
  //               address = val;
  //             },
  //           ),
  //         ),

  //         // new DropdownButton<String>(
  //         //   items: <String>['Clinic', 'Bank',].map((String value) {
  //         //     return new DropdownMenuItem<String>(
  //         //       value: value,
  //         //       child: new Text(value),
  //         //     );
  //         //   }).toList(),
  //         //   onChanged: (_) {},
  //         // )

  //         new SizedBox(
  //           height: 50.0,
  //           child: new RaisedButton(
  //             color: Colors.indigo[900],
  //             onPressed: _validateInputs,
  //             child: new Text(
  //               'Rigister',
  //               style: TextStyle(color: Colors.white),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
