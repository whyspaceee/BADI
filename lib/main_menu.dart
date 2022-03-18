import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sports_buddy/authenticator.dart';
import 'package:sports_buddy/firestore_service.dart';
import 'maps_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Location location = Location();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        MapsWidget(),
        RaisedButton(onPressed: (() => {context.read<AuthService>().signOut()}))
      ],
    ));
  }
}

class MapsWidget extends StatefulWidget {
  const MapsWidget({Key? key}) : super(key: key);

  @override
  State<MapsWidget> createState() => _MapsWidgetState();
}

class _MapsWidgetState extends State<MapsWidget> {
  GoogleMapController? controller;
  Location location = Location();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
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

  _onMapCreated(GoogleMapController mapController) {
    setState(() {
      controller = mapController;
      animateToUser();
    });
  }

  Future<void> animateToUser() async {
    LocationData currentLocation = await location.getLocation();
    CameraPosition currentCameraPosition = CameraPosition(
        target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        zoom: 15);
    controller!
        .animateCamera(CameraUpdate.newCameraPosition(currentCameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(25),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(50))),
      height: 200,
      child: StreamBuilder(
          stream: context
              .read<FirestoreService>()
              .getCollectionStream(collectionName: 'activities'),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              _updateMarkers(snapshot.data!.docs);
            }
            return (GoogleMap(
              zoomControlsEnabled: false,
              compassEnabled: false,
              onMapCreated: _onMapCreated,
              initialCameraPosition: (CameraPosition(
                  target: LatLng(-7.770717, 110.377724), zoom: 15)),
              markers: Set<Marker>.of(markers.values),
            ));
          }),
    );
  }
}

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(50)))),
        Center(
            child: Container(
          child: TextField(),
        ))
      ],
    );
  }
}
