import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../SharedPref/SharedPref.dart';

final Verification vrf = new Verification();

class Verification {
  Future<String> getUserDoc() async {
    try {
      print('in getuser doc phn: ${pref.phone}');

    String ret =  await Firestore.instance
          .collection('users')
          .getDocuments()
          .then((onValue) async {
        bool found = false;
        await onValue.documents.forEach((f) {
          print(f.documentID);
          if (f.documentID == pref.phone) {
            found = true;
            return 'old';
          }
        });
        print('user:$found');
        if(!found){
          String ret = await setNewUser();
          return ret;
        }
        // else{
        //   print('old user so not set');
        // }
      });
      return ret;

    } catch (e) {
      print('getUserDoc err ; $e');
      return 'err';
    }
  }

  Future<String>setNewUser()async{
    var documentReference =
          Firestore.instance.collection('users').document(pref.phone);

     String ret = 
     await Firestore.instance.runTransaction((transaction) async {
        await transaction
        .set(
          documentReference,
          {
            'phone': pref.phone,
            'name': '',
            'email': '',
            'addr': '',
          },
        );
      }).then((onValue){
        return 'new';
      });

      return ret;
  }

 

 Future<String> getVendorDoc() async {
    try {
      print('in getVendor doc phn: ${pref.phone}');
     String ret = await Firestore.instance
          .collection('vendors')
          .getDocuments()
          .then((onValue) async {
        bool found = false;
        await onValue.documents.forEach((f) {
          print(f.documentID);
          if (f.documentID == pref.phone) {
            found = true;
          }
          if (f.documentID == pref.phone) {
            found = true;
          }
        }
        );
        print('user:$found');
        if(!found){
          await setNewVendor();
          return 'form';
        }else{
          print('old user so not set');
          // return 'old';
         String res =  await checkVendorInfo();
         return res;
        }
      });

      return ret;
    } catch (e) {
      print('getUserDoc err ; $e');
      return 'err';
    }
  }

  setNewVendor()async{
    var documentReference =
          Firestore.instance.collection('vendors').document(pref.phone);
      await Firestore.instance.runTransaction((transaction) async {
        await transaction
        .set(
          documentReference,
          {
            'phone': pref.phone,
            'type':null,
            'address':'',
            'verify':false,
            'name':'',
            'email': '',
            'queue':[],
            'submission':false
          },
        );
      });
        print('added..');
  }

 Future<String>checkVendorInfo()async{
    try{
      String ret = await Firestore.instance
          .collection('vendors').document(pref.phone).get().then((onValue)async{
            // onValue['verify'];
            if(onValue['verify']){ //return vendor 'verifed' and venor home screen where he can manage Q
                return 'verified';
            }
            else{
              return 'form';
            }
            // print(onValue);
          });
          return ret;
    }catch(e){
      print('checkVendorInfo err ; $e');
      return 'err';
    }
  }

 Future<String> registerVendor(nm,email,addr,typ,clinc_name) async{
    try {
      print('$nm , $email , ${pref.phone} , $typ');
      String ret = await Firestore.instance
          .collection('vendors').document(pref.phone).updateData(
            {'dr_name':nm,
            'email':email,
            'address':addr,
            'type':typ,
            'submission':true,
            'clinic_name':clinc_name
            })
          .then((onValue){
            return 'saved';
          });
          return ret;
    } catch (e) {
      return 'error';
    }
  }

 Future<String> updateStatus(timestamp,idx) async{
   try {
      print('tm:$timestamp');
  final DocumentReference postRef = Firestore.instance.document('vendors/${pref.phone}');
      await Firestore.instance.runTransaction((Transaction tx) async {
            DocumentSnapshot snapshot =
                await tx.get(postRef);
            var doc = snapshot.data;
            print(doc['queue'][idx]['status'].toString());
              await tx.update(snapshot.reference, <String, dynamic>{
                doc['queue'][idx]['status']: true
              });
          });

    } catch (e) {
      return 'error';
    }
  }
}
