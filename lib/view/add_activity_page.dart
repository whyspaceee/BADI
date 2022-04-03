import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:sports_buddy/theme.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddActivity extends StatefulWidget {
  const AddActivity({Key? key}) : super(key: key);

  @override
  State<AddActivity> createState() => _AddActivityState();
}

class _AddActivityState extends State<AddActivity> {
  GooglePlace? googlePlace;
  List<AutocompletePrediction> predictions = [];
  String? placeId;
  TextEditingController controller = TextEditingController();
  String? sportValue;
  DetailsResult? _detailsResult;
  @override
  void initState() {
    initgooglePlace();
    super.initState();
  }

  void initgooglePlace() async {
    String apiKey = dotenv.env['apiKey']!;
    googlePlace = GooglePlace(apiKey);
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace?.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
      print(result.predictions);
    }
  }

  void getDetails(String placeId) async {
    var result = await this.googlePlace!.details.get(placeId);
    if (result != null && result.result != null && mounted) {
      setState(() {
        _detailsResult = result.result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Column(
          children: [
            SizedBox(height: 25),
            Text(
              "Add your activity",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            SizedBox(
              height: 25,
            ),
            DropDownSportSelector(
                sportValue,
                (value) => {
                      sportValue = value,
                    }),
            Container(
              height: 260,
              margin: EdgeInsets.only(right: 20, left: 20, top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Location",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Search",
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black54,
                          width: 2.0,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        autoCompleteSearch(value);
                      } else {
                        if (predictions.length > 0 && mounted) {
                          setState(() {
                            predictions = [];
                          });
                        }
                      }
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 150,
                    child: ListView.builder(
                      itemCount: predictions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            setState(() {
                              controller.text = predictions[index].description!;
                              placeId = predictions[index].placeId;
                              getDetails(placeId!);
                            });
                          },
                          leading: CircleAvatar(
                            child: Icon(
                              Icons.pin_drop,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(predictions[index].description!),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),
            InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  print('Created Activity');
                  final lat = _detailsResult!.geometry!.location!.lat;
                  final lng = _detailsResult!.geometry!.location!.lng;
                  final user = Provider.of<User?>(context, listen: false);
                  GeoPoint geoPoint = GeoPoint(lat!, lng!);
                  FirebaseFirestore.instance.collection('activities').add({
                    'type': sportValue,
                    'position': geoPoint,
                    'uid': user!.uid,
                    'active': true,
                    'placeId': placeId,
                  });
                  print('Created Activity ' + sportValue!);
                },
                child: Ink(
                    width: 250,
                    height: 50,
                    padding: EdgeInsets.all(5),
                    child: Center(
                        child: Text(
                      "Add Activity",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    )),
                    decoration: BoxDecoration(
                        color: orange1,
                        borderRadius: BorderRadius.circular(12))))
          ],
        )));
  }
}

class DropDownSportSelector extends StatelessWidget {
  String? sportsValue;
  Function? func;
  DropDownSportSelector(this.sportsValue, this.func);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(right: 20, left: 20, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sport", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            Container(
                child: DropdownButtonFormField(
              icon: Icon(
                CupertinoIcons.arrow_down_circle,
                color: blue1,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: gray1,
              ),
              dropdownColor: gray1,
              style: TextStyle(color: Colors.black),
              items: <String>[
                'Tennis',
                'Swimming',
                'Soccer',
                'Basketball',
                'Other'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                sportsValue = newValue!;
                func!(newValue);
              },
            ))
          ],
        ));
  }
}

class LocationSelector extends StatefulWidget {
  GooglePlace? googlePlace;
  final void Function() onTap;
  LocationSelector({Key? key, required this.onTap}) : super(key: key);

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  GooglePlace? googlePlace;
  List<AutocompletePrediction> predictions = [];
  @override
  void initState() {
    initgooglePlace();
    super.initState();
  }

  void initgooglePlace() async {
    String apiKey = dotenv.env['apiKey']!;
    googlePlace = GooglePlace(apiKey);
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace?.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
      print(result.predictions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _onTap = widget.onTap;
    return Container(
      height: 260,
      margin: EdgeInsets.only(right: 20, left: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              labelText: "Search",
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue,
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black54,
                  width: 2.0,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                autoCompleteSearch(value);
              } else {
                if (predictions.length > 0 && mounted) {
                  setState(() {
                    predictions = [];
                  });
                }
              }
            },
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 150,
            child: ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: _onTap,
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.pin_drop,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(predictions[index].description!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
