import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import '../SharedPref/SharedPref.dart';

final Verification vrf = new Verification();

class Verification {
  Future getUserDoc() async {
    try {
      //go to user collection get user info and set it
      //if user not found in user collection then create new document
      //and redirect to user home screen
      print('in getuser doc phn: ${pref.phone}');

//       final DocumentReference postRef = Firestore.instance.document('posts/123');
// Firestore.instance.runTransaction((Transaction tx) async {
//   DocumentSnapshot postSnapshot = await tx.get(postRef);
//   if (postSnapshot.exists) {
//     await tx.update(postRef, <String, dynamic>{'likesCount': postSnapshot.data['likesCount'] + 1});
//   }
// });

     await Firestore.instance
          .collection('users')
          .getDocuments()
          .then((onValue) async {
        bool found = false;
        await onValue.documents.forEach((f) {
          print(f.documentID);
          if (f.documentID == pref.phone) {
            found = true;
          }
        });
        print('user:$found');
        if(!found){
          await setNewUser();
        }else{
          print('old user so not set');
        }
      });

      

      // Firestore.instance
      //     .collection('user') //pref.userType
      //     .where("phone", isEqualTo: pref.phone)
      //     .snapshots()
      //     .listen((data) async {
      //  await data.documents.forEach((doc) {
      //     print('found:' + doc["phone"]);
      //     found = true;
      //   });
      // });
      // // .onError((handleError){
      // //   print('user query err: $handleError');
      // // });

      // // .onDone(() {
      // //   if (found) {
      // //     print('found: ${pref.phone}');
      // //   } else {
      // //     print('not found');
      // //   }
      // // });
    } catch (e) {
      print('getUserDoc err ; $e');
    }
  }

  setNewUser()async{
    var documentReference =
          Firestore.instance.collection('users').document(pref.phone);
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
      });
        print('added..');
  }

 

 Future<String> getVendorDoc() async {
    //1.go to vendor collection get vendor info and set it
    //2.if vendor verified then according to its type(bank,hospital,atm)redirect to screen
    //3.if not verified and form submitted then redirect to waitForVerification page
    //   else vendor registration page

    //1.if vendor phone not found in vendor collection then create new vendor document
    //2.redirect it to vendor registration page
    //3.after filling registration form redirect to waitForVerification page//

    try {
      print('in getVendor doc phn: ${pref.phone}');
      // Firestore.instance.collection('venords').document(pref.phone).get();
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
      // String ret = await Firestore.instance
      //     .collection('vendors').document(pref.phone).updateData(
      //       {'queue':[][idx]['status'][true]
      //       })
      //     .then((onValue){
      //       return 'saved';
      //     });
      //     return ret;
  final DocumentReference postRef = Firestore.instance.document('vendors/${pref.phone}');
      await Firestore.instance.runTransaction((Transaction tx) async {
            DocumentSnapshot snapshot =
                await tx.get(postRef);
            var doc = snapshot.data;
            print(doc['queue'][idx]['status'].toString());
            // if (doc['queue'][idx].contains(timestamp)) {
            // print('yes');
              await tx.update(snapshot.reference, <String, dynamic>{
                doc['queue'][idx]['status']: true
              });
            // } 
            // else {
            //   await tx.update(snapshot.reference, <String, dynamic>{
            //     'upvoters': FieldValue.arrayUnion(['12345'])
            //   });
            // }
          });


    } catch (e) {
      return 'error';
    }
  }
}
