import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'Home/dummyHome.dart';
import 'Login/loginPage.dart';
import 'VendorForm/form.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'SharedPref/SharedPref.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        debugShowCheckedModeBanner: false, //true
        title: 'QueueC',
        home: new MainPage(),
        theme: ThemeData(
          // primarySwatch: Colors.lightBlue, //
          brightness: Brightness.light,
          primaryColor: Colors.indigo[
              900], //Color.fromRGBO(58, 66, 86, 1.0),//Colors.lightBlue[800],
          accentColor: Colors.blue[900],
          // textTheme: TextTheme(
          //   headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold,color: ),
          //   title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          //   body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          // ),
        ),
        routes: <String, WidgetBuilder>{
          '/loginpage': (BuildContext context) => LoginPage(),
          '/home': (BuildContext context) => Home(),
          '/dummyHome': (BuildContext context) => DummyHome(),
          '/formPage': (BuildContext context) => FormPage(),
        });
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage>
// with SingleTickerProviderStateMixin
{
  //#Animation
  // AnimationController _logoAnimationCtrl;
  // Animation<double> _iconAnimationBounce;
  // CurvedAnimation _iconAnimation; //

  //#connectivity
  var _connectionStatus = 'Unknown';
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;

  bool isLoggedIn;
  String userPhone;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // super.initState();
    // print('init main....${isLoggedIn}');
    //#iconAnimation
    // _logoAnimationCtrl = AnimationController(
    //     duration: const Duration(milliseconds: 3000), vsync: this);
    // _iconAnimation = CurvedAnimation(
    //     parent: _logoAnimationCtrl, curve: Curves.easeIn /* bounceOut */);
    // _iconAnimationBounce =
    //     CurvedAnimation(parent: _logoAnimationCtrl, curve: Curves.bounceOut);
    // _iconAnimation.addListener(() => this.setState(() {}));
    // _iconAnimationBounce.addListener(() => this.setState(() {}));
    // _logoAnimationCtrl.forward();

    isLoggedIn = false;

    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectionStatus = result.toString();
      });
      print("..." + _connectionStatus);
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        setState(() {
          print('got connection');
          FirebaseAuth.instance.currentUser().then((user) => user != null
              ? setState(() {
                  isLoggedIn = true;
                })
              : null);
          _loadUserState().then((result) {
            this.checkUserProfile();
          });
        });
      }
      if (result == ConnectivityResult.none) {
        print('no  internet');
      }
    });
  }

  _loadUserState() async {
    print('init loadUserState()....');
    //#check phone no in mobile locale storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      this.userPhone = (prefs.getString('userPhone') ?? null);
      print('in userPhone: $userPhone');
    });

    pref.getValues();
  }

  Future<void> checkUserProfile() async {
    print('in checking user profile:${this.userPhone}');
    if (this.isLoggedIn == true || userPhone != null) {
      //not correct condition
      print('you are login(firebase)');
      Navigator.of(context).pushReplacementNamed('/dummyHome');
      // Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => DummyHome(),
      //         ),
      //       );
    } else {
      print('you are not login');
      Navigator.of(context).pushReplacementNamed('/loginpage');
    }
  }

  loadingSpinner(_scaffoldKey) {
    //make it future build
    print('internet : $_connectionStatus');
    if (this._connectionStatus == 'ConnectivityResult.none' ||
        this._connectionStatus == 'Unknown') {
      return Container(
          child: Column(children: <Widget>[
        Text(
          "No Internet Connection",
          style: TextStyle(
            fontStyle: FontStyle.italic,
            // fontFamily: 'Raleway',
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
        Padding(padding: EdgeInsets.all(10.0)),
        CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation(Colors.white),
        ),
      ]));
    } else {
      return Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(fit: StackFit.expand, children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // Where the linear gradient begins and ends
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // Add one stop for each color. Stops should increase from 0 to 1
              stops: [0.3, 0.4, 0.5, 0.6, 0.7, 0.8],
              colors: [
                // Colors are easy thanks to Flutter's Colors class.
                Colors.indigo[900],
                Colors.deepPurple[900],
                Colors.indigo[800],
                Colors.deepPurple[800],
                Colors.indigo[700],
                Colors.blue[900],
              ],
            ),
          ),
        ),
        Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Expanded(
              flex: 2,
              child: Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Text(
                      "Queue Control System",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 40.0,
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(10.0)),
                    Text(
                      "Managing Q",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0,
                        // fontFamily: qa
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 40.0)),
                    // FadeTransition(
                    //   opacity: _iconAnimation,
                    //   child:
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 60.0,
                      child: Icon(
                        Icons.group,
                        color: Colors.indigo[900],
                        size: 80.0,
                      ),
                    ),
                    // ),
                    Padding(padding: EdgeInsets.all(40.0)),
                    loadingSpinner(_scaffoldKey),
                  ])))
        ])
      ]),
    );
  }
}
