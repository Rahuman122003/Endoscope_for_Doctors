import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfController extends GetxController {
  var generatedPdfs = <Map<String, dynamic>>[].obs; // List to hold generated PDFs

  Future<void> generatePdf(Map<String, dynamic> profileData, Map<String, dynamic> patientData) async {
    try {
      final pdf = pw.Document();

      // Retrieve images from profileData
      final Uint8List logoImage = profileData['logo'];
      final Uint8List signatureImage = profileData['signature'];

      // Create the PDF content
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(profileData['hospitalName'], style: pw.TextStyle(fontSize: 24)),
              pw.Text(profileData['address']),
              pw.Text("${profileData['email']} | ${profileData['contact']}"),
              pw.Divider(),
              pw.Image(pw.MemoryImage(logoImage), width: 100, height: 100),
              pw.SizedBox(height: 20),
              pw.Text('Patient Name: ${patientData['name']}'),
              pw.Text('Age: ${patientData['age']}'),
              pw.Text('Gender: ${patientData['gender']}'),
              pw.SizedBox(height: 50),
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Image(pw.MemoryImage(signatureImage), width: 100, height: 50),
              ),
            ],
          ),
        ),
      );

      await savePdf(pdf);
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate PDF: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> savePdf(pw.Document pdf) async {
    try {
      // Check and request storage permission
      if (await Permission.storage.request().isGranted) {
        // Get directory to save the file
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory(); // For older Android versions
        } else {
          directory = await getApplicationDocumentsDirectory(); // For iOS or if needed for Android 11+
        }

        if (directory != null) {
          final path = "${directory.path}/patient_report_${DateTime.now().millisecondsSinceEpoch}.pdf";

          final file = File(path);
          await file.writeAsBytes(await pdf.save());

          // Add the PDF details to the list
          generatedPdfs.add({
            'fileName': 'patient_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
            'filePath': path,
            'createdOn': DateTime.now().toString(),
          });

          Get.snackbar('Success', 'PDF saved at $path', snackPosition: SnackPosition.BOTTOM);
        } else {
          Get.snackbar('Error', 'Unable to access directory', snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        Get.snackbar('Error', 'Storage permission not granted', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save PDF: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void viewOrDownloadPdf(String filePath) {
    // Implement functionality to view or download the PDF
    // For example, you might open the PDF file using a PDF viewer package
    Get.snackbar('PDF Open', 'Attempting to open or download PDF from $filePath',
        snackPosition: SnackPosition.BOTTOM);
  }
}
