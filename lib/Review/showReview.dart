import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class ShowReview extends StatefulWidget {
  final String serviceName, servicetype;
  ShowReview({@required this.serviceName, @required this.servicetype});
  @override
  _ShowReviewState createState() => _ShowReviewState();
}

class _ShowReviewState extends State<ShowReview> {
 

  @override
  void initState() {
    print('${widget.serviceName},${widget.servicetype}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
      ),
      body:StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('services')
                  .document('${widget.servicetype}')
                  .collection('${widget.servicetype}')
                  .document('${widget.serviceName}')
                  .collection('review')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Center(child: Text('No Reviews'));
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());

                  default:
                    return
                        ListView(children: createChildren(snapshot));
                }
              })
          
    );
  }

  //  Future<Map<String, double>> _getLocation() async {
  //   var currentLocation = <String, double>{};
  //   try {
  //     currentLocation = await location.getLocation();
  //   } catch (e) {
  //     currentLocation = null;
  //   }
  //   return currentLocation;
  // }

  List<Widget> createChildren(snapshot) {
    List<Container> t = [];
    snapshot.data.documents.forEach((f){
      t.add(
        Container(
          child:Column(
            children: <Widget>[
              ListTile(
                leading:CircleAvatar(
                                    child: Icon(Icons.person),
                                    backgroundColor: Colors.grey[300],
                                    radius: 25,
                                  ),
                                  title: Text(f['review']),
              ),
              Divider()
            ],
          )
        )
        // Text(f['review'])
        );
    });
    return t;
  }

}
