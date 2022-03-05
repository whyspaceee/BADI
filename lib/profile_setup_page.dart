import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sports_buddy/firestore_service.dart';
import 'package:sports_buddy/storage_service.dart';
import './authenticator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({Key? key}) : super(key: key);

  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  String networkprofileImage =
      'https://firebasestorage.googleapis.com/v0/b/sportsbuddy-fd199.appspot.com/o/profilepicture%2Fdefault.png?alt=media&token=bac098fc-762f-4bb4-9a45-f6fecf554607';

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: SingleChildScrollView(
      padding: EdgeInsets.all(25),
      child: Column(
        children: [
          Container(
              height: size.width / 4,
              width: size.width / 4,
              child: StreamBuilder(
                  stream: context
                      .read<FirestoreService>()
                      .getUserDocumentStream(user: user),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      networkprofileImage = snapshot.data!['imageUrl'];
                      return CircleAvatar(
                        backgroundImage: NetworkImage(networkprofileImage),
                        backgroundColor: Colors.black26,
                        child: GestureDetector(
                          onTap: () async {
                            final image = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (image == null) return;
                            final croppedImage = await ImageCropper()
                                .cropImage(sourcePath: image.path);
                            if (croppedImage == null) return;
                            final imageTemporary = File(croppedImage.path);
                            await context
                                .read<StorageService>()
                                .uploadProfilePhoto(
                                    user.uid, imageTemporary.path);
                            final temporaryURL = await context
                                .read<StorageService>()
                                .getProfilePhoto(user.uid);
                            final DocumentReference docRef = await context
                                .read<FirestoreService>()
                                .getUserReference(user: user);
                            docRef.set({'imageUrl': temporaryURL});
                          },
                        ),
                      );
                    } else
                      return CircularProgressIndicator();
                  })),
          SizedBox(height: 15),
          Container(
              padding: (EdgeInsets.symmetric(horizontal: 20, vertical: 5)),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  color: Colors.black12),
              child: TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "First name"),
                style: TextStyle(),
              )),
          SizedBox(height: 15),
          Container(
              padding: (EdgeInsets.symmetric(horizontal: 20, vertical: 5)),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  color: Colors.black12),
              child: TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "Last name"),
                style: TextStyle(),
              )),
          SizedBox(height: 15),
          InkWell(
            onTap: () async {
              if (firstNameController.text != "" &&
                  lastNameController.text != "") {
                FocusManager.instance.primaryFocus?.unfocus();
                await context.read<FirestoreService>().saveName(
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    user: user);
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Empty")));
              }
            },
            borderRadius: BorderRadius.all(Radius.circular(50)),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: Color.fromARGB(221, 66, 66, 66),
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              child: Center(
                child: Text(
                  "Save Changes",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          RaisedButton(
            child: Text("Sign Out"),
            onPressed: () => {
              context.read<AuthService>().signOut(),
              Navigator.popUntil(context, ModalRoute.withName('/'))
            },
          ),
        ],
      ),
    ));
  }
}
