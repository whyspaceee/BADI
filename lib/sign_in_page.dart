import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './theme.dart';
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                    padding: const EdgeInsets.all(30),
                    child: Center(
                        child: Image(
                      image: NetworkImage(
                          'https://firebasestorage.googleapis.com/v0/b/sportsbuddy-fd199.appspot.com/o/logoipsum-logo-54.png?alt=media&token=3288ac9b-66fd-4b86-9ae0-3a115c4c545a'),
                    ))),
                Column(children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Login to your Account",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  //email and password form fields
                  Container(
                      padding:
                          (EdgeInsets.symmetric(horizontal: 5, vertical: 5)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        color: gray1,
                      ),
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.black12,
                          ),
                          border: InputBorder.none,
                          hintText: "Email",
                          hintStyle:
                              TextStyle(color: Colors.black26, fontSize: 14),
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  SizedBox(height: 15),
                  Container(
                      padding:
                          (EdgeInsets.symmetric(horizontal: 5, vertical: 5)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        color: gray1,
                      ),
                      child: TextFormField(
                        obscureText: true,
                        controller: passController,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.password,
                              color: Colors.black12,
                            ),
                            border: InputBorder.none,
                            hintText: "Password",
                            hintStyle:
                                TextStyle(color: Colors.black26, fontSize: 14)),
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
                    child: Ink(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: orange1,
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Sign in",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ]),
                Column(children: [
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      "- or continue with -",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => {},
                    child: Ink(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [box_shadow]),
                        child: Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/logos/google.png'))))),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    child: Text(
                      "Forgot your password?",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  //navigates to the signup page
                  GestureDetector(
                    child: Text("Sign up",
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    onTap: () => {Navigator.pushNamed(context, '/signUp')},
                  ),
                ]),
              ]),
        ));
  }
}
