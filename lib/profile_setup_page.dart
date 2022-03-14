import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sports_buddy/firestore_service.dart';
import 'package:sports_buddy/storage_service.dart';
import 'package:sports_buddy/theme.dart';
import './authenticator.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({Key? key}) : super(key: key);

  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ProfilePhoto(
                    user: user,
                  ),
                  SizedBox(height: 15),
                  FormFields(
                      formkey: _formKey,
                      controller: firstNameController,
                      title: "First Name"),
                  SizedBox(height: 15),
                  FormFields(
                    formkey: _formKey,
                    controller: lastNameController,
                    title: "Last Name",
                  ),
                  SizedBox(height: 15),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 25),
                      child: InkWell(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            // save the profile to firestore database
                            await context.read<FirestoreService>().saveName(
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                user: user);
                            firstNameController.clear();
                            lastNameController.clear();
                          }
                        },
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        child: Ink(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                              color: orange1,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          child: Center(
                            child: Text(
                              "Continue",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )),
                  RaisedButton(
                    child: Text("Sign Out"),
                    onPressed: () => {
                      context.read<AuthService>().signOut(),
                      Navigator.popUntil(context, ModalRoute.withName('/'))
                    },
                  ),
                ],
              ),
            )));
  }
}

class FormFields extends StatefulWidget {
  TextEditingController controller;
  String title;
  FormFields(
      {Key? key,
      required GlobalKey formkey,
      required this.controller,
      required this.title})
      : super(key: key);

  @override
  State<FormFields> createState() => _FormFieldsState();
}

class _FormFieldsState extends State<FormFields> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  widget.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                )),
            SizedBox(
              height: 5,
            ),
            Container(
                child: TextFormField(
              controller: widget.controller,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.transparent, width: 0.0),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.transparent, width: 0.0),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.transparent, width: 0.0),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                filled: true,
                fillColor: gray1,
              ),
              style: TextStyle(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ))
          ],
        ));
  }
}

class ProfilePhoto extends StatefulWidget {
  final User user;
  const ProfilePhoto({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfilePhoto> createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<ProfilePhoto> {
  String networkprofileImage =
      'https://firebasestorage.googleapis.com/v0/b/sportsbuddy-fd199.appspot.com/o/profilepicture%2Fdefault.png?alt=media&token=bac098fc-762f-4bb4-9a45-f6fecf554607';
  Stream<DocumentSnapshot>? _stream;
  @override
  Widget build(BuildContext context) {
    _stream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .snapshots();
    final User user = widget.user;
    return Stack(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            color: orange1,
          ),
        ),
        Center(
            child: Container(
                margin: EdgeInsets.only(top: 50),
                height: 115,
                width: 115,
                //streambuilder to build the profile photo,
                child: StreamBuilder(
                    //gets the document of the user
                    stream: _stream,
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      //if there is a connection to the snapshot,
                      //set the network image to the user's imageUrl
                      if (snapshot.connectionState == ConnectionState.active &&
                          snapshot.data?['imageUrl'] != null) {
                        networkprofileImage = snapshot.data!['imageUrl'];
                        return CircleAvatar(
                          backgroundImage: NetworkImage(networkprofileImage),
                          backgroundColor: Colors.black26,
                          child: GestureDetector(
                            //function to get, crop, and upload the profile photo
                            onTap: () async {
                              final image = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (image == null) return;
                              final croppedImage = await ImageCropper()
                                  .cropImage(sourcePath: image.path);
                              if (croppedImage == null) return;
                              final imageTemporary = File(croppedImage.path);
                              try {
                                await context
                                    //uploads the profile photo to storage
                                    .read<StorageService>()
                                    .uploadProfilePhoto(
                                        user.uid, imageTemporary.path);
                                //gets the url for the uploaded photo
                                final temporaryURL = await context
                                    .read<StorageService>()
                                    .getProfilePhoto(user.uid);
                                //gets the document reference of the user
                                //sets the user's imageUrl to the url of the image uploaded to storage
                                final DocumentReference docRef = await context
                                    .read<FirestoreService>()
                                    .getUserReference(user: user);
                                docRef.update({'imageUrl': temporaryURL});
                              } on FirebaseException catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())));
                              }
                            },
                          ),
                        );
                      } else
                        return CircularProgressIndicator(
                          color: Colors.black12,
                        );
                    }))),
      ],
    );
  }
}
