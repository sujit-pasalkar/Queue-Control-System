import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Select/select.dart';

class HomePage extends StatefulWidget {
  final ScrollController hideButtonController;

  HomePage({@required this.hideButtonController, Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class Choice {
  const Choice({this.title, this.icon});
  final String title;
  final IconData icon;
}

class _HomePageState extends State<HomePage> {
  List<Choice> choices = const <Choice>[
    // const Choice(
    //     title: 'Settings', icon: Icons.settings), //#nav to next(settings page)
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
    // const Choice(title: 'Profile', icon: Icons.person),
  ];
  var listMessage;

  @override
  initState() {}

  //new
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Home',
          ),
          actions: <Widget>[
            new Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
            ),
            PopupMenuButton<Choice>(
              onSelected: onItemMenuPress,
              itemBuilder: (BuildContext context) {
                return choices.map((Choice choice) {
                  return PopupMenuItem<Choice>(
                      value: choice,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            choice.icon,
                          ),
                          Container(
                            width: 10.0,
                          ),
                          Text(
                            choice.title,
                          ),
                        ],
                      ));
                }).toList();
              },
            ),
          ],
        ),
        body: new StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection("vendor")
                .getDocuments()
                .asStream(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return new ListView(children: getServices(snapshot, context));
            }));
  }

  getServices(AsyncSnapshot<QuerySnapshot> snapshot, context) {
    return snapshot.data.documents
        .map((doc) => Column(children: <Widget>[
              Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SelectPage(selectName: 'bank')));
                    },
                    child: Container(
                      height: 115.0,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            left: 50.0,
                            child: serviceCard(doc, context),
                          ),
                          Positioned(top: 7.5, child: serviceImage),
                        ],
                      ),
                    ),
                  )),
              Divider(height: 5.0),
            ]))
        .toList();
  }

  //# after view functions
  logout() {
    FirebaseAuth.instance.signOut().then((action) {
      clearSharedPref();
      Navigator.pushReplacementNamed(context, '/loginpage');
    }).catchError((e) {
      print("*err:*" + e);
    });
  }

  clearSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void onItemMenuPress(Choice choice) {
    if (choice.title == 'Log out') {
      logout();
    }
  }

  //new
  Widget serviceCard(doc, context) {
    return Container(
      width: 290.0,
      height: 115.0,
      child: Card(
        color: Colors.indigo[300],
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
            left: 64.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(doc["name"],
                  style: TextStyle(color: Colors.white, fontSize: 20)
                  ),
              Text('widget.dog.location',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.star,
                    color: Colors.white,
                  ),
                  Text(' :8/10',
                      style: TextStyle(color: Colors.white, fontSize: 15))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget get serviceImage {
    return Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/q.jpg"),
        ),
      ),
    );
  }
}
