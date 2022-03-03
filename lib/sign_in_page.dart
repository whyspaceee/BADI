import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sports_buddy/sign_up_page.dart';
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
  var errorMessage = false;

  Future logIn() async {
    var message = await context.read<AuthService>().signIn(
        email: emailController.text.trim(),
        password: passController.text.trim());

    errorMessage = message;
  }

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
                      child: Text(
                    "Login",
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
                  await logIn();
                  if (errorMessage == false) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(invalidEmailorPass);
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
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              GestureDetector(
                child: Text("Forgot your password?"),
              ),
              SizedBox(
                height: 15,
              ),
              GestureDetector(
                child: Text("Sign up"),
                onTap: () => {Navigator.pushNamed(context, '/signUp')},
              )
            ],
          ),
        ));
  }
}
