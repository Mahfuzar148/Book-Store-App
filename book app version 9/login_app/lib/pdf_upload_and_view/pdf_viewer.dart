import 'dart:io'; // For file operations

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http; // For downloading files
import 'package:path_provider/path_provider.dart'; // For storing files locally

class CustomPdfViewer extends StatefulWidget {
  final String filePath; // Could be a local path or a URL

  const CustomPdfViewer({super.key, required this.filePath});

  @override
  _CustomPdfViewerState createState() => _CustomPdfViewerState();
}

class _CustomPdfViewerState extends State<CustomPdfViewer> {
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    _preparePdf();
  }

  // Prepare the PDF file (download if it's a URL, or use the local file path)
  void _preparePdf() async {
    if (Uri.parse(widget.filePath).isAbsolute) {
      // If the filePath is a URL, download the PDF
      String downloadedFilePath = await _downloadPdf(widget.filePath);
      setState(() {
        localFilePath = downloadedFilePath;
      });
    } else {
      // If it's already a local file, set the file path
      setState(() {
        localFilePath = widget.filePath;
      });
    }
  }

  // Function to download PDF from URL and save it locally
  Future<String> _downloadPdf(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Get the temporary directory
        final dir = await getTemporaryDirectory();
        // Create a temporary file to store the PDF
        final file = File("${dir.path}/downloaded_pdf.pdf");
        // Write the downloaded bytes to the file
        await file.writeAsBytes(response.bodyBytes);
        // Return the file path
        return file.path;
      } else {
        throw Exception("Failed to load PDF");
      }
    } catch (e) {
      print("Error downloading PDF: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View PDF"),
      ),
      body: localFilePath == null
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loader while the PDF is loading
          : PDFView(
              filePath: localFilePath!,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: true,
              onRender: (pages) {
                // PDF rendered callback
                print("PDF rendered with $pages pages");
              },
              onError: (error) {
                // Error callback
                print(error.toString());
              },
              onPageError: (page, error) {
                // Page error callback
                print('Page $page: ${error.toString()}');
              },
            ),
    );
  }
}
