import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../utilis/routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);

      // Route to the appropriate home screen based on the email
      if (email == "rrayushscope@gmail.com") {
        Get.offAllNamed(Routes.HOME1);
      } else {
        Get.offAllNamed(Routes.HOME2);
      }
    } catch (e) {
      // Handle specific error messages based on the exception type
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided for that user.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }
      Get.snackbar("Login Error", errorMessage, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> registerAdmin(Map<String, dynamic> profileData) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: profileData['email'],
        password: profileData['password'],
      );

      // Save profile data to Firestore
      await firestore
          .collection('admins')
          .doc(userCredential.user?.uid)
          .set({
        'uhid': profileData['uhid'],
        'fullName': profileData['fullName'],
        'hospital': profileData['hospital'],
        'location': profileData['location'],
        'contactNumber': profileData['contactNumber'],
        'logo': profileData['logo'], // Assuming logo is stored as URL or Blob
        'signature': profileData['signature'], // Assuming signature is stored as URL or Blob
      });

      // Navigate to the login screen after successful registration
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      // Handle specific error messages based on the exception type
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'The email address is already in use by another account.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }
      Get.snackbar("Registration Error", errorMessage, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
