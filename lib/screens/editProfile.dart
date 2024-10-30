import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'dart:io'; // To handle file inputs

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  TextEditingController uhidController = TextEditingController();
  TextEditingController hospitalNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController hospitalAddressController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();

  bool isLoading = false;
  File? logoFile;
  File? signatureFile;

  Map<String, dynamic> userProfileData = {};

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
            _populateFields(userProfileData);
          });
        }
      }
    } catch (error) {
      Get.snackbar("Error", "Failed to fetch profile: $error", snackPosition: SnackPosition.TOP);
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    uhidController.text = data['UHID'] ?? '';
    hospitalNameController.text = data['hospitalName'] ?? '';
    fullNameController.text = data['fullName'] ?? '';
    emailController.text = data['email'] ?? '';
    hospitalAddressController.text = data['hospitalAddress'] ?? '';
    contactNumberController.text = data['contactNumber'] ?? '';
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isLoading = true;
        });

        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          String uid = currentUser.uid;

          // Update the user's profile data in Firestore
          await FirebaseFirestore.instance.collection('profiles').doc(uid).update({
            'UHID': uhidController.text,
            'hospitalName': hospitalNameController.text,
            'fullName': fullNameController.text,
            'email': emailController.text,
            'hospitalAddress': hospitalAddressController.text,
            'contactNumber': contactNumberController.text,
            // TODO: Handle the image URL updates if logos or signatures are changed
          });

          Get.snackbar("Success", "Profile updated successfully", snackPosition: SnackPosition.TOP);
        }
      } catch (error) {
        Get.snackbar("Error", "Failed to update profile: $error", snackPosition: SnackPosition.TOP);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isLogo) {
          logoFile = File(pickedFile.path);
        } else {
          signatureFile = File(pickedFile.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // UHID Field
              _buildTextField("UHID", uhidController, "Please enter UHID"),

              // Hospital Name Field
              _buildTextField("Hospital Name", hospitalNameController, "Please enter hospital name"),

              // Full Name Field
              _buildTextField("Doctor's Full Name", fullNameController, "Please enter full name"),

              // Email Field
              _buildTextField("Email", emailController, "Please enter email", isEmail: true),

              // Hospital Address Field
              _buildTextField("Hospital Address", hospitalAddressController, "Please enter hospital address"),

              // Contact Number Field
              _buildTextField("Contact Number", contactNumberController, "Please enter contact number"),

              // Image Pickers for Logo and Signature
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Logo Picker
                  GestureDetector(
                    onTap: () => _pickImage(true),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: logoFile != null
                          ? FileImage(logoFile!)
                          : userProfileData['logoUrl'] != null
                          ? NetworkImage(userProfileData['logoUrl'])
                          : null,
                      child: logoFile == null && userProfileData['logoUrl'] == null
                          ? Icon(Icons.camera_alt, size: 30, color: Colors.grey[700])
                          : null,
                    ),
                  ),
                  // Signature Picker
                  GestureDetector(
                    onTap: () => _pickImage(false),
                    child: Container(
                      width: 150,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: signatureFile != null
                          ? Image.file(signatureFile!, fit: BoxFit.cover)
                          : userProfileData['signatureUrl'] != null
                          ? Image.network(userProfileData['signatureUrl'], fit: BoxFit.cover)
                          : Center(child: Icon(Icons.camera_alt, size: 30, color: Colors.grey[700])),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Save Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String validationMessage, {bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validationMessage;
          }
          if (isEmail && !value.contains('@')) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
    );
  }
}
