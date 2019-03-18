import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:queue_control/SharedPref/SharedPref.dart';
import '../Home/dummyHome.dart';
// import '../Verification/verification.dart';

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

  Future<void> verifyPhone(_scaffoldKey,String loginType) async {
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

      smsCodeDialog(_scaffoldKey,loginType).then((value) {
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
      // Navigator.of(context).pop();
      _scaffoldKey.currentState.showSnackBar(snackBar);
      register(loginType);
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

  smsCodeDialog(_scaffoldKey,String loginType) {
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
                  verifyPhone(_scaffoldKey,loginType);
                },
              ),
              new FlatButton(
                child: Text('Done'),
                onPressed: () {
                  print(this.smsCode.length);
                  if (this.smsCode.length == 6) {
                    FirebaseAuth.instance.currentUser().then((user) {
                      print('user $user');
                      if (user != null) {
                        register(loginType);
                        print('user:$user');
                        print("phone" + this.phoneNo);
                      } else {
                        signIn(this.smsCode,loginType);
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

  Future<void> register(String loginType) async {
    print('in register: $loginType');
    pref.setPhone(this.phoneNo);
    pref.setLoginType(loginType);
    print('register success');
    Navigator.of(context).pushReplacementNamed('/home');
    // Navigator.pushReplacement(
    //           context,
    //           MaterialPageRoute(
    //             builder: (context) => DummyHome(),
    //           ),
    //         );
  }

  signIn(smscode,String loginType) {
    print('in sign in..$verificationId / $smsCode');
    try {
      FirebaseAuth.instance
          .signInWithPhoneNumber(
              verificationId: verificationId, smsCode: smsCode)
          .then((user) {
        print("signed User : $user");
        this.register(loginType);
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

  phoneConfirmAlert(_scaffoldKey,String loginType) {
    if (formKey.currentState.validate()) {
      if (this._country_code == null) {
        final snackBar = SnackBar(content: Text("Select country code!"));
        _scaffoldKey.currentState.showSnackBar(snackBar);
        // setState(() {
        //   loginType = '';
        // });
      } else {
        setState(() {
          this.loading = true;
          verifybtn = false;
          this.loadingMsg = "Verifying Your Number";
        });
        formKey.currentState.save();
        verifyPhone(_scaffoldKey,loginType);
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
            padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: SizedBox(
              height: 50.0,
              child: RaisedButton(
                child: Text(
                  'Verify as a user',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                splashColor: Colors.green,
                color: Colors.indigo[900],
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                onPressed: !verifybtn
                    ? null
                    : () {
                        // setState(() {
                        //   loginType = 'user';
                        // });
                        print('${this._country_code}-${this.phoneNo}');
                        phoneConfirmAlert(
                          _scaffoldKey,'users'
                        );
                      },
              ),
            ),
          ),
          verifybtn
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        // setState(() {
                        //   loginType = 'vendor';
                        // });
                        phoneConfirmAlert(
                          _scaffoldKey,'vendors'
                        );
                      },
                      child: Text('verify as a vendor',
                          style: TextStyle(color: Colors.indigo[900])),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 30),
                    )
                  ],
                )
              : SizedBox(
                  height: 0,
                  width: 0,
                )
        ],
      );
    } else {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
              
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
