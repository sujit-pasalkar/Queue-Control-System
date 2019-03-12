import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:queue_control/Home/homePage.dart';
import 'package:queue_control/home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController smsCodeController = TextEditingController();

  String phoneNo;
  String smsCode;
  String verificationId;
  bool userVerified = false;
  //# make loading var = flase
  bool loading = false;
  //#new
  String loadingMsg = "";
  bool verifybtn;

  final formKey = GlobalKey<FormState>();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    verifybtn = false;
  }

  List<DropdownMenuItem<String>> _country_codes = [];
  String _country_code = null;
  String url;

  void loadData() {
    _country_codes = [];
    _country_codes.add(
      new DropdownMenuItem(child: new Text('India'), value: '+91'),
    );
  }

  Future<void> verifyPhone(_scaffoldKey) async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
      print('**in -> 1.AutoRetrivalTimeOut**' + verId);
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      print("2.smsSent_verifyid" + this.verificationId);
      setState(() {
        this.loading = false;
        this.loadingMsg = "";
      });

      smsCodeDialog(_scaffoldKey).then((value) {
        print('** Done clicked **');
      });
    };

    final PhoneVerificationCompleted verifiedSuccess = (FirebaseUser user) {
      print('**4.verified**');

      setState(() {
        this.loading = false;
        this.loadingMsg = "";
      });

      final snackBar = SnackBar(
        content: Text("Phone Number verified Successfully."),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      register();
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print('*5*Err ${exception.message}');

      setState(() {
        this.loading = false;
        this.loadingMsg = "";
      });

      final snackBar = SnackBar(
        content: Text(exception.message),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this._country_code + this.phoneNo,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 10),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }

  smsCodeDialog(_scaffoldKey) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter 6-digit Code'),
            content: TextField(
              decoration: InputDecoration(
                labelText: 'Enter OTP',
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
              onChanged: (value) {
                this.smsCode = value;
                //on 6th input auto nav
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              new FlatButton(
                child: Text('Resend'),
                onPressed: () {
                  Navigator.of(context).pop();
                  verifyPhone(_scaffoldKey);
                },
              ),
              new FlatButton(
                child: Text('Done'),
                onPressed: () {
                  print(this.smsCode.length);
                  if (this.smsCode.length == 6) {
                    FirebaseAuth.instance.currentUser().then((user) {
                      print('user ${user}');
                      if (user != null) {
                        register();
                        print('user:${user}');
                        print("phone" + this.phoneNo);
                      } else {
                        signIn(this.smsCode);
                      }
                    });
                  } else {
                    setState(() {
                      this.loading = false;
                    });
                    print("incorrect otp");
                    final snackBar = SnackBar(
                      content: Text("Incorrect OTP!"),
                    );
                    _scaffoldKey.currentState.showSnackBar(snackBar);
                  }
                },
              )
            ],
          );
        });

