import 'package:flutter/material.dart';
import '../SharedPref/SharedPref.dart';
import '../Verification/verification.dart';
import 'homePage.dart';

class DummyHome extends StatefulWidget {
  @override
  _DummyHomeState createState() => _DummyHomeState();
}

class _DummyHomeState extends State<DummyHome> {
  @override
  void initState() {
    check();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
        body: 
        Center(
      child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    ));
  }

  check() async{
    print('login user type :${pref.loginType}');
    if (pref.loginType == 'users') {
     await vrf.getUserDoc();
        print('in getUserDoc future res');
        // Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => HomePage(),
        //       ),
        //     );
      Navigator.of(context).pushReplacementNamed('/home');


    } else {
      var result = await vrf.getVendorDoc();
      print(result);
    
    }
  }
}
