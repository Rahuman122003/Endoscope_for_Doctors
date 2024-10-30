import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';
import '../controllers/patientController.dart';
import '../utilis/Navbar.dart';
import '../utilis/appColors.dart';
import '../utilis/reStartWidget.dart';
import '../utilis/routes.dart';

class HomeScreen2 extends StatelessWidget {
  final PatientController patientController = Get.put(PatientController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: SideNavBar(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            foregroundColor: Colors.white,
            actions: [
              IconButton(onPressed: (){
                restartApp();
              },
                  icon: Icon(Icons.restart_alt_rounded,size: 30,color: Colors.white,))
            ],
            pinned: true,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/icons/rrscopelogo.png', // Replace with your logo asset path
                  height: 150,
                ),
              ),
              background: Container(
                color: Colors.blueGrey,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(70.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildSearchBar(context),
              ),
            ),
          ),
          SliverFillRemaining(
            child: Obx(() {
              if (patientController.patients.isEmpty) {
                return Center(child: Text('No patients found'));
              }

              return ListView.builder(
                itemCount: patientController.patients.length,
                itemBuilder: (context, index) {
                  final patient = patientController.patients[index];
                  final patientName = patient['name'] ?? 'Unknown Name';
                  final firstLetter = patientName.isNotEmpty ? patientName[0].toUpperCase() : '';

                  return Dismissible(
                    key: Key(patient['id'] ?? ''),  // Null safety check
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Delete'),
                            content: Text(
                                'Are you sure you want to delete ${patient['name'] ?? 'this patient'}?'),  // Null safety check
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      // Remove the item from the list and database
                      patientController.deletePatient(patient['id'] ?? '');  // Null safety check
                      // Show a snackbar after deletion
                      Get.snackbar(
                        'Deleted',
                        '${patient['name'] ?? 'Patient'} was deleted successfully.',  // Null safety check
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      color: AppColors.textHint,
                      margin: EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5), // Minimalist margin
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueGrey,
                          child: Text(
                            firstLetter,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          patientName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Age: ${patient['age']?.toString() ?? 'N/A'}',  // Null safety check
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Get.toNamed(Routes.VIEW_PATIENT,
                              arguments: patient);
                        },
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        onPressed: () {
          Get.toNamed(Routes.ADD_PATIENT);
        },
        icon: Icon(Icons.person_add),
        label: const Text(
          'Add Patient',
          style: TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 40.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              onChanged: (query) {
                patientController.searchPatients(query);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search patients...',
              ),
            ),
          ),
        ],
      ),
    );
  }
  // void _showLogoutDialog(BuildContext context) {
  //   showCupertinoDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return CupertinoAlertDialog(
  //         title: Text(
  //           'Confirm Logout',
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold,
  //             fontSize: 18,
  //           ),
  //         ),
  //         content: Text('Are you sure you want to log out?'),
  //         actions: [
  //           CupertinoDialogAction(
  //             child: Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //           ),
  //           CupertinoDialogAction(
  //             child: Text('Logout'),
  //             isDestructiveAction: true, // Red color for iOS style
  //             onPressed: () {
  //               Get.toNamed(Routes.LOGOUT);// Close the dialog
  //
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}