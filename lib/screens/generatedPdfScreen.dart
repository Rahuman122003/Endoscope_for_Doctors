import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart'; // Import the printing package

class GeneratedPDFListScreen extends StatefulWidget {
  @override
  _GeneratedPDFListScreenState createState() => _GeneratedPDFListScreenState();
}

class _GeneratedPDFListScreenState extends State<GeneratedPDFListScreen> {
  List<File> _pdfFiles = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPDFs();
  }

  Future<void> _loadPDFs() async {
    try {
      // Get the app's document directory
      final directory = await getApplicationDocumentsDirectory();

      // List all files in the directory
      final List<FileSystemEntity> files = directory.listSync();

      // Filter the files to include only PDFs
      final List<File> pdfFiles = files
          .whereType<File>()
          .where((file) => file.path.endsWith('.pdf'))
          .toList();

      // Update the state to display the list of PDFs
      setState(() {
        _pdfFiles = pdfFiles;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading PDFs: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openPDFViewer(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(pdfFile: file),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Text('Generated PDFs'),
          backgroundColor: Colors.blueGrey,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Text('Generated PDFs'),
          backgroundColor: Colors.blueGrey,
        ),
        body: Center(child: Text(_errorMessage)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Generated PDFs'),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView.builder(
        itemCount: _pdfFiles.length,
        itemBuilder: (context, index) {
          final file = _pdfFiles[index];
          return ListTile(
            title: Text(file.path.split('/').last),
            trailing: Icon(Icons.picture_as_pdf),
            onTap: () => _openPDFViewer(file), // Open PDF viewer here
          );
        },
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final File pdfFile;

  PDFViewerScreen({required this.pdfFile});

  Future<void> _sharePDF() async {
    try {
      await Printing.sharePdf(
        bytes: await pdfFile.readAsBytes(),
        filename: pdfFile.path.split('/').last,
      );
    } catch (e) {
      print('Error sharing PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pdfFile.path.split('/').last),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _sharePDF, // Share PDF when button is pressed
          ),
        ],
      ),
      body: PDFView(
        filePath: pdfFile.path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onRender: (_pages) {},
        onError: (error) {
          print(error.toString());
        },
        onPageError: (page, error) {
          print('$page: ${error.toString()}');
        },
      ),
    );
  }
}
