import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double lat = 0.0;
  double long = 0.0;

  Completer<GoogleMapController> mcontroller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    mcontroller.complete(controller);
  }

  MapType currentMapType = MapType.normal;

  late CameraPosition aposition;

  liveCoordinates() async {
    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        lat = position.latitude;
        long = position.longitude;
        aposition = CameraPosition(
          target: LatLng(lat, long),
        );
      });
    });
  }

  void initState() {
    super.initState();
    Permission.location.request();
    liveCoordinates();
    aposition = CameraPosition(
      target: LatLng(lat, long),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location App'),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () async {
                await openAppSettings();
              },
              icon: Icon(Icons.settings)),
          IconButton(
              onPressed: _onMapTypeButtonPressed,
              icon: Icon(Icons.map_outlined)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          liveCoordinates();
          setState(() {
            aposition = CameraPosition(
              target: LatLng(lat, long),
              zoom: 19,
            );
          });
          final GoogleMapController controller = await mcontroller.future;
          controller.animateCamera(CameraUpdate.newCameraPosition(aposition));
        },
        label: Text('Get Live!'),
        icon: Icon(Icons.gps_fixed_outlined),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined),
                  Text(
                    " Live Co-ordinates : ",
                    style: TextStyle(fontSize: 17, color: Colors.black),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SelectableText(
                        "$lat, $long  ",
                        style:
                            const TextStyle(fontSize: 18, color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mcontroller.complete(controller);
              },
              initialCameraPosition: aposition,
              mapType: currentMapType,
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),
          ),
        ],
      ),
    );
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      currentMapType =
          currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }
}
