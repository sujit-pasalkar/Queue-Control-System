import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:queue_control/SharedPref/SharedPref.dart';
import 'package:uuid/uuid.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

var uuid = new Uuid();

class Chat extends StatefulWidget {
  final int servicePhone;
  final String serviceName, userPhone, sender;
  Chat(
      {@required this.servicePhone,
      this.serviceName,
      this.userPhone,
      @required this.sender});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  bool textSending = false;
  String searchText = "";
  bool isLoading;
  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  List<dynamic> listMessage;
  String userP;

  @override
  void initState() {
    isLoading = false;
    print(
        'in chatpage :${widget.servicePhone}, ${widget.serviceName} , ${widget.userPhone}');
    if (widget.userPhone == null) //
      userP = pref.phone;
    else
      userP = widget.userPhone;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceName),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

              // Input content
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('chats')
            .document(widget.servicePhone.toString() + "~" + userP)
            .collection(widget.servicePhone.toString() + "~" + userP)
            .orderBy('timestamp', descending: true)
            // .limit(12)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.indigo[900])));
          } else {
            listMessage = snapshot.data.documents;

            print('-----listMessage----${listMessage.length}');
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(3.0, 10.0, 5.0, 0.0),
              itemBuilder: (context, index) =>
                  buildItem(index, listMessage[index]
                      //             // snapshot.data.documents[index]
                      ),
              itemCount: listMessage.length,
              //     // snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    print("in........................... :" + document['sender']);
    if (document['sender'] == 'user') {
      // print("in :" + document['sender']);
      // Right (my message)
      return Stack(
        children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            Container(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(document['senderName'],
                            style: new TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                      Text(DateFormat('dd MMM kk:mm')
                          .format(document['timestamp'])),
                    ],
                  ),
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      document['msg'],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 4.0),
              width: 200.0,
              margin: EdgeInsets.only(
                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
              ),
              // ),
            ),
            // : SizedBox(height: 0, width: 0),
          ])
        ],
      );
    } else {
      // Left (peer message)
      print("in services :" + document['sender']);
      return Container(
          child: Column(children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,          
          children: <Widget>[
          Container(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(document['senderName'],
                          style: new TextStyle(
                              fontSize: 12.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(DateFormat('dd MMM kk:mm')
                        .format(document['timestamp'])),
                  ],
                ),
                new Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    document['msg'],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 4.0),
            width: 200.0,
            decoration: BoxDecoration(
                color: Colors.indigo[100],
                borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(
                bottom: isLastMessageRight(index) ? 15.0 : 10.0, left: 5.0),
          )
        ])
      ]));
      //
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['senderPhone'] != pref.phone) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget buildInput() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(50.0)),
                  padding: EdgeInsets.all(15.0),
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: Color(0xffb00bae3),
                    style: TextStyle(fontSize: 15.0),
                    controller: textEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    onChanged: (input) {
                      print(input.length);
                      // if (input.length >= 1) {
                      //   setState(() {
                      //     this.isSearching = true;
                      //   });
                      //   searchOperation(input);
                      // } else {
                      //   stop();
                      // }
                    },
                    // onTap: () {
                    //   print('ontap-');
                    //   setState(() {
                    //     this.isSearching = true;
                    //   });
                    //   searchOperation('a');
                    // },
                  ),
                ),
              ),
              // Button send message
              Container(
                decoration: BoxDecoration(
                    color: Colors.indigo[900],
                    borderRadius: BorderRadius.circular(50.0)),
                margin: new EdgeInsets.symmetric(horizontal: 8.0),
                child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: !textSending
                      ? () {
                          onTextMessage(textEditingController.text, 0);
                        }
                      : null,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
          ),
        ],
      ),
      width: double.infinity,
      // height: isSearching == true ? 70.0 : 105.0,
      decoration: new BoxDecoration(
        border: new Border(top: new BorderSide(color: Colors.grey, width: 0.9)),
        color: Colors.white,
      ),
    );
  }

  void onTextMessage(String content, int type) async {
    print('in onText');
    try {
      setState(() {
        textSending = true;
      });

      if (content.trim() != '') {
        textEditingController.clear();
        String uuid = Uuid().v1();
        var documentReference = Firestore.instance
            .collection('chats')
            .document(widget.servicePhone.toString() + "~" + userP)
            .collection(widget.servicePhone.toString() + "~" + userP)
            .document(uuid);
        Firestore.instance.runTransaction((transaction) async {
          await transaction.set(
            documentReference,
            {
              'senderPhone':
                  widget.userPhone == null ? pref.phone : widget.servicePhone,
              'sender': widget.sender,
              // 'senderId': this.myId,
              // 'idTo': widget.peerId,
              'timestamp': FieldValue.serverTimestamp(),
              'msg': content,
              'type': type,
              // 'members': groupMembersArr,
              'senderName': widget.sender == 'user' ?widget.userPhone  :widget.serviceName
              // pref.name == '' ? widget.userPhone  : pref.name .
              // widget.userPhone == null ? pref.name : widget.serviceName
              // 'groupName': widget.name
            },
          );
        }).then((onValue) {
          print('$content sent');
          setState(() {
            textSending = false;
          });
        });
        listScrollController.animateTo(0.0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      } else {
        Fluttertoast.showToast(msg: 'Nothing to send');
        setState(() {
          textSending = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error while sending');
      setState(() {
        textSending = false;
      });
    }
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Color(0xffb00bae3))),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }
}
//msgtype
//senedernm
//senderPhone
