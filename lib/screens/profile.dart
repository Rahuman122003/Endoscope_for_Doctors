import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../utilis/routes.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userProfileData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;

        // Fetch profile data from Firestore
        DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
            .collection('profiles')
            .doc(uid)
            .get();

        if (profileSnapshot.exists) {
          setState(() {
            userProfileData = profileSnapshot.data() as Map<String, dynamic>;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          Get.snackbar("Error", "Profile does not exist.", snackPosition: SnackPosition.TOP);
        }
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar("Error", "Failed to fetch profile: $error", snackPosition: SnackPosition.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userProfileData.isNotEmpty
          ? SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display logo and signature side by side with tap-to-view functionality
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Round avatar for logo with tap action
                  if (userProfileData['logoUrl'] != null)
                    GestureDetector(
                      onTap: () => _showFullImage(userProfileData['logoUrl']),
                      child: CircleAvatar(
                        radius: 75,
                        backgroundImage: NetworkImage(userProfileData['logoUrl']),
                        backgroundColor: Colors.grey[200],
                      ),
                    ),

                  // Rectangular frame for signature with tap action
                  if (userProfileData['signatureUrl'] != null)
                    GestureDetector(
                      onTap: () => _showFullImage(userProfileData['signatureUrl']),
                      child: Column(
                        children: [
                          Text(
                            "Signature:",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: 150,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.network(
                              userProfileData['signatureUrl'],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 30),

              // Profile fields
              _buildProfileField("UHID", userProfileData['UHID'] ?? 'N/A'),
              _buildProfileField("Hospital Name", userProfileData['hospitalName'] ?? 'N/A'),
              _buildProfileField("Doctor's Full Name", userProfileData['fullName'] ?? 'N/A'),
              _buildProfileField("Email", userProfileData['email'] ?? 'N/A'),
              _buildProfileField("Hospital Address", userProfileData['hospitalAddress'] ?? 'N/A'),
              _buildProfileField("Contact Number", userProfileData['contactNumber'] ?? 'N/A'),
              SizedBox(height: 30),

              // Edit Profile Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(Routes.EDIT_PROFILE);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      )
          : Center(child: Text("No profile data available.")),
    );
  }

  // Method to display the image in full screen
  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
