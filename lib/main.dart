import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scope/utilis/routes.dart';

import 'controllers/profileController.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options for the platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final auth = FirebaseAuth.instance;
  Get.put(ProfileController());

  // Check if the user is already logged in
  User? user = auth.currentUser;
  String initialRoute = user == null ? '/login' : (user.email == "rrayushscope@gmail.com" ? Routes.HOME1 : Routes.HOME2);

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SCOPE',
      initialRoute: '/splash', // Set the initial route to the splash screen
      getPages: Routes.routes,
    );
  }
}