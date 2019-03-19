import 'package:flutter/material.dart';
import '../SharedPref/SharedPref.dart';
import '../Verification/verification.dart';
import 'homePage.dart';
import '../VendorForm/form.dart';

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
      // Navigator.of(context).pushReplacementNamed('/home');
      Navigator.of(context)
    .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);


    } else {
      var result = await vrf.getVendorDoc();
      print(result);//form verified err
      if(result == 'form'){
      // Navigator.of(context).pushReplacementNamed('/formPage');
       Navigator.of(context)
    .pushNamedAndRemoveUntil('/formPage', (Route<dynamic> route) => false);

        // Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => FormPage(),
        //       ),
        //     );
      }
    
    }
  }
}
