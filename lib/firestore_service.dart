import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class FirestoreService {
  final FirebaseFirestore _firebaseFirestore;

  FirestoreService(this._firebaseFirestore);

  Future<void> saveName(
      {required String firstName,
      required String lastName,
      required User user}) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'firstName': firstName,
      'lastName': lastName,
    });
  }

  Future<void> createAccount({required User user}) async {
    await FirebaseChatCore.instance
        .createUserInFirestore(types.User(id: user.uid));
    await _firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .update({'uid': user.uid});
  }
}
