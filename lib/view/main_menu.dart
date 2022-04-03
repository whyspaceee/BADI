import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sports_buddy/models/user_model.dart';
import 'package:sports_buddy/models/activity_model.dart';
import 'package:sports_buddy/services/authenticator.dart';
import 'package:sports_buddy/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '/services/authenticator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sports_buddy/theme.dart';
import 'package:sports_buddy/utils/set_icons.dart';
import 'package:sports_buddy/view/maps_page.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  Location location = Location();
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            SearchBar(controller: searchController),
            MapsWidget(),
            Container(
              child: Text("Friend activity"),
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
            ),
            FriendActivities(),
            RecentActivities(),
          ]))),
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

class FriendActivities extends StatelessWidget {
  FriendActivities({Key? key}) : super(key: key);
  List? list;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context, listen: false);
    final list = context.read<FirestoreService>().getFriendActivity(user!);
    return Container(
        height: 160,
        child: FutureBuilder(
            future: list,
            builder:
                (context, AsyncSnapshot<List<ActivityModel>> querySnapshot) {
              if (querySnapshot.hasData) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: querySnapshot.data!.length,
                      itemBuilder: ((context, index) {
                        if (querySnapshot.hasData) {
                          final friendId =
                              querySnapshot.data!.elementAt(index).uid;
                          final friendData = context
                              .read<FirestoreService>()
                              .getSingleUser(user: friendId!);
                          return FutureBuilder(
                              future: friendData,
                              builder: (context,
                                  AsyncSnapshot<UserModel> userSnapshot) {
                                if (userSnapshot.hasData) {
                                  return Container(
                                    margin: EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [box_shadow],
                                      color: Colors.white,
                                    ),
                                    width: 120,
                                    child: Column(children: [
                                      SizedBox(height: 15),
                                      Container(
                                        child: CircleAvatar(
                                          backgroundColor: blue1,
                                          radius: 35,
                                          backgroundImage: NetworkImage(
                                              userSnapshot.data!.imageUrl!),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(userSnapshot.data!.firstName! +
                                          " " +
                                          userSnapshot.data!.lastName!),
                                      Center(
                                          child: Text(
                                        querySnapshot.data!
                                            .elementAt(index)
                                            .type
                                            .toString(),
                                        style: TextStyle(color: Colors.black),
                                      )),
                                    ]),
                                  );
                                } else {
                                  return Container();
                                }
                              });
                        } else {
                          return Container();
                        }
                      })),
                );
              } else {
                return Container();
              }
            }));
  }
}

class RecentActivities extends StatefulWidget {
  const RecentActivities({Key? key}) : super(key: key);

  @override
  State<RecentActivities> createState() => _RecentActivitiesState();
}

class _RecentActivitiesState extends State<RecentActivities> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context, listen: false);
    final size = MediaQuery.of(context).size.width;
    return Container(
        height: 140,
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Text("Recent Activities")),
          Container(
            height: size / 4.2,
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
                            width: size / 5.1,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                boxShadow: [box_shadow]),
                            margin: EdgeInsets.all(7),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Icon(
                                    sportIcon,
                                    size: 50,
                                    color: orange1,
                                  ),
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
            onPressed: () {
              Navigator.pushNamed(context, '/followingList');
            },
            iconSize: 27.0,
            icon: Icon(
              Icons.person,
            ),
          ),
          //to leave space in between the bottom app bar items and below the FAB
          SizedBox(
            width: 50.0,
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/chatUsers');
            },
            iconSize: 27.0,
            icon: Icon(
              Icons.chat,
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<AuthService>().signOut();
            },
            iconSize: 27.0,
            icon: Icon(
              Icons.logout,
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
