import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../controllers/profileController.dart';
import '../controllers/patientController.dart';
import 'package:http/http.dart' as http;

class ViewPatientScreen extends StatelessWidget {
  final PatientController patientController = Get.find();
  final ProfileController profileController = Get.find();

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? patient = Get.arguments as Map<String,
        dynamic>?;

    if (patient == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Go Back'),
          backgroundColor: Colors.blueGrey,
        ),
        body: Center(
          child: Text(
            'Your device routing to Printer \n Go back',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          patient['name'] ?? 'Patient Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),

            // Row to display two columns of patient details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetail('Patient Name', patient['name']),
                      _buildDetail('Age', patient['age']),
                      _buildDetail('Gender', patient['gender']),
                      _buildDetail('Date', patient['location']),
                      _buildDetail('Study', patient['study']),
                    ],
                  ),
                ),

                // Right Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetail('Phone',
                          '${patient['countryCode']} ${patient['phoneNumber']}'),
                      _buildDetail('Examined By', patient['examinedBy']),
                      _buildDetail('Referred By', patient['referredBy']),
                      _buildDetail('Impression', patient['impressionComment']),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Image Grid Section
            _buildPatientImageGrid(patient['imageUrls'] ?? []),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => AlertDialog(
              title: Text('Generating PDF'),
              content: Column(
                mainAxisSize: MainAxisSize.min, // Adjust to fit content
                children: [
                  Image.asset(
                    'assets/icons/pdf.gif', // Loading GIF path
                    height: 300, // Adjust height as needed
                    width: 300, // Adjust width as needed
                  ),
                  Text('Please wait while your PDF is being generated.',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold,fontSize: 20),),
                ],
              ),
            ),
          );

          await _generatePDF(context, patient);
          Navigator.of(context).pop(); // Close the loading dialog
        },
        label: Text('Download PDF'),
        icon: Icon(Icons.file_download),
      ),
    );
  }

  // Build Detail for patient data
  Widget _buildDetail(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          text: '$title: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
          children: [
            TextSpan(
              text: value ?? 'N/A',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Grid for Patient Images
  Widget _buildPatientImageGrid(List<dynamic>? imageUrls) {
    if (imageUrls == null || imageUrls.isEmpty) {
      return Center(
        child: Text(
          'No images available',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 2,
                    blurRadius: 6,
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(imageUrls[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 5),
          ],
        );
      },
    );
  }

  // Generate the PDF with patient details and images
  Future<void> _generatePDF(BuildContext context,
      Map<String, dynamic> patient) async {
    final pdf = pw.Document();

    // Get the ProfileController and fetch the current user profile
    final ProfileController profileController = Get.find<ProfileController>();
    final Map<String, dynamic>? profile = profileController.currentUserProfile
        .value;

    if (profile == null) {
      Get.snackbar('Error', 'No profile data available');
      return;
    }

    // Fetch all images before generating the PDF
    final List<pw.ImageProvider> imageProviders = await Future.wait(
      (patient['imageUrls'] as List<dynamic>).map<Future<pw.ImageProvider>>((
          url) async {
        return await _getNetworkImage(
            url as String); // Ensure the URL is a String
      }).toList(),
    );

    // Fetch logo and signature images
    final pw.ImageProvider logoImage = await _getNetworkImage(
        profile['logoUrl'] ?? '');
    final pw.ImageProvider signatureImage = await _getNetworkImage(
        profile['signatureUrl'] ?? '');

    // Generate the PDF content with the profile in the header
// Inside the _generatePDF function
    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with Logo
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(logoImage, width: 80, height: 80),
                  pw.SizedBox(width: 16), // Spacing between logo and text
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          profile['hospitalName'] ?? 'Hospital Name',
                          style: pw.TextStyle(
                              fontSize: 24, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          profile['hospitalAddress'] ?? 'Hospital Address',
                          style: pw.TextStyle(
                              fontSize: 20, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          '${profile['contactNumber']} | ${profile['email']}',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Divider(),

              // Patient Details in two columns
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildPDFDetail('Patient Name', patient['name']),
                        _buildPDFDetail('Age', patient['age']),
                        _buildPDFDetail('Gender', patient['gender']),
                        _buildPDFDetail('Date', patient['location']),

                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildPDFDetail('Study', patient['study']),
                        _buildPDFDetail('Phone', '${patient['countryCode']} ${patient['phoneNumber']}'),
                        _buildPDFDetail('Examined By', patient['examinedBy']),
                        _buildPDFDetail('Referred By', patient['referredBy']),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Divider(),

              // Display Images in Grid, shifted right
              pw.Padding(
                padding: pw.EdgeInsets.only(left: 70), // Adjust left padding to shift right
                child: pw.Wrap(
                  alignment: pw.WrapAlignment.center, // Align images to center
                  spacing: 10,
                  runSpacing: 10,
                  children: imageProviders.map((imageProvider) {
                    return pw.Container(
                      width: 200,
                      height: 200,
                      child: pw.Image(imageProvider, fit: pw.BoxFit.cover),
                    );
                  }).toList(),
                ),
              ),

              pw.SizedBox(height: 20),

              // Centered Impression Comment
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Impression:',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      patient['impressionComment'] ?? 'N/A',
                      style: pw.TextStyle(fontSize: 18),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Signature:',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Image(signatureImage, width: 200, height: 60),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );


    // Save PDF to file
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String fullPath = '$dir/${patient['name']}_report.pdf';
    final File file = File(fullPath);
    await file.writeAsBytes(await pdf.save());

    // Display or download PDF
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  // Build Detail for PDF
  pw.Widget _buildPDFDetail(String title, String? value) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 8),
      child: pw.RichText(
        text: pw.TextSpan(
          text: '$title: ',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
          children: [
            pw.TextSpan(
              text: value ?? 'N/A',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.normal, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  // Fetch image from network
  Future<pw.ImageProvider> _getNetworkImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return pw.MemoryImage(response.bodyBytes);
    } else {
      throw Exception('Failed to load image');
    }
  }
}