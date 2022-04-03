import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:sports_buddy/models/user_model.dart';
import 'package:sports_buddy/models/activity_model.dart';

import 'package:location/location.dart';

//class for accesing the firestore db
class FirestoreService {
  final FirebaseFirestore _firebaseFirestore;

  FirestoreService(this._firebaseFirestore);

  //saves the name (should be changed into a function to set profile not just names)
  Future<void> saveName(
      {required String firstName,
      required String lastName,
      required User user}) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'firstName': firstName,
      'lastName': lastName,
    });
  }

  //saves the user id and set default profile
  Future<void> createAccount({required User user}) async {
    await FirebaseChatCore.instance
        .createUserInFirestore(types.User(id: user.uid));
    await _firebaseFirestore.collection('users').doc(user.uid).update({
      'uid': user.uid,
      'imageUrl':
          'https://firebasestorage.googleapis.com/v0/b/sportsbuddy-fd199.appspot.com/o/profilepicture%2Fdefault.png?alt=media&token=bac098fc-762f-4bb4-9a45-f6fecf554607'
    });
  }

  //returns the user document snapshot
  Future<DocumentSnapshot> getUserDocument({required String user}) async {
    return await _firebaseFirestore.collection('users').doc(user).get();
  }

  //get the user document reference
  DocumentReference getUserReference({required User user}) {
    return _firebaseFirestore.collection('users').doc(user.uid);
  }

  //get a stream of user document snapshots
  //useful for refreshing user profile pictures
  Stream<DocumentSnapshot> getUserDocumentStream({required User user}) {
    return _firebaseFirestore.collection('users').doc(user.uid).snapshots();
  }

  Stream<QuerySnapshot> getCollectionStream({required String collectionName}) {
    return _firebaseFirestore.collection(collectionName).snapshots();
  }

  Future<UserModel> getSingleUser({required String user}) async {
    final firestoreReference = await getUserDocument(user: user);
    return UserModel(
        firestoreReference['firstName'],
        firestoreReference['lastName'],
        firestoreReference['imageUrl'],
        firestoreReference['uid']);
  }

  Future<List<UserModel>> getAllUsers() async {
    final q_snapshot = await _firebaseFirestore.collection('users').get();
    return q_snapshot.docs.map((snapshot) {
      final Map<String, dynamic> dataMap =
          snapshot.data() as Map<String, dynamic>;

      return UserModel(dataMap['firstName'], dataMap['lastName'],
          dataMap['imageUrl'], dataMap['uid']);
    }).toList();
  }

  Future<List<String>> getFollowing(String uid) async {
    final following = await _firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();

    return following.docs.map((snapshot) {
      final Map<String, dynamic> dataMap =
          snapshot.data() as Map<String, dynamic>;

      return dataMap['uid'].toString();
    }).toList();
  }

  Future<List<String>> getFollowingId(User user) async {
    final friends = await _firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .collection('following')
        .get();

    return friends.docs.map((snapshot) {
      final Map<String, dynamic> dataMap =
          snapshot.data() as Map<String, dynamic>;
      print(dataMap['uid'].toString());
      return dataMap['uid'].toString();
    }).toList();
  }

  List<ActivityModel> getActivityModel(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((snapshot) {
      final Map<String, dynamic> dataMap =
          snapshot.data() as Map<String, dynamic>;

      return ActivityModel(dataMap['active'], dataMap['placeId'],
          dataMap['position'], dataMap['type'], dataMap['uid'], snapshot.id);
    }).toList();
  }

  Future<List<ActivityModel>> getFriendActivity(User user) async {
    final friends = await getFollowingId(user);
    List<ActivityModel> list = [];
    for (var element in friends) {
      print(element);
      final activity = await _firebaseFirestore
          .collection('activities')
          .where('uid', isEqualTo: element)
          .where('active', isEqualTo: true)
          .get();
      print(activity.docs.length);
      final model = getActivityModel(activity);
      print("model" + (model.length).toString());
      model.forEach((element) {
        list.add(element);
      });
    }
    ;
    return list;
  }

  Future<List<ActivityModel>> getAllActivities() async {
    final activites = await _firebaseFirestore.collection('activities').get();
    final model = getActivityModel(activites);
    return model;
  }

  double getDistance(LocationData loc, GeoPoint gp) {
    final currentLat = loc.latitude;
    final currentLong = loc.longitude;

    final activityLat = gp.latitude;
    final activityLong = gp.longitude;

    final latDiff = currentLat! - activityLat;
    final longDiff = currentLong! - activityLong;

    final distance = sqrt(pow(latDiff, 2)) + pow(longDiff, 2);

    return distance * 111;
  }

  Future<List<NearbyActivities>> getNearbyActivities(LocationData loc) async {
    final allActivities =
        await _firebaseFirestore.collection('activities').get();

    final nearby = allActivities.docs.map((snapshot) {
      final Map<String, dynamic> dataMap =
          snapshot.data() as Map<String, dynamic>;

      return NearbyActivities(
        getDistance(loc, dataMap['position']),
        dataMap['active'],
        dataMap['placeId'],
        dataMap['position'],
        dataMap['type'],
        dataMap['uid'],
        snapshot.id,
      );
    }).toList();

    nearby.sort(((a, b) => a.distancefromUser.compareTo(b.distancefromUser)));
    return nearby;
  }

  void joinActivity(String activityId, String userId) {
    final ref = _firebaseFirestore
        .collection('activities')
        .doc(activityId)
        .collection('joined')
        .doc(userId)
        .set({'uid': userId});
  }
}
