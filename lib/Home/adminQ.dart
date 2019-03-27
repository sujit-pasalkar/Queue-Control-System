import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../SharedPref/SharedPref.dart';

class AdminQ extends StatefulWidget {
  final String serviceName;
  final String servicetype;
  AdminQ({
    Key key,
    @required this.serviceName,
    @required this.servicetype,
  });

  @override
  _AdminQState createState() => _AdminQState();
}

class _AdminQState extends State<AdminQ> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    print('${widget.servicetype}, ${widget.serviceName}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('${widget.serviceName.toUpperCase()}'),
      ),
      body: new StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection("services")
              .document(widget.servicetype)
              .collection(widget.servicetype)
              .document(widget.serviceName)
              .collection('tokens')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
                  if (snapshot.hasError)
              return Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Incorrect Service Name',
                        style:
                            TextStyle(fontSize: 20, color: Colors.indigo[900]),
                      ),
                    ],
                  ));

            return snapshot.data.documents.length > 0
                ? ListView(
                    children: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return new Card(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: new Text(
                                  "${document['username'][0].toUpperCase()}${document['username'].substring(1)}"),
                              subtitle: new Text(document['uuid']),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.indigo[900],
                                iconSize: 40,
                                onPressed: () {
                                  deleteToken(
                                      // document['serviceType'],
                                      // document['servicename'],
                                      document['uuid']
                                      );
                                },
                              ),
                            ),
                            ListTile(
                              title: new Text('Booked At'),
                              subtitle: new Text(document['time'].toString()),
                            ),
                            ListTile(
                              title: new Text('Contact'),
                              subtitle: new Text(
                                  document['phone'].toString()),
                            ),
                            ListTile(
                              title: new Text('Address'),
                              subtitle: new Text(
                                  document['address'].toString()),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    // ),
                  )
                : Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'No Status Found Yet.',
                        style:
                            TextStyle(fontSize: 20, color: Colors.indigo[900]),
                      ),
                    ],
                  ));
          }),
    );
  }

  deleteToken(uuid)async{
    //delete from service
    var docRefServ = await Firestore.instance
        .collection('services')
        .document(widget.servicetype)
        .collection(widget.servicetype)
        .document(widget.serviceName)
        .collection('tokens')
        .document(uuid);
  

   Firestore.instance.runTransaction((transaction) async {
      await transaction.delete(docRefServ);
    }).then((onValue) async{
      print('deleted token in serv');
       //increment count
        var docRef = await Firestore.instance
            .collection('services')
            .document(widget.servicetype)
            .collection(widget.servicetype)
            .document(widget.serviceName);
        var queueLen;// = 0;

        await docRef.get().then((onValue) async {
          print(onValue.data['queuelength']);
          queueLen = onValue.data['queuelength'];
        });

        print(queueLen);

        Firestore.instance.runTransaction((transaction) async {
          await transaction.update(
            docRef,
            { 
              'queuelength': queueLen - 1,
            },
          );
        });
    });

}
}