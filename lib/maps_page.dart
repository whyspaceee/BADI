import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sports_buddy/firestore_service.dart';
import './maps_service.dart';
import 'package:provider/provider.dart';
import './authenticator.dart';

class NearbySports extends StatefulWidget {
  const NearbySports({Key? key}) : super(key: key);

  @override
  State<NearbySports> createState() => _NearbySportsState();
}

class _NearbySportsState extends State<NearbySports> {
  GoogleMapController? controller;
  MapService mapService = MapService(Location());
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      StreamBuilder(
        stream: context
            .read<FirestoreService>()
            .getCollectionStream(collectionName: 'activities'),
        builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            _updateMarkers(snapshot.data!.docs);
          }
          return GoogleMap(
            onMapCreated: _onMapCreated,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
                target: LatLng(-7.771325363128137, 110.37763754446743),
                zoom: 15),
            markers: Set<Marker>.of(markers.values),
          );
        }),
      ),
      Positioned(
          left: 50,
          bottom: 50,
          child: RaisedButton(onPressed: () async {
            LocationData locData = await mapService.getUserLocation();
            GeoPoint geo = GeoPoint(locData.latitude!, locData.longitude!);
            FirebaseFirestore.instance.collection('activities').add({
              'position': geo,
              'uid': Provider.of<User?>(context, listen: false)?.uid
            });
          })),
      Positioned(
          child: RaisedButton(
        child: Text("Sign Out"),
        onPressed: () => {
          context.read<AuthService>().signOut(),
          Navigator.popUntil(context, ModalRoute.withName('/'))
        },
      )),
    ]));
  }

  _onMapCreated(GoogleMapController mapController) {
    setState(() {
      controller = mapController;
      animateToUser();
    });
  }

  Future<void> animateToUser() async {
    LocationData currentLocation = await mapService.getUserLocation();
    CameraPosition currentCameraPosition = CameraPosition(
        target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        zoom: 15);
    controller!
        .animateCamera(CameraUpdate.newCameraPosition(currentCameraPosition));
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    markers.clear();
    documentList.forEach((DocumentSnapshot document) {
      final MarkerId markerId = MarkerId(document.id);
      GeoPoint pos = document['position'];
      var marker = Marker(
        markerId: markerId,
        position: LatLng(pos.latitude, pos.longitude),
        icon: BitmapDescriptor.defaultMarker,
      );
      markers[markerId] = marker;
    });
  }
}
