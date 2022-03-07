import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearbySports extends StatefulWidget {
  const NearbySports({Key? key}) : super(key: key);

  @override
  State<NearbySports> createState() => _NearbySportsState();
}

class _NearbySportsState extends State<NearbySports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(-7.771325363128137, 110.37763754446743)))
        ],
      ),
    );
  }
}