// #BottomSheet
    // showModalBottomSheet(
    //     context: context,
    //     // barrierDismissible: false,
    //     builder: (builder) {
    //       return new Container(
    //         height: 600.0,
    //         color: Colors.blue[50],
    //         child: Column(children: <Widget>[
    //           TextField(
    //             decoration: InputDecoration(
    //               labelText: 'Enter OTP',
    //             ),
    //             keyboardType: TextInputType.number,
    //             autofocus: true,
    //             onChanged: (value) {
    //               this.smsCode = value;
    //             },
    //           ),
    //          Padding(padding: EdgeInsets.all(10.0)) ,
    //          new RaisedButton(
    //             child: Text('Done'),
    //             color: Colors.blue,
    //             onPressed: () {
    //               FirebaseAuth.instance.currentUser().then((user) {
    //                 if (user != null) {
    //                   print('user:${user}');
    //                   Navigator.of(context).pop();
    //                   Navigator.of(context)
    //                       .pushReplacementNamed('/profilepage');
    //                 } else {
    //                   Navigator.of(context).pop();
    //                   print("pop");
    //                   // signIn();
    //                 }
    //               });})
    //         ]),
    //       );
    //     });
  }

  Future<void> register() async {
    print('in register');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('userPhone', this.phoneNo);
      print('phone after set reg ${this.phoneNo}');
    });
    Navigator.of(context).pushReplacementNamed('/home');
  }

  signIn(smscode) {
    print('in sign in..$verificationId / $smsCode');
    try {
      FirebaseAuth.instance
          .signInWithPhoneNumber(
              verificationId: verificationId, smsCode: smsCode) 
          .then((user) {
        print("signed User : $user");
        this.register();
      }, onError: (e) {
        print('....$e');
        setState(() {
          this.loading = false;
        });
        final snackBar = SnackBar(
          content: Text("The sms verification code is invalid."),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
        Navigator.of(context).pop();
      });
    } catch (e) {
      //no use
      final snackBar = SnackBar(
          content: Text("$e"),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
        Navigator.of(context).pop();
    }
  }

  phoneConfirmAlert(_scaffoldKey) {
    if (formKey.currentState.validate()) {
      if (this._country_code == null) {
        final snackBar = SnackBar(content: Text("Select country code!"));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      } else {
        setState(() {
          this.loading = true;
          verifybtn = false;
          this.loadingMsg = "Verifying Your Number";
        });
        formKey.currentState.save();
        verifyPhone(_scaffoldKey);
      }
    } else
      print("invalid form");
  }

  @override
  Widget build(BuildContext context) {
    loadData();
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
          title: new Text('Verify Your Mobile Number'), centerTitle: true),
      resizeToAvoidBottomPadding: true,
      body: body(),
    );
  }

  Widget body() {
    if (!loading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Expanded(
              child: ListView(
            padding: EdgeInsets.all(15.0),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 25.0),
              ),
              Text(
                "Please Select Your Country and Enter  Phone Number",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
              ),
              Container(
                padding: EdgeInsets.only(left: 10.0),
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(width: 1.0, color: Colors.black38),
                        bottom: BorderSide(width: 1.0, color: Colors.black38))),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    value: _country_code,
                    items: _country_codes,
                    hint: new Text(
                      'Select Country',
                      style: TextStyle(color: Colors.black38),
                    ),
                    onChanged: (value) {
                      _country_code = value;
                      setState(() {
                        _country_code = value;
                      });
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10.0),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(width: 1.0, color: Colors.black38))),
                child: Form(
                    key: formKey,
                    autovalidate: true,
                    child: Column(children: <Widget>[
                      Table(
                        columnWidths: {1: FractionColumnWidth(.8)},
                        children: [
                          TableRow(children: [
                            Container(
                              padding:
                                  EdgeInsets.fromLTRB(10.0, 11.0, 0.0, 0.0),
                              child: Text(
                                (_country_code == null)
                                    ? ('+1')
                                    : _country_code,
                              ),
                            ),
                            TextField(
                                decoration: InputDecoration(
                                  hintText: 'Enter Phone Number',
                                  border: InputBorder.none,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (input) {
                                  print(input);
                                  if (input.length == 10) {
                                    setState(() {
                                      verifybtn = true;
                                      this.phoneNo = input;
                                      // phoneConfirmAlert(
                                      //   _scaffoldKey,
                                      // );
                                    });
                                  } else {
                                    setState(() {
                                      verifybtn = false;
                                    });
                                  }
                                }),
                          ]),
                        ],
                      ),
                    ])),
              ),
              Container(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  'You will receive an OTP on the mobile number you have..',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            ],
          )),
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: SizedBox(
              height: 50.0,
              child: RaisedButton(
                child: Text(
                  'Verify',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                splashColor: Colors.green,
                color: Colors.indigo[900],
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                onPressed: !verifybtn
                    ? null
                    : () {
                        print('${this._country_code}-${this.phoneNo}');
                        phoneConfirmAlert(
                          _scaffoldKey,
                        );
                      },
              ),
            ),
          ),
        ],
      );
    } else {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
              // valueColor: new AlwaysStoppedAnimation<Color>(Color(0xffb00bae3)),
              ),
          Padding(
            padding: EdgeInsets.all(5),
          ),
          Text(
            loadingMsg,
            style: TextStyle(
                color: Colors.indigo[900], fontWeight: FontWeight.bold),
          ),
        ],
      ));
    }
  }
}
