import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:queue_control/SharedPref/SharedPref.dart';
import 'package:uuid/uuid.dart';

import 'package:fluttertoast/fluttertoast.dart';

// import 'package:image_picker/image_picker.dart';
var uuid = new Uuid();

class Chat extends StatefulWidget {
  final int servicePhone;
  final String serviceName;
  Chat({@required this.servicePhone, this.serviceName});

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

  @override
  void initState() {
    isLoading = false;

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
            .document(widget.servicePhone.toString() + "~" + pref.phone)
            .collection(widget.servicePhone.toString() + "~" + pref.phone)
            // .orderBy('timestamp', descending: true)
            // .limit(12)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Color(0xffb00bae3))));
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
    if (document['sender'] == 'user') {
      // Right (my message)
      return Stack(
        children: <Widget>[
          Row(children: <Widget>[
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
                      Text(document['timestamp'].toString()),
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
                color: Colors.grey,
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
      return Container(
          child: Column(children: <Widget>[
        Row(children: <Widget>[
          Expanded(
            child: Text(document['senderName'],
                style: new TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
          ),
          Text(document['timestamp']),
        ])
      ]));
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
          // !isSearching
          //     ? Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //         children: <Widget>[
          //           Material(
          //             child: new Container(
          //               margin: new EdgeInsets.symmetric(horizontal: 1.0),
          //               child: new IconButton(
          //                 icon: new Icon(Icons.image),
          //                 onPressed: getGalleryImage,
          //                 color: primaryColor,
          //               ),
          //             ),
          //             color: Colors.white,
          //           ),
          //           Material(
          //             child: new Container(
          //               margin: new EdgeInsets.symmetric(horizontal: 1.0),
          //               child: new IconButton(
          //                 icon: new Icon(Icons.video_library),
          //                 onPressed: getGalleryVideo,
          //                 color: primaryColor,
          //               ),
          //             ),
          //             color: Colors.white,
          //           ),
          //           Material(
          //             child: new Container(
          //               margin: new EdgeInsets.symmetric(horizontal: 1.0),
          //               child: new IconButton(
          //                 icon: new Icon(Icons.photo_camera),
          //                 onPressed: getCameraImage,
          //                 color: primaryColor,
          //               ),
          //             ),
          //             color: Colors.white,
          //           ),
          //           Material(
          //             child: new Container(
          //               margin: new EdgeInsets.symmetric(horizontal: 1.0),
          //               child: new IconButton(
          //                 icon: new Icon(Icons.videocam),
          //                 onPressed: getCameraVideo,
          //                 color: primaryColor,
          //               ),
          //             ),
          //             color: Colors.white,
          //           ),
          //         ],
          //       )
          //     : Text(''),
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(50.0)),
                  padding: EdgeInsets.all(15.0),
                  child:
                      // GestureDetector(
                      // child:
                      TextField(
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: Color(0xffb00bae3),
                    style: TextStyle(fontSize: 15.0),
                    controller: textEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    // focusNode: focusNode,
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
                  // )
                ),
              ),
              // Button send message
              Container(
                decoration: BoxDecoration(
                    color: Color(0xffb00bae3),
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
    setState(() {
      textSending = true;
    });
    // var result = await http.get('http://oyeyaaroapi.plmlogix.com/time');
    // var res = jsonDecode(result.body);
    // timestamp = res['timestamp'];

    if (content.trim() != '') {
      textEditingController.clear();
      String uuid = Uuid().v1();
      var documentReference = Firestore.instance
          .collection('chats')
          .document(widget.servicePhone.toString() + "~" + pref.phone)
          .collection(widget.servicePhone.toString() + "~" + pref.phone)
          .document(uuid);
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'senderPhone': pref.phone,
            'sender': 'user',
            // 'senderId': this.myId,
            // 'idTo': widget.peerId,
            'timestamp': FieldValue.serverTimestamp(),
            'msg': content,
            'type': type,
            // 'members': groupMembersArr,
            'senderName': pref.name
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
