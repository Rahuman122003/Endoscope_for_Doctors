import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  RxMap<String, dynamic> userProfileData = RxMap<String, dynamic>({});
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var currentUserProfile = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchProfile();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;

        // Fetch profile data from Firestore
        DocumentSnapshot profileSnapshot = await firestore
            .collection('profiles')
            .doc(uid)
            .get();

        if (profileSnapshot.exists) {
          userProfileData.value = profileSnapshot.data() as Map<String, dynamic>;
        } else {
          print('Profile does not exist');
          userProfileData.clear();
        }
      }
    } catch (error) {
      Get.snackbar("Error", "Failed to fetch profile: $error", snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> _fetchProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot profileSnapshot = await firestore
            .collection('profiles')
            .doc(user.uid)
            .get();

        if (profileSnapshot.exists) {
          currentUserProfile.value = Map<String, dynamic>.from(profileSnapshot.data() as Map);
        } else {
          print('Profile does not exist');
          currentUserProfile.clear();
        }
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Future<void> createProfile(Map<String, dynamic> profileData) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: profileData['email'], password: profileData['password']);

      User? user = userCredential.user;
      if (user == null) {
        Get.snackbar("Error", "User registration failed.", snackPosition: SnackPosition.TOP);
        return;
      }

      String userId = user.uid;

      // Save profile data using userId as document ID
      await firestore.collection('profiles').doc(userId).set(profileData);

      Get.snackbar("Success", "Profile created successfully", snackPosition: SnackPosition.BOTTOM);

      Get.offAllNamed('/login'); // Navigate to login screen
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
      print(e);
    }
  }

  Future<void> editProfile(Map<String, dynamic> profileData) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar("Error", "No user is currently logged in.", snackPosition: SnackPosition.BOTTOM);
        return;
      }

      String userId = user.uid;

      // Update the existing profile document
      await firestore.collection('profiles').doc(userId).update(profileData);
      Get.snackbar("Success", "Profile updated successfully", snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar("Error", "No user is currently logged in.", snackPosition: SnackPosition.BOTTOM);
        return;
      }

      String userId = user.uid;

      // Delete the profile document
      await firestore.collection('profiles').doc(userId).delete();
      Get.snackbar("Success", "Profile deleted successfully", snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllProfiles() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await firestore.collection('profiles').get();

      if (snapshot.docs.isEmpty) {
        Get.snackbar("Info", "No profiles available.", snackPosition: SnackPosition.TOP);
        return [];
      }

      List<Map<String, dynamic>> profiles = snapshot.docs
          .map((doc) => doc.data())
          .toList();

      return profiles;
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
      return [];
    }
  }
}
