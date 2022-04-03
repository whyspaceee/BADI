import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final bool? active;
  final String? placeId;
  final GeoPoint position;
  final String? type;
  final String? uid;
  final String? activityId;

  ActivityModel(this.active, this.placeId, this.position, this.type, this.uid,
      this.activityId);
}

class NearbyActivities extends ActivityModel {
  final double distancefromUser;

  NearbyActivities(
      this.distancefromUser, active, placeId, position, type, uid, activityId)
      : super(active, placeId, position, type, uid, activityId);
}
