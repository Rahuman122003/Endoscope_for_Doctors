import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';

import '../utilis/routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthentication();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _textAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward(); // Start animation
  }

  void _checkAuthentication() async {
    await Future.delayed(Duration(seconds: 3)); // Wait for 3 seconds

    User? user = _auth.currentUser;

    if (user != null) {
      // User is logged in, navigate to the appropriate home screen
      if (user.email == "adminscope24@gmail.com") {
        Get.offAllNamed(Routes.HOME1);
      } else {
        Get.offAllNamed(Routes.HOME2);
      }
    } else {
      // No user logged in, navigate to login screen
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.white30],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated SVG Image at the top
              FadeTransition(
                opacity: _logoAnimation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.2).animate(
                    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
                  ),
                  child:  Image.asset(
                    'assets/icons/scope1.png', // Replace with your logo asset path
                    height: 300,
                    width: 300,
                  ),
                  // SvgPicture.asset(
                  //   'assets/svgs/rrscopelogo.svg', // Replace with your SVG asset
                  //   height: 350,
                  //   width: 350,
                  // ),
                ),
              ),
              SizedBox(height: 5),
              // Animated App name
              FadeTransition(
                opacity: _textAnimation,
                child: Text(
                  'SCOPES',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.6),
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Animated Slogan
              FadeTransition(
                opacity: _textAnimation,
                child: Text(
                  'Go with Sleek and Futuristic',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black.withOpacity(0.4),
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
