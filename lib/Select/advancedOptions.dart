import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:queue_control/SharedPref/SharedPref.dart';
import 'package:uuid/uuid.dart';

class AdvancedOptions extends StatefulWidget {
  final String serviceName, servicetype;
 final int timePerService;

  AdvancedOptions(
      {@required this.serviceName,
      @required this.servicetype,
      @required this.timePerService});
  @override
  _AdvancedOptionsState createState() => _AdvancedOptionsState();
}

class _AdvancedOptionsState extends State<AdvancedOptions> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  List options = [];
  List optionsName = [];

  @override
  void initState() {
    print('${widget.servicetype}');
    if (widget.servicetype == 'bank') {
      optionsName = [
        'Apply for Loan',
        'Overdraft',
        'Discounting of Bills of Exchange',
        'Check/Cheque Payment',
        'Collection and Payment Of Credit Instruments',
        'Foreign Currency Exchange',
        'Consultancy',
        'Bank Guarantee',
        'Remittance of Funds',
        'Credit cards',
        'ATMs Services',
        'Debit cards',
        'Home banking application',
        'Online banking application',
        'Mobile Banking application',
        'Accepting Deposit'
      ];
    } else if (widget.servicetype == 'clinic') {
      optionsName = [
        'Ask for Doctor',
        'Ask for Surgeon',
        'OPD appointment',
        'Dentist appointment',
        'Gynecologist appointment',
        'Dietition/Nutrition',
        'Physiotherapist appointment',
        'Health Checkup',
        'Diagnostic test',
        'Medicine related'
      ];
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Choose specific option'),
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                widget.servicetype == 'bank'
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: optionsName.length,
                          itemBuilder: (BuildContext ctxt, int i) {
                            return ListTile(
                                onTap: () {
                                  if (options.contains(i)) {
                                    options.remove(i);
                                  } else {
                                    options.add(i);
                                  }
                                  setState(() {});
                                },
                                leading: options.contains(i)
                                    ? Icon(
                                        Icons.add_box,
                                        color: Colors.indigo[800],
                                      )
                                    : Icon(
                                        Icons.add_box,
                                      ),
                                title: Text(optionsName[i]),
                                trailing: options.contains(i)
                                    ? Icon(
                                        Icons.check_circle,
                                        color: Colors.indigo[800],
                                      )
                                    : SizedBox(),
                                selected: options.contains(i));
                          },
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: optionsName.length,
                          itemBuilder: (BuildContext ctxt, int i) {
                            return ListTile(
                                onTap: () {
                                  if (options.contains(i)) {
                                    options.remove(i);
                                  } else {
                                    options.add(i);
                                  }
                                  setState(() {});
                                },
                                leading: options.contains(i)
                                    ? Icon(
                                        Icons.add_box,
                                        color: Colors.indigo[800],
                                      )
                                    : Icon(
                                        Icons.add_box,
                                      ),
                                title: Text(optionsName[i]),
                                trailing: options.contains(i)
                                    ? Icon(
                                        Icons.check_circle,
                                        color: Colors.indigo[800],
                                      )
                                    : SizedBox(),
                                selected: options.contains(i));
                          },
                        ),
                      ),
                Container(
                  color: options.length > 0 ? Colors.indigo[800] : Colors.grey,
                  width: double.infinity,
                  child: FlatButton(
                    // color: Colors.indigo[800],
                    child: Text(
                      'Add me in Queue',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onPressed: options.length > 0
                        ? () {
                            setState(() {
                              loading = true;
                            });
                            addInService();
                          }
                        : null,
                  ),
                )
              ],
            ),
          ),
        ),
        loading
            ? Container(
                decoration: BoxDecoration(color: Colors.black54),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Color(0xffb00bae3)),
                  ),
                ))
            : SizedBox(),
      ],
    );
  }

  addInService() async {
    try {
      String uuid = Uuid().v1();

//in service name
      var documentReference = Firestore.instance
          .collection('services')
          .document(widget.servicetype)
          .collection(widget.servicetype)
          .document(widget.serviceName)
          .collection('tokens')
          .document(uuid);

      //increment count
      var docRef = await Firestore.instance //
          .collection('services')
          .document(widget.servicetype)
          .collection(widget.servicetype)
          .document(widget.serviceName);

      var queueLen = 0;

      await docRef.get().then((onValue) async {
        // print(onValue.data['queuelength']);
        queueLen = onValue.data['queuelength'];
        if (onValue.data['queuelength'] < 0) {
          queueLen = 0;
        } else {
          queueLen = onValue.data['queuelength'];
        }
      });

      Firestore.instance.runTransaction((transaction) async {
        await transaction.update(
          docRef,
          {
            'queuelength': queueLen + 1,
          },
        );
      }).then((onValue) {
        Firestore.instance.runTransaction((transaction) async {
          await transaction.set(
            documentReference,
            {
              'uuid': uuid,
              'username': pref.name,
              'address': pref.address,
              'phone': pref.phone,
              'time': FieldValue.serverTimestamp(),
              'averageWaitingTime': queueLen * widget.timePerService
            },
          );
        }).then((onValue) async {
          //in user side
          var userDocRef = Firestore.instance
              .collection('users')
              .document(pref.phone)
              .collection('tokens')
              .document(uuid);

          Firestore.instance.runTransaction((transaction) async {
            await transaction.set(
              userDocRef,
              {
                'uuid': uuid,
                'serviceType': widget.servicetype,
                'servicename': widget.serviceName,
                // 'phone': pref.phone,
                'time': FieldValue.serverTimestamp(),
                'averageWaitingTime': queueLen * widget.timePerService
              },
            );
          }).then((onValue) async {});

          final snackBar = SnackBar(
              content: Text("Token added in Queue"),
              backgroundColor: Colors.green);
          _scaffoldKey.currentState.showSnackBar(snackBar);
          Navigator.pop(context);
        });
      });
    } catch (e) {
      print('Got Err : $e');
    }
  }
}
