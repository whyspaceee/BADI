import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _firebaseStorage;

  StorageService(this._firebaseStorage);

  Future<void> uploadProfilePhoto(String uid, String filePath) async {
    final profilePictureFile = File(filePath);
    await _firebaseStorage
        .ref('./profilepicture/$uid')
        .putFile(profilePictureFile);
  }

  Future<String> getProfilePhoto(String uid) async {
    String downloadURL =
        await _firebaseStorage.ref('./profilepicture/$uid').getDownloadURL();
    return downloadURL;
  }
}
