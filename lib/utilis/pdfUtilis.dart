import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfUtils {
  static pw.Document generatePatientPdf(Map<String, dynamic> patient) {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('Patient Details')),
              pw.Text('Full Name: ${patient['name']}'),
              pw.Text('Age: ${patient['age']}'),
              pw.Text('Gender: ${patient['gender']}'),
              pw.Text('Phone Number: ${patient['phoneNumber']}'),
              pw.Text('Study: ${patient['study']}'),
              pw.Text('Examined By: ${patient['examinedBy']}'),
              pw.Text('Referred By: ${patient['referredBy']}'),
              pw.Text('Location: ${patient['location']}'),
              pw.Text('Impression Comment: ${patient['impressionComment']}'),
            ],
          );
        },
      ),
    );
    return pdf;
  }
}
