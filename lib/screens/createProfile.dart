import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../controllers/profileController.dart';

class ProfileCreationScreen extends StatelessWidget {
  final ProfileController profileController = Get.put(ProfileController());

  final TextEditingController uhidController = TextEditingController();
  final TextEditingController hospitalNameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController hospitalAddressController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxString selectedCountryCode = "+91".obs;
  final Rx<File?> logoFile = Rx<File?>(null);
  final Rx<File?> signatureFile = Rx<File?>(null);
  final RxBool isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(Rx<File?> imageFile) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e", snackPosition: SnackPosition.TOP);
    }
  }

  Future<String?> _uploadImageToFirebase(File image, String folderName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('$folderName/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Get.snackbar("Error", "Failed to upload image: $e", snackPosition: SnackPosition.TOP);
      return null;
    }
  }

  Future<void> _onCreateProfile() async {
    if (!_validateFields()) {
      return;
    }

    isLoading.value = true;

    // Upload images to Firebase Storage
    final logoUrl = logoFile.value != null ? await _uploadImageToFirebase(logoFile.value!, 'logos') : null;
    final signatureUrl = signatureFile.value != null ? await _uploadImageToFirebase(signatureFile.value!, 'signatures') : null;

    final profileData = {
      'UHID': uhidController.text.trim(),
      'hospitalName': hospitalNameController.text.trim(),
      'fullName': fullNameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
      'hospitalAddress': hospitalAddressController.text.trim(),
      'contactNumber': '$selectedCountryCode ${contactNumberController.text.trim()}',
      'logoUrl': logoUrl,
      'signatureUrl': signatureUrl,
    };

    try {
      await profileController.createProfile(profileData);
      Get.snackbar("Success", "Profile created successfully!", snackPosition: SnackPosition.TOP);
      Get.offNamed('/login'); // Navigate to login screen after profile creation
    } catch (error) {
      Get.snackbar("Error", "Failed to create profile: $error", snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateFields() {
    if (uhidController.text.isEmpty ||
        hospitalNameController.text.isEmpty ||
        fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        !GetUtils.isEmail(emailController.text) ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        passwordController.text != confirmPasswordController.text ||
        passwordController.text.length < 6) {
      Get.snackbar("Validation Error", "Please fill in all fields correctly. Password must be at least 6 characters and match the confirmation.",
          snackPosition: SnackPosition.TOP);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurpleAccent, Colors.white30],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Image.asset(
                  'assets/icons/scope1.png',
                  height: 200,
                ),
              ),
              SizedBox(height: 2),

              // Welcome Text
              Text(
                'CREATE PROFILE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              // TextFields
              _buildModernTextField(controller: uhidController, labelText: 'UHID'),
              SizedBox(height: 16),
              _buildModernTextField(controller: hospitalNameController, labelText: 'Enter Hospital Name'),
              SizedBox(height: 16),
              _buildModernTextField(controller: fullNameController, labelText: 'Dr. Full Name'),
              SizedBox(height: 16),
              _buildModernTextField(controller: emailController, labelText: 'Email', keyboardType: TextInputType.emailAddress),
              SizedBox(height: 16),
              Obx(() => _buildModernTextField(
                controller: passwordController,
                labelText: 'Password',
                isObscure: !isPasswordVisible.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey[700],
                  ),
                  onPressed: () {
                    isPasswordVisible.value = !isPasswordVisible.value;
                  },
                ),
              )),
              SizedBox(height: 16),
              Obx(() => _buildModernTextField(
                controller: confirmPasswordController,
                labelText: 'Confirm Password',
                isObscure: !isPasswordVisible.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey[700],
                  ),
                  onPressed: () {
                    isPasswordVisible.value = !isPasswordVisible.value;
                  },
                ),
              )),
              SizedBox(height: 16),
              _buildModernTextField(controller: hospitalAddressController, labelText: 'Hospital Address'),
              SizedBox(height: 16),

              Row(
                children: [
                  Obx(() => CountryCodePicker(
                    onChanged: (country) {
                      selectedCountryCode.value = country.dialCode!;
                    },
                    initialSelection: selectedCountryCode.value,
                    favorite: ['+91'],
                    showFlag: false,
                    textStyle: TextStyle(color: Colors.grey[700]),
                  )),
                  Expanded(
                    child: _buildModernTextField(
                      controller: contactNumberController,
                      labelText: 'Contact Number',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Image Pickers
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildImagePicker('Upload Logo', logoFile),
                  _buildImagePicker('Upload Signature', signatureFile),
                ],
              ),
              SizedBox(height: 24),

              // Create Profile Button
              Obx(() => ElevatedButton(
                onPressed: isLoading.value ? null : _onCreateProfile,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: isLoading.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Create Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String labelText,
    bool isObscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(2, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildImagePicker(String label, Rx<File?> imageFile) {
    return GestureDetector(
      onTap: () => _pickImage(imageFile),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(2, 2),
              blurRadius: 5,
            ),
          ],
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageFile.value != null
                ? Image.file(
              imageFile.value!,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            )
                : Icon(
              Icons.camera_alt,
              color: Colors.grey[700],
              size: 40,
            ),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
