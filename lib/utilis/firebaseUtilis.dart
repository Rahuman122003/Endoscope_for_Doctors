import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUtil {
  // Save data to Firestore
  static Future<void> saveData(String collection, String doc, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection(collection).doc(doc).set(data);
    } catch (e) {
      print('Error saving data: $e');
      // Handle errors or show a message to the user if necessary
    }
  }

  // Update data in Firestore
  static Future<void> updateData(String collection, String doc, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection(collection).doc(doc).update(data);
    } catch (e) {
      print('Error updating data: $e');
      // Handle errors or show a message to the user if necessary
    }
  }

  // Delete a document from Firestore
  static Future<void> deleteData(String collection, String doc) async {
    try {
      await FirebaseFirestore.instance.collection(collection).doc(doc).delete();
    } catch (e) {
      print('Error deleting data: $e');
      // Handle errors or show a message to the user if necessary
    }
  }

  // Retrieve data from Firestore
  static Future<Map<String, dynamic>?> getData(String collection, String doc) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection(collection).doc(doc).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error retrieving data: $e');
      // Handle errors or show a message to the user if necessary
      return null;
    }
  }

  // Retrieve all documents from a collection
  static Future<List<Map<String, dynamic>>> getAllData(String collection) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collection).get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error retrieving all data: $e');
      // Handle errors or show a message to the user if necessary
      return [];
    }
  }

  // Stream data from a Firestore collection
  static Stream<List<Map<String, dynamic>>> streamData(String collection) {
    return FirebaseFirestore.instance.collection(collection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }
}
