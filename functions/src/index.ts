import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

export const notify = functions.firestore
    .document('/notify/{idTo}').onCreate(async (snapshot, context) => {
        // console.log('firebase params: ' + context.params);
        // console.log('firebase params: ' + context.params.phone);

        console.log('firebase snap: ' + snapshot.data());

        let data = snapshot.data();
        if (data) {
            console.log('firebase data: ' + data.phone);
            const payload = {
                notification: {
                    title: 'Message from: ' + data.sevice,
                    body: 'About Your Appointment..',//data.body
                    icon: 'https://goo.gl/Fz9nrQ',
                    badge: '1',
                    sound: 'default'
                }
            }

            const db = admin.firestore()
            const devicesRef = db.collection('userTokens').where('id', '==', data.phone);
            const devices = await devicesRef.get();

            const tokens:any = [];
            // send a notification to each device token
            devices.forEach(result => {
                const token = result.data().token;
                console.log('token:' + token);
                tokens.push(token)
            })


            return admin.messaging().sendToDevice(tokens, payload);
        } else {
            return null;
        }

        // console.log('data:'+data.id);
    });
