import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectPage extends StatefulWidget {
  final String selectName;
  SelectPage({
    Key key,
    @required this.selectName,
  });

  @override
  _SelectPageState createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  var listMessage;
    var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Select',
        ),
        // actions: <Widget>[
        //   new Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 5.0),
        //   ),
        //   PopupMenuButton<Choice>(
        //     onSelected: onItemMenuPress,
        //     itemBuilder: (BuildContext context) {
        //       return choices.map((Choice choice) {
        //         return PopupMenuItem<Choice>(
        //             value: choice,
        //             child: Row(
        //               children: <Widget>[
        //                 Icon(
        //                   choice.icon,
        //                   // color: primaryColor,
        //                 ),
        //                 Container(
        //                   width: 10.0,
        //                 ),
        //                 Text(
        //                   choice.title,
        //                   // style: TextStyle(color: primaryColor),
        //                 ),
        //               ],
        //             ));
        //       }).toList();
        //     },
        //   ),
        // ],
      ),
      body: body(),
      // StreamBuilder<QuerySnapshot>(
      //   stream: Firestore.instance.collection('vendor').snapshots(), //get doc
      //   builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      //     if (!snapshot.hasData) {
      //       return Center(child: CircularProgressIndicator());
      //     } else {
      //       listMessage = snapshot.data.documents;
      //       return ListView.builder(
      //         padding: EdgeInsets.all(10.0),
      //         itemBuilder: (context, index) =>
      //             buildItem(index, snapshot.data.documents[index]),
      //         itemCount: snapshot.data.documents.length,
      //         reverse: true,
      //       );
      //     }
      //   },
      // ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['type'] == widget.selectName) {
      // return Container(
      // child: Column(
      // children: <Widget>[
      return Text(document['name']);
      // ],
      // ),
      // );
    }
  }

  Widget body() {
    if (widget.selectName == 'bank') {
      return Container(
        padding: EdgeInsets.all(6),
          child: Card(
              child: new Row(children: <Widget>[
        Expanded(
          child: Text('State Bank Of India',),
        ),
        FlatButton(
          child: Text(
            'Get Token',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          splashColor: Colors.green,
          color: Colors.indigo[900],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          onPressed: () {
            genToken(_scaffoldKey);
          },
        )
      ])),
      );
      // return Container(
      //   child: Column(
      //     children: <Widget>[
      //       Text('State Bank Of India'),
      //       FlatButton(
      //         child: Text(
      //           'Get Token',
      //           style: TextStyle(color: Colors.white, fontSize: 18),
      //         ),
      //         splashColor: Colors.green,
      //         color: Colors.indigo[900],
      //         shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(30.0)),
      //         onPressed: () {},
      //       )
      //     ],
      //   ),
      // );
    } else if (widget.selectName == 'hospital') {
      return Container(
        padding: EdgeInsets.all(6),
          child: Card(
              child: new Row(children: <Widget>[
        Expanded(
          child: Text('Bharti hhospital',),
        ),
        FlatButton(
          child: Text(
            'Get Token',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          splashColor: Colors.green,
          color: Colors.indigo[900],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          onPressed: () {
            genToken(_scaffoldKey);
          },
        )
      ])),
      );

    } else {
      return Container(
        padding: EdgeInsets.all(6),
          child: Card(
              child: new Row(children: <Widget>[
        Expanded(
          child: Text('Kotak Mahindra ATM',),
        ),
        FlatButton(
          child: Text(
            'Get Token',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          splashColor: Colors.green,
          color: Colors.indigo[900],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          onPressed: () {
            genToken(_scaffoldKey);
          },
        )
      ])),
      );
    }
  }

  genToken(_scaffoldKey){
     final snackBar = SnackBar(content: Text("Token added"));
        _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
