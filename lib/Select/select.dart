import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Home/addQ.dart';

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
          widget.selectName.toString().toUpperCase(),
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
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('services')
              .document(widget.selectName)
              .collection(widget.selectName)
              .getDocuments()
              .asStream(), //get doc
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            return ListView(children: getServices(snapshot, context));
          }),
    );
  }

  getServices(AsyncSnapshot<QuerySnapshot> snapshot, context) {
    return snapshot.data.documents
        .map(
          (doc) => GestureDetector(
              onTap: () {
                // print('object');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddQ(
                            serviceName: doc.documentID,
                            servicetype: widget.selectName)));
              },
              child: ListTile(
                leading: CircleAvatar(child: Text(doc.documentID[0]),),
                title: Text(doc.documentID,style: TextStyle(fontSize: 20),),
              )
              
              ))
        .toList();
  }

  // genToken(_scaffoldKey){
  //    final snackBar = SnackBar(content: Text("Token added"));
  //       _scaffoldKey.currentState.showSnackBar(snackBar);
  // }
}
