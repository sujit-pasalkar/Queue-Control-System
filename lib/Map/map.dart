import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:queue_control/Select/select.dart';
import 'package:queue_control/SharedPref/SharedPref.dart';

// import 'package:location/location.dart';
// import 'package:queue_control/SharedPref/SharedPref.dart';

class GMap extends StatefulWidget {
  final String docId;

  GMap({@required this.docId});

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<GMap> {
  

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(pref.userLocation['latitude'], pref.userLocation['longitude']),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(pref.userLocation['latitude'], pref.userLocation['longitude']), //18.4655, -73.8547
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

      @override
  void initState() {
    //  location.onLocationChanged().listen((LocationData currentLocation) {
    //   print(currentLocation.latitude);
    //   print(currentLocation.longitude);
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('To the Nearest!'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {

     Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SelectPage(
                                      selectName: widget.docId)));
    
    setState(() {
      pref.currentIndex = 1;
    });
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));

    await Future.delayed(const Duration(seconds: 2));
    pref.currentIndex = 1;
    setState(() {});
    print('out');
  }

 
}
