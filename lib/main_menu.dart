import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sports_buddy/authenticator.dart';
import 'package:sports_buddy/firestore_service.dart';
import 'package:sports_buddy/theme.dart';
import 'maps_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import './sign_in_page.dart';
import './authenticator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './theme.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Location location = Location();
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBar(controller: searchController),
          MapsWidget(),
          RecentActivities(),
          RaisedButton(
              onPressed: (() => {context.read<AuthService>().signOut()}))
        ],
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerDocked, //specify the location of the FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addActivity');
        },
        backgroundColor: orange1,
        child: Container(
          margin: EdgeInsets.all(15.0),
          child: Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: BottomAppBarWidget(),
        shape: CircularNotchedRectangle(),
        color: Colors.white,
      ),
    );
  }
}

class RecentActivities extends StatefulWidget {
  const RecentActivities({Key? key}) : super(key: key);

  @override
  State<RecentActivities> createState() => _RecentActivitiesState();
}

class _RecentActivitiesState extends State<RecentActivities> {
  IconData setIcons(String type) {
    if (type == "Tennis") return Icons.sports_tennis;
    if (type == "Basketball") return Icons.sports_basketball;
    if (type == "Soccer") return Icons.sports_soccer;
    return Icons.sports;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context, listen: false);

    return Container(
        height: 160,
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Text("Recent Activities")),
          Container(
            height: 130,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('activities')
                  .where('uid', isEqualTo: user!.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var sportIcon =
                            setIcons(snapshot.data!.docs[index]['type']);
                        return Container(
                            width: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
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
                                      borderRadius: BorderRadius.circular(25),
                                      color: orange1),
                                  child: Icon(
                                    sportIcon,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  snapshot.data!.docs[index]["type"],
                                ),
                              ],
                            ));
                      });
                }
                return CircularProgressIndicator();
              },
            ),
          )
        ]));
  }
}

class ActivitiesWidget extends StatefulWidget {
  const ActivitiesWidget({Key? key}) : super(key: key);

  @override
  State<ActivitiesWidget> createState() => _ActivitiesWidgetState();
}

class _ActivitiesWidgetState extends State<ActivitiesWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [Text("Activities")],
    ));
  }
}

class BottomAppBarWidget extends StatelessWidget {
  const BottomAppBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 12.0, right: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            //update the bottom app bar view each time an item is clicked
            onPressed: () {},
            iconSize: 27.0,
            icon: Icon(
              Icons.home,
              //darken the icon if it is selected or else give it a different color
            ),
          ),
          IconButton(
            onPressed: () {},
            iconSize: 27.0,
            icon: Icon(
              Icons.call_made,
            ),
          ),
          //to leave space in between the bottom app bar items and below the FAB
          SizedBox(
            width: 50.0,
          ),
          IconButton(
            onPressed: () {},
            iconSize: 27.0,
            icon: Icon(
              Icons.call_received,
            ),
          ),
          IconButton(
            onPressed: () {},
            iconSize: 27.0,
            icon: Icon(
              Icons.settings,
            ),
          ),
        ],
      ),
    );
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

  void _onTap(LatLng latLng) {
    Navigator.pushNamed(context, '/mapPage');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 25, horizontal: 15),
        decoration:
            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(50))),
        height: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: StreamBuilder(
              stream: context
                  .read<FirestoreService>()
                  .getCollectionStream(collectionName: 'activities'),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  _updateMarkers(snapshot.data!.docs);
                }
                return (GoogleMap(
                  scrollGesturesEnabled: false,
                  buildingsEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                  onTap: _onTap,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: (CameraPosition(
                      target: LatLng(-7.770717, 110.377724), zoom: 15)),
                  markers: Set<Marker>.of(markers.values),
                ));
              }),
        ));
  }
}

class SearchBar extends StatefulWidget {
  TextEditingController controller;
  SearchBar({Key? key, required TextEditingController this.controller})
      : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    final searchController = widget.controller;
    return Container(
      height: 60,
      decoration: BoxDecoration(color: orange1),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Center(
          child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width / 1.2,
              child: TextField(
                maxLines: 1,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.bottom,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(5.0, 9, 5.0, 9),
                  prefixIcon: Icon(
                    CupertinoIcons.search,
                    color: Colors.black26,
                  ),
                  filled: true,
                  fillColor: gray1,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        BorderSide(color: Colors.transparent, width: 0.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        BorderSide(color: Colors.transparent, width: 0.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 0.0)),
                  hintText: "Find your sports buddy",
                ),
                controller: searchController,
              )),
        ),
      ]),
    );
  }
}
