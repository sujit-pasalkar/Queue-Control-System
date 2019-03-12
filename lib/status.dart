import 'package:flutter/material.dart';

class Status extends StatefulWidget {
  final ScrollController hideButtonController;

  Status({@required this.hideButtonController, Key key}) : super(key: key);

  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Status',
        ),
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          Text('No Status Founf Yet.',style: TextStyle(fontSize: 20,color: Colors.indigo[900]),),
        ],
      )),
    );
  }
}
