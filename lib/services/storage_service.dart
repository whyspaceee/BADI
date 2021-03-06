import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageService {
  // class to handle the storage
  final FirebaseStorage _firebaseStorage;

  StorageService(this._firebaseStorage);
  // takes a filepath and a user uid and uploads a photo to storage
  Future<void> uploadProfilePhoto(String uid, String filePath) async {
    final profilePictureFile = File(filePath);
    await _firebaseStorage
        .ref('profilepicture/$uid')
        .putFile(profilePictureFile);
  }

// returns the url for the users's profile photo
  Future<String> getProfilePhoto(String uid) async {
    String downloadURL =
        await _firebaseStorage.ref('profilepicture/$uid').getDownloadURL();
    return downloadURL;
  }
}
