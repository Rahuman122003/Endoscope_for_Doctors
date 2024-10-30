import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scope/utilis/routes.dart';
import '../controllers/profileController.dart';
import '../screens/generatedPdfScreen.dart';
import '../screens/profile.dart';

class SideNavBar extends StatelessWidget {
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final userProfile = profileController.currentUserProfile.value;

    return Drawer(
      child: Column(
        children: [
          // User Profile Header
          UserAccountsDrawerHeader(
            accountName: Text(userProfile?['fullName'] ?? 'Unknown'),
            accountEmail: Text(userProfile?['email'] ?? 'No Email'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: TextButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black54)),
                 onPressed: () {
                   Navigator.of(context).pop(); // Close the drawer
                   Get.to(() => ProfileScreen()); // Navigate to ProfileScreen
                 },
                child:Text(
                    (userProfile?['fullName']?.isNotEmpty ?? false)
                  ? userProfile!['fullName']![0]
                  : '?',
                style: TextStyle(fontSize: 35.0, color: Colors.white)),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
            ),
          ),
          // List of options
          // ListTile(
          //   leading: Icon(Icons.person),
          //   title: Text('Profile'),
          //   onTap: () {
          //     Navigator.of(context).pop(); // Close the drawer
          //     Get.to(() => ProfileScreen()); // Navigate to ProfileScreen
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.picture_as_pdf),
            title: Text('Generated PDFs'),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              Get.to(() => GeneratedPDFListScreen()); // Navigate to GeneratedPDFListScreen
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text('Logout'),
            onTap: (){
              _showLogoutDialog(context);
            },
          )
        ],
      ),
    );
  }
  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            'Confirm Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text('Are you sure you want to log out?'),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            CupertinoDialogAction(
              child: Text('Logout'),
              isDestructiveAction: true, // Red color for iOS style
              onPressed: () {
                Get.toNamed(Routes.LOGOUT);// Close the dialog

              },
            ),
          ],
        );
      },
    );
  }
}
