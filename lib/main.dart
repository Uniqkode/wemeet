import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/allConstants/app_constants.dart';
import 'package:wemeet/allProviders/auth_provider.dart';
import 'package:wemeet/allProviders/chat_provider.dart';
import 'package:wemeet/allProviders/home_provider.dart';
import 'package:wemeet/allProviders/settings_provider.dart';
import 'package:wemeet/allScreens/splash_screen.dart';

bool isWhite = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
              firebaseAuth: FirebaseAuth.instance,
              firebaseFirestore: firebaseFirestore,
              googleSignIn: GoogleSignIn(),
              prefs: prefs),
        ),
        Provider(
            create: (_) => SettingsProvider(
                firestore: firebaseFirestore,
                firebaseStorage: firebaseStorage,
                prefs: prefs)),
        Provider(
          create: (_) => HomeProvider(firebaseFirestore: firebaseFirestore),
        ),
        Provider(
            create: (_) => ChatProvider(
                firebaseFirestore: firebaseFirestore,
                prefs: prefs,
                firebaseStorage: firebaseStorage))
      ],
      child: MaterialApp(
        title: AppConstants.appTitle,
        theme: ThemeData(
          primaryColor: Colors.black,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
