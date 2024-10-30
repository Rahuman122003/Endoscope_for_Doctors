import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class PatientController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var patients = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPatients();
  }

  Future<void> addPatient(Map<String, dynamic> patientData) async {
    isLoading.value = true;
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await firestore.collection('profiles').doc(userId)
          .collection('patients')
          .add(patientData);
      fetchPatients(); // Refresh the list after adding a patient
    } catch (e) {
      Get.snackbar("Error", e.toString());
      print("Error adding patient: $e");
      rethrow;
    } finally{
      isLoading.value = false;
    }
  }

  Future<void> updatePatient(String id,
      Map<String, dynamic> patientData) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await firestore.collection('profiles').doc(userId)
          .collection('patients')
          .doc(id)
          .update(patientData);
      fetchPatients(); // Refresh the list after updating a patient
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> deletePatient(String id) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await firestore.collection('profiles').doc(userId)
          .collection('patients')
          .doc(id)
          .delete();
      fetchPatients(); // Refresh the list after deleting a patient
    } catch (e) {
      Get.snackbar("Error", e.toString());
      print("Error deleting patient: $e");
    }
  }

  void fetchPatients() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot querySnapshot = await firestore.collection('profiles')
          .doc(userId)
          .collection('patients')
          .get();

      patients.value = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;  // Add document ID to the patient data
        return data;
      }).toList();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }


  Stream<List<Map<String, dynamic>>> streamPatients() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return firestore.collection('profiles').doc(userId)
        .collection('patients')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  void searchPatients(String query) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    if (query.isEmpty) {
      fetchPatients();  // If query is empty, reload all patients
    } else {
      var searchResult = await firestore.collection('profiles')
          .doc(userId)
          .collection('patients')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')  // Ensure correct range for search
          .get();

      patients.value = searchResult.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;  // Add document ID to the search result
        return data;
      }).toList();
    }
  }


}

