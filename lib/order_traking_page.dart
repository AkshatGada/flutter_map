import 'dart:async';
import 'dart:js_interop_unsafe';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'constants.dart';



class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  static const LatLng destination = LatLng(37.33429383, -122.06600055);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  void getCurrentLocation (){
    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location ;

    },
    );
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude,sourceLocation.longitude),
      PointLatLng(destination.latitude,destination.longitude),
    );

    if(result.points.isNotEmpty){
      result.points.forEach(
       (PointLatLng point ) => polylineCoordinates.add(
        LatLng(point.latitude,point.longitude),
       ),
      );
      setState(() {});
    }
  }

  @override 
  void initState(){
    getCurrentLocation();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track order",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: currentLocation == null ? Text("Loading") :
      GoogleMap(initialCameraPosition: CameraPosition(target:LatLng(currentLocation!.latitude!, currentLocation!.longitude!) ,zoom: 14.5),
      polylines:{
        Polyline(polylineId: PolylineId("route"),
        points : polylineCoordinates,
        ),
      },
      markers: { Marker(markerId: const MarkerId("currentLocation"),
      position : LatLng(currentLocation!.latitude!, currentLocation!.longitude!) ,),
      const Marker(markerId: MarkerId("source"),
      position : sourceLocation ,),
      const Marker(markerId: MarkerId("destination"),
      position : destination ,),

      },),
    );
  }
}
