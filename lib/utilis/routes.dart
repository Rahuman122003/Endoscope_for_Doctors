import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../screens/Settings.dart';
import '../screens/addScreen.dart';
import '../screens/createProfile.dart';
import '../screens/editProfile.dart';
import '../screens/generatedPdfScreen.dart';
import '../screens/homeScreen1.dart';
import '../screens/homeScreen2.dart';
import '../screens/loginScreen.dart';
import '../screens/logoutScreen.dart';
import '../screens/manageProfile.dart';
import '../screens/profile.dart';
import '../screens/profileDetils.dart';
import '../screens/splashScreen.dart';
import '../screens/viewScreen.dart';
import '../screens/editScreen.dart';
import '../screens/viewScreen2.dart'; // Ensure you have an edit screen.

class Routes {
  static const LOGIN = '/login';
  static const LOGOUT = '/logout';
  static const SETTINGS = '/settings';
  static const PROFILE_CREATION = '/profile-creation';
  static const HOME1 = '/home1';
  static const HOME2 = '/home2';
  static const ADD_PATIENT = '/add-patient';
  static const VIEW_PATIENT = '/view-patient';
  static const GENERATED_PDF_LIST = '/generated-pdf-list';
  static const EDIT_PATIENT = '/edit-patient'; // Added this line.
  static const MANAGE_CLINIC = '/manage-clinic'; // Added this line.
  static const PROFILE_DETAILS = '/profile-details';
  static const String SPLASH = '/splash';
  static const PROFILE = '/profile';
  static const EDIT_PROFILE = '/editProfile';
  static const VIEW_PATIENT2= '/view-patient';

  static final routes = [
    GetPage(name: SPLASH, page: () => SplashScreen()),
    GetPage(name: PROFILE, page: () => ProfileScreen()),
    GetPage(name: EDIT_PROFILE, page: () => EditProfileScreen()),
    GetPage(name: LOGIN, page: () => LoginScreen()),
    GetPage(name: LOGOUT, page: () => LogoutScreen()),
    GetPage(name: SETTINGS, page: () => SettingsScreen()),
    GetPage(name: PROFILE_CREATION, page: () => ProfileCreationScreen()),
    GetPage(name: HOME1, page: () => HomeScreen1()),
    GetPage(name: HOME2, page: () => HomeScreen2()),
    GetPage(name: ADD_PATIENT, page: () => AddPatientScreen()),
    GetPage(name: VIEW_PATIENT, page: () => ViewPatientScreen()), // Pass arguments here.
    GetPage(name: VIEW_PATIENT2, page: () => ViewPatientScreen2()), // Pass arguments here.
    GetPage(name: GENERATED_PDF_LIST, page: () => GeneratedPDFListScreen()),
    GetPage(name: EDIT_PATIENT, page: () => EditPatientScreen()),
    GetPage(name: MANAGE_CLINIC, page: () => ManageClinicSettingsScreen()),
    GetPage(name: PROFILE_DETAILS, page: () => ProfileDetailScreen(profile: {})), // Added edit screen route.
  ];
}
