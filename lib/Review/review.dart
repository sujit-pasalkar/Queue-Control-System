import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Review extends StatefulWidget {
  final DocumentSnapshot document;

  Review({@required this.document});
  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  TextEditingController _textEditingController = new TextEditingController();
  bool loading = false;
  @override
  void initState() {
    print('${widget.document['servicename']}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Write Review')),
        body: Container(
            padding: EdgeInsets.all(8),
            child: Column(children: <Widget>[
              Expanded(
                child: TextField(
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  autofocus: true,
                  cursorColor: Color(0xffb00bae3),
                  // maxLength: 25,
                  textCapitalization: TextCapitalization.sentences,
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    // labelText: 'Enter OTP',
                    hintText: "Type your review here",
                  ),
                  onChanged: (messageText) {
                    print(messageText);
                  },
                  onTap: () {
                    print('ontapp.');
                  },
                  // onSubmitted: _textMessageSubmitted,
                ),
              ),
              Container(
                color: _textEditingController.text.length > 0
                    ? Colors.indigo[800]
                    : Colors.grey,
                width: double.infinity,
                child: FlatButton(
                  // color: Colors.indigo[800],
                  child: Text(
                    'post',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onPressed: _textEditingController.text.length > 0
                      ? () {
                          setState(() {
                            loading = true;
                          });
                          post();
                        }
                      : null,
                ),
              )
            ])));
  }

  post() {
    print(widget.document['serviceType']);
    print(widget.document['servicename']);

    try {
      String uuid = Uuid().v1();

      var documentReference = Firestore.instance
          .collection('services')
          .document(widget.document['serviceType'])
          .collection(widget.document['serviceType'])
          .document(widget.document['servicename'])
          .collection('review')
          .document(uuid);

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'review': _textEditingController.text,
          },
        );
      }).then((onValue) async {
        setState(() {
          _textEditingController.text = '';
        });
        print('added');
      });
    } catch (e) {
      print('error in review post:$e');
    }
  }
}
