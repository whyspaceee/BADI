import 'package:firebase_auth/firebase_auth.dart';
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

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final firebaseInstance = FirebaseFirestore.instance;
  bool errorMessage = false;
  Future signUp() async {
    var message = await context.read<AuthService>().signUp(
        email: emailController.text.trim(),
        password: passController.text.trim());

    errorMessage = message;
  }

  Widget build(BuildContext context) {
    const invalidEmailorPass =
        SnackBar(content: Text("Invalid email or password"));
    return Scaffold(
        body: Container(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.all(50),
              child: Center(
                  child: Text(
                "Sign up",
                style: TextStyle(fontSize: 30),
              ))),
          SizedBox(height: 15),
          Container(
              padding: (EdgeInsets.symmetric(horizontal: 20, vertical: 5)),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  color: Colors.black12),
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "Email"),
                style: TextStyle(),
              )),
          SizedBox(height: 15),
          Container(
              padding: (EdgeInsets.symmetric(horizontal: 20, vertical: 5)),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  color: Colors.black12),
              child: TextFormField(
                obscureText: true,
                controller: passController,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "Password"),
                style: TextStyle(),
              )),
          SizedBox(height: 25),
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () => {},
            child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/logos/google.png')))),
          ),
          SizedBox(height: 25),
          InkWell(
            onTap: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              await signUp();
              final user = Provider.of<User?>(context, listen: false);
              if (errorMessage == false) {
                ScaffoldMessenger.of(context).showSnackBar(invalidEmailorPass);
              } else {
                await FirebaseChatCore.instance
                    .createUserInFirestore(types.User(id: user!.uid));
                await firebaseInstance
                    .collection('users')
                    .doc(user.uid)
                    .set({'uid': user.uid});
                await Navigator.pushNamed(context, '/authWrapper');
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
                  "Sign up",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          GestureDetector(
            onTap: () => {
              Navigator.pop(context),
            },
            child: Text("Sign In"),
          )
        ],
      ),
    ));
  }
}
