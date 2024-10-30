import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utilis/routes.dart'; // Assuming you're using Firebase for authentication.

class LogoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Perform logout operation
    FirebaseAuth.instance.signOut().then((_) {
      // Navigate to the login screen after logout
      Get.offAllNamed(Routes.LOGIN);
    });

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show a loading indicator while logging out.
      ),
    );
  }
}
