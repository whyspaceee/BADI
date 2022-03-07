import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sports_buddy/profile_setup_page.dart';
import 'package:sports_buddy/sign_up_page.dart';
import 'package:sports_buddy/storage_service.dart';
import '/authenticator.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import './sign_in_page.dart';
import './firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          //providers to handle state management
          Provider<AuthService>(
            create: (_) => AuthService(FirebaseAuth.instance),
          ),
          StreamProvider(
              create: (context) => context.read<AuthService>().authStateChanges,
              initialData: null),
          Provider<FirestoreService>(
              create: (_) => FirestoreService(FirebaseFirestore.instance)),
          Provider<StorageService>(
              create: (_) => StorageService(FirebaseStorage.instance))
        ],
        child: MaterialApp(
          theme: ThemeData(
            backgroundColor: Colors.white,
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          home: AuthenticationWrapper(),
          routes: {
            '/mainMenu': (context) => const MainMenu(),
            '/authWrapper': (context) => const AuthenticationWrapper(),
            '/signUp': (context) => const SignUpPage(),
            '/profileSetup': (context) => const ProfileSetupPage(),
          },
        ));
  }
}

//wrapper to determine if the user is logged in or not
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    if (firebaseUser != null) {
      return ProfileSetupPage();
    } else {
      return SignInPage();
    }
  }
}

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: RaisedButton(
        child: Text("Sign Out"),
        onPressed: () => {context.read<AuthService>().signOut()},
      ),
    ));
  }
}
