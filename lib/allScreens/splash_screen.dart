import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wemeet/allConstants/color_constants.dart';

import 'package:wemeet/allProviders/auth_provider.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      checkSignedin();
    });
  }

  void checkSignedin() async {
    AuthProvider authProvider = context.read<AuthProvider>();
    bool isLoggedIn = await authProvider.isLoggedIn();
    if (isLoggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
      return;
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'images/splash.png',
              width: 300,
              height: 300,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Connecting people all over the world',
              style: TextStyle(color: ColorConstants.themeColor),
            ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: ColorConstants.themeColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
