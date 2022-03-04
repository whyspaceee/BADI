import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import './authenticator.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({Key? key}) : super(key: key);

  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
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
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: GestureDetector(
                onTap: () => {},
              ),
            ),
          ),
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
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update({
                  'firstName': firstNameController.text,
                  'lastName': lastNameController.text,
                });
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
                  "Create Account",
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
