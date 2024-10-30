import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../controllers/authController.dart';
import '../utilis/routes.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs; // For loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.white30], // Light white-grey gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Image.asset(
                  'assets/icons/scope1.png', // Add your logo asset path here
                  height: 200,
                ),
              ),
              Text(
                'Hi, Welcome!',
                style: TextStyle(
                  fontSize: 30,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10,),

              // Email TextField
              _buildModernTextField(
                controller: emailController,
                labelText: 'Email',
                isObscure: false,
              ),
              SizedBox(height: 16),

              // Password TextField
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
              SizedBox(height: 24),

              // Login Button
              Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  isLoading.value = true; // Start loading
                  authController.login(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  ).then((_) {
                    isLoading.value = false; // Stop loading after login
                  });
                },
                child: isLoading.value
                    ? Image.asset('assets/icons/loading.gif', height: 24) // Replace with your GIF asset path
                    : Text('Login', style: TextStyle(color: Colors.white, fontSize: 16)),
              )),
              // SizedBox(height: 16),

              // Sign Up Button
              TextButton(
                onPressed: () {
                  Get.toNamed(Routes.PROFILE_CREATION);
                },
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modern TextField Method
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String labelText,
    bool isObscure = false,
    Widget? suffixIcon,
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
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
