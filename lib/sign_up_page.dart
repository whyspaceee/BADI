import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sports_buddy/firestore_service.dart';
import '/authenticator.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

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
              try {
                await context.read<AuthService>().signUp(
                    email: emailController.text.trim(),
                    password: passController.text.trim());
              } on FirebaseAuthException catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.message!)));
              }
              final user = Provider.of<User?>(context, listen: false);
              if (user != null) {
                await context
                    .read<FirestoreService>()
                    .createAccount(user: user);
                Navigator.pushNamed(context, '/profileSetup');
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
