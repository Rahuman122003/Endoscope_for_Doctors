import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scope/screens/profileDetils.dart';
import '../controllers/profileController.dart';

class ManageClinicSettingsScreen extends StatelessWidget {
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        title: Text('Manage Clinic Settings', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey[900],
      ),
      backgroundColor: Colors.blueGrey[50],
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: profileController.fetchAllProfiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No profiles available.'));
          }

          List<Map<String, dynamic>> profiles = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              var profile = profiles[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        // Show Cupertino confirmation dialog before deletion
                        showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: Text('Delete Profile'),
                              content: Text('Are you sure you want to delete this profile?'),
                              actions: [
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  onPressed: () {
                                    Get.back(); // Close the dialog
                                  },
                                  child: Text('Cancel'),
                                ),
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  onPressed: () async {
                                    // Implement the delete functionality if needed
                                    Get.back(); // Close the dialog
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    title: Text(
                      profile['fullName'] != null ? profile['fullName'] : 'No Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    subtitle: Text(
                      profile['hospitalAddress'] != null ? profile['hospitalAddress'] : 'No Address',
                      style: TextStyle(
                        color: Colors.blueGrey[600],
                        fontSize: 14,
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueGrey[300]),
                    onTap: () {
                      Get.to(ProfileDetailScreen(profile: profile));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
