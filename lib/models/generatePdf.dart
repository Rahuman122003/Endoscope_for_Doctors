import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart'as http;

void generatePatientPdf(Map<String, dynamic> profile, Map<String, dynamic> patient) async {
  final pdf = pw.Document();

  final profileLogo = pw.MemoryImage(
    (await rootBundle.load('assets/logo.png')).buffer.asUint8List(), // Use profile logo path or URL
  );

  final signature = pw.MemoryImage(
    (await rootBundle.load('assets/signature.png')).buffer.asUint8List(), // Use profile signature path or URL
  );

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(16),
      build: (pw.Context context) {
        return [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header section with hospital name, address, email, and contact
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    profile['hospital'],
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Image(profileLogo, width: 50),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text(profile['location'], style: pw.TextStyle(fontSize: 14)),
              pw.Text('Email: ${profile['email']} | Contact: ${profile['contactNumber']}'),
              pw.Divider(),

              // Patient details split left and right
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Patient Name: ${patient['name']}', style: pw.TextStyle(fontSize: 14)),
                        pw.Text('Age: ${patient['age']}', style: pw.TextStyle(fontSize: 14)),
                        pw.Text('Gender: ${patient['gender']}', style: pw.TextStyle(fontSize: 14)),
                        pw.Text('Study: ${patient['study']}', style: pw.TextStyle(fontSize: 14)),
                        pw.Text('Examined By: ${patient['examinedBy']}', style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Phone: ${patient['countryCode']} ${patient['phoneNumber']}', style: pw.TextStyle(fontSize: 14)),
                        pw.Text('Referred By: ${patient['referredBy']}', style: pw.TextStyle(fontSize: 14)),
                        pw.Text('Location: ${patient['location']}', style: pw.TextStyle(fontSize: 14)),
                        pw.Text('Impression Comment: ${patient['impressionComment']}', style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),

              // Image section
              if (patient['imageUrls'] != null && patient['imageUrls'].isNotEmpty) ...[
                pw.Text('Patient Images:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.GridView(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: patient['imageUrls'].map<pw.Widget>((url) async {
                    return pw.Column(
                        children: [
                    pw.Image(pw.MemoryImage((await networkImage(url)).buffer.asUint8List()), height: 100, width: 100),
                    pw.SizedBox(height: 5),
                    pw.Text(patient['imageNames'][patient['imageUrls'].indexOf(url)], textAlign: pw.TextAlign.center),
                    ],
                    );
                  }).toList(),
                ),
              ],

              // Signature at the bottom
              pw.SizedBox(height: 50),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('Signature:', style: pw.TextStyle(fontSize: 12)),
                      pw.Image(signature, width: 80),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ];
      },
    ),
  );

  // Save or print the PDF
  await Printing.sharePdf(bytes: await pdf.save(), filename: 'Patient_Details.pdf');
}

Future<Uint8List> networkImage(String url) async {
  final response = await http.get(Uri.parse(url));
  return response.bodyBytes;
}
