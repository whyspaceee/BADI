import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import '/authenticator.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import './sign_in_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class Profile {
  final firestoreInstance = FirebaseFirestore.instance;
  final storageInstance = FirebaseStorage.instance;

  Future createAccount(User user, BuildContext context) async {
    await FirebaseChatCore.instance
        .createUserInFirestore(types.User(id: user.uid));
    await firestoreInstance
        .collection('users')
        .doc(user.uid)
        .update({'uid': user.uid});
    await Navigator.pushNamed(context, '/profileSetup');
  }

  Future uploadProfilePicture(String filePath, String uid) async {
    File file = File(filePath);

    try {
      await storageInstance.ref('profilepicture/$uid').putFile(file);
    } on FirebaseException catch (e) {}
  }
}
