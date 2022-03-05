import 'package:firebase_auth/firebase_auth.dart';
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
    await _firebaseFirestore.collection('users').doc(user.uid).update({
      'uid': user.uid,
      'imageURL':
          'https://firebasestorage.googleapis.com/v0/b/sportsbuddy-fd199.appspot.com/o/profilepicture%2Fdefault.png?alt=media&token=bac098fc-762f-4bb4-9a45-f6fecf554607'
    });
  }

  Future<DocumentSnapshot> getUserDocument({required User user}) async {
    return await _firebaseFirestore.collection('users').doc(user.uid).get();
  }
}
