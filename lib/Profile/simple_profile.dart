import 'package:flutter/material.dart';

class SimpleProfile extends StatefulWidget {
  @override
  _SimpleProfileState createState() => _SimpleProfileState();
}

class _SimpleProfileState extends State<SimpleProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  // decoration: BoxDecoration(shape: BoxShape.circle),
                  decoration: BoxDecoration(
                                color: Colors.grey[300],
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage('no_profile.jpg'),
                                ),
                              ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                   icon: Icon(Icons.camera),
                   onPressed: (){

                   },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
