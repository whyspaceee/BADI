import 'dart:math';
import 'package:sports_buddy/models/user_model.dart';
import 'package:sports_buddy/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sports_buddy/services/firestore_service.dart';
import '/services/maps_service.dart';
import 'package:provider/provider.dart';
import 'package:sports_buddy/models/activity_model.dart';
import '/services/authenticator.dart';
import 'dart:io';
import 'package:sports_buddy/utils/set_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NearbySports extends StatefulWidget {
  const NearbySports({Key? key}) : super(key: key);

  @override
  State<NearbySports> createState() => _NearbySportsState();
}

class _NearbySportsState extends State<NearbySports> {
  GoogleMapController? controller;
  MapService mapService = MapService(Location());
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Future<LocationData>? userLocation;
  ScrollController scrollController = ScrollController();

  String getDistance(GeoPoint geo, LocationData currentLocation) {
    final latDiff = geo.latitude - currentLocation.latitude!;
    final longDiff = geo.longitude - currentLocation.longitude!;
    final distance = sqrt(pow(latDiff, 2)) + pow(longDiff, 2);
    return (distance * 111).toStringAsFixed(1);
  }

  Future<void> setCurrentLocation() async {
    userLocation = mapService.getUserLocation();
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
                        child: FutureBuilder(
                            future: userLocation,
                            builder:
                                (context, AsyncSnapshot<LocationData> loc) {
                              if (loc.hasData) {
                                animateToUser();
                                return FutureBuilder(
                                    future: context
                                        .read<FirestoreService>()
                                        .getNearbyActivities(loc.data!),
                                    builder: (context,
                                        AsyncSnapshot<List<NearbyActivities>>
                                            nearbyActivities) {
                                      if (nearbyActivities.hasData) {
                                        return NotificationListener(
                                          child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              controller: scrollController,
                                              itemCount:
                                                  nearbyActivities.data!.length,
                                              itemBuilder: (context, index) {
                                                var sportIcon = setIcons(
                                                    nearbyActivities.data!
                                                        .elementAt(index)
                                                        .type!);
                                                return ActivitiesWidget(
                                                    scrollController,
                                                    nearbyActivities.data!
                                                        .elementAt(index),
                                                    sportIcon,
                                                    animateToLocation,
                                                    index);
                                              }),
                                          onNotification: (notification) {
                                            if (notification
                                                is ScrollNotification) {
                                              final offset =
                                                  scrollController.offset;
                                              final size =
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3.1;
                                              final widgetNum =
                                                  ((offset + 15) / size)
                                                      .toInt();
                                              print(widgetNum);
                                              print(MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3.1);
                                              animateToLocation(nearbyActivities
                                                  .data!
                                                  .elementAt(widgetNum)
                                                  .position);
                                              return true;
                                            } else {
                                              return false;
                                            }
                                          },
                                        );
                                      } else {
                                        return Container();
                                      }
                                    });
                              } else {
                                return Container();
                              }
                            }))
                  ])))
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

class ActivitiesWidget extends StatelessWidget {
  GeoPoint? gp;
  Function? animateToLocation;
  NearbyActivities activities;
  IconData icon;
  Future<UserModel>? user;
  ScrollController scrollController;
  int index;

  ActivitiesWidget(this.scrollController, this.activities, this.icon,
      this.animateToLocation, this.index);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width / 2.8;
    gp = activities.position;
    user =
        context.read<FirestoreService>().getSingleUser(user: activities.uid!);

    return FutureBuilder(
        future: user,
        builder: (context, AsyncSnapshot<UserModel> user) {
          if (user.hasData) {
            return InkWell(
                onTap: () => {
                      animateToLocation!(gp),
                      scrollController.animateTo(size * index,
                          duration: Duration(seconds: 1),
                          curve: Curves.easeInOutQuart),
                      showDialog(
                          context: context,
                          builder: (context) {
                            return JoinActivity(user.data!, activities);
                          })
                    },
                child: Container(
                    width: MediaQuery.of(context).size.width / 3.1,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [box_shadow]),
                    margin: EdgeInsets.all(7),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: orange1),
                          child: Stack(children: [
                            Container(
                                width: 50,
                                height: 50,
                                child: CircleAvatar(
                                    backgroundColor: blue1,
                                    foregroundImage:
                                        NetworkImage(user.data!.imageUrl!))),
                            Positioned(
                                right: 0,
                                bottom: 0,
                                height: 22,
                                width: 22,
                                child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: orange1,
                                    ),
                                    child: Icon(
                                      icon,
                                      size: 17,
                                      color: Colors.white,
                                    )))
                          ]),
                        ),
                        Center(
                            child: Text(
                          user.data!.firstName! + " " + user.data!.lastName!,
                          textAlign: TextAlign.center,
                        )),
                        Text(activities.type!),
                        Text(activities.distancefromUser.toStringAsFixed(1) +
                            " km"),
                      ],
                    )));
            ;
          } else {
            return Container();
          }
        });
  }
}

class JoinActivity extends StatelessWidget {
  UserModel user;
  User? currentUser;
  NearbyActivities activity;
  bool isButtonEnabled = true;
  JoinActivity(this.user, this.activity);

  @override
  Widget build(BuildContext context) {
    currentUser = Provider.of<User>(context, listen: false);
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 25, vertical: 225),
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(25)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                    backgroundColor: blue1,
                    foregroundImage: NetworkImage(user.imageUrl!),
                    radius: 50),
                SizedBox(
                  width: 25,
                ),
                Text(
                  user.firstName! + " " + user.lastName!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Text("Activity  :   " + activity.type!),
            Text("Distance  :   " +
                activity.distancefromUser.toStringAsFixed(1) +
                " km"),
            SizedBox(height: 15),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(orange1),
                overlayColor:
                    MaterialStateProperty.all<Color>(Colors.lightBlue),
              ),
              onPressed: () {
                if (isButtonEnabled) {
                  context
                      .read<FirestoreService>()
                      .joinActivity(activity.activityId!, currentUser!.uid);
                  isButtonEnabled = false;
                  Navigator.of(context, rootNavigator: true).pop;
                }
              },
              child: Text(
                "Join",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ));
  }
}
