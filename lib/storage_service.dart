import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageService {
  final FirebaseStorage _firebaseStorage;

  StorageService(this._firebaseStorage);

  Future<void> uploadProfilePhoto(String uid, String filePath) async {
    final profilePictureFile = File(filePath);
    await _firebaseStorage
        .ref('profilepicture/$uid')
        .putFile(profilePictureFile);
  }

  Future<String> getProfilePhoto(String uid) async {
    String downloadURL =
        await _firebaseStorage.ref('profilepicture/$uid').getDownloadURL();
    return downloadURL;
  }
}
