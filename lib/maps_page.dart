import 'dart:math';
import './theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sports_buddy/firestore_service.dart';
import './maps_service.dart';
import 'package:provider/provider.dart';
import './authenticator.dart';
import 'dart:io';

class NearbySports extends StatefulWidget {
  const NearbySports({Key? key}) : super(key: key);

  @override
  State<NearbySports> createState() => _NearbySportsState();
}

class _NearbySportsState extends State<NearbySports> {
  GoogleMapController? controller;
  MapService mapService = MapService(Location());
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  LocationData? userLocation;
  IconData setIcons(String type) {
    if (type == "Tennis") return Icons.sports_tennis;
    if (type == "Basketball") return Icons.sports_basketball;
    if (type == "Soccer") return Icons.sports_soccer;
    if (type == "Swimming") return Icons.water;
    return Icons.sports;
  }

  String getDistance(GeoPoint geo) {
    LocationData currentLocation = userLocation!;
    final latDiff = geo.latitude - currentLocation.latitude!;
    final longDiff = geo.longitude - currentLocation.longitude!;
    final distance = sqrt(pow(latDiff, 2)) + pow(longDiff, 2);
    return (distance * 111).toStringAsFixed(1);
  }

  Future<void> setCurrentLocation() async {
    final Location = await mapService.getUserLocation();
    userLocation = Location;
  }

  @override
  void initState() {
    super.initState();
    setCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    setCurrentLocation();

    return Scaffold(
        body: Stack(children: [
      Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder(
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
            })),
      ),
      Positioned(
          top: MediaQuery.of(context).size.height / 3 * 2,
          child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Text("Nearby"),
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        height: MediaQuery.of(context).size.height / 4,
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('activities')
                              .where('active', isEqualTo: true)
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    GeoPoint gp =
                                        snapshot.data!.docs[index]['position'];
                                    var sportIcon = setIcons(
                                        snapshot.data!.docs[index]['type']);
                                    final activityOwner = FirebaseFirestore
                                        .instance
                                        .collection('users')
                                        .where('uid',
                                            isEqualTo: snapshot
                                                .data!.docs[index]['uid'])
                                        .get();
                                    if (userLocation != null)
                                      return InkWell(
                                          onTap: () => {},
                                          child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3.1,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  color: Theme.of(context)
                                                      .scaffoldBackgroundColor,
                                                  boxShadow: [box_shadow]),
                                              margin: EdgeInsets.all(7),
                                              padding: EdgeInsets.all(10),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25),
                                                        color: orange1),
                                                    child: Icon(
                                                      sportIcon,
                                                      size: 30,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(snapshot.data!
                                                      .docs[index]['type']),
                                                  Text(getDistance(gp) + " km"),
                                                ],
                                              )));
                                    return Container();
                                  });
                            }
                            return Container();
                          },
                        ))
                  ]))),
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

  Future<void> animateToLocation(GeoPoint loc) async {
    CameraPosition currentCameraPosition =
        CameraPosition(target: LatLng(loc.latitude, loc.longitude), zoom: 15);
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
