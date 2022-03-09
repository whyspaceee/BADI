import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './authenticator.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  Widget build(BuildContext context) {
    const invalidEmailorPass =
        SnackBar(content: Text("Invalid email or password"));
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.all(50),
                  child: Center(
                      child: Image(
                    image: NetworkImage(
                        'https://firebasestorage.googleapis.com/v0/b/sportsbuddy-fd199.appspot.com/o/logoipsum-logo-46.png?alt=media&token=22a7c90a-589b-4628-ae97-32629ad933d4'),
                  ))),
              SizedBox(height: 15),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Login to your Account",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              //email and password form fields
              Container(
                  padding: (EdgeInsets.symmetric(horizontal: 20, vertical: 5)),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.black12),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Email"),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              SizedBox(height: 15),
              Container(
                  padding: (EdgeInsets.symmetric(horizontal: 20, vertical: 5)),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.black12),
                  child: TextFormField(
                    obscureText: true,
                    controller: passController,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Password"),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              SizedBox(height: 15),

              InkWell(
                //uses the provider to sign in using the AuthService class,
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  try {
                    await context.read<AuthService>().signIn(
                        email: emailController.text.trim(),
                        password: passController.text.trim());
                  } on FirebaseAuthException catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.message!)));
                  }
                },
                borderRadius: BorderRadius.all(Radius.circular(12)),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(243, 102, 52, 1),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  "- or continue with -",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => {},
                child: Ink(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 3,
                              spreadRadius: 2,
                              color: Colors.black12,
                              offset: Offset(0, 3))
                        ]),
                    child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage('assets/logos/google.png'))))),
              ),
              SizedBox(
                height: 15,
              ),
              GestureDetector(
                child: Text(
                  "Forgot your password?",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              //navigates to the signup page
              GestureDetector(
                child: Text("Sign up",
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onTap: () => {Navigator.pushNamed(context, '/signUp')},
              )
            ],
          ),
        ));
  }
}
