import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class CustomPdfViewer extends StatelessWidget {
  final String filePath;

  const CustomPdfViewer({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View PDF"),
      ),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: true,
        onRender: (pages) {
          // PDF rendered callback
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
