import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PDFViewerPage extends StatelessWidget {
  final String pdfUrl;

  const PDFViewerPage({required this.pdfUrl, super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure pdfUrl is not null or empty
    if (pdfUrl.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('PDF Viewer'),
        ),
        body: const Center(
          child: Text(
            'No PDF URL provided.',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: const PDF().cachedFromUrl(
        pdfUrl,
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(
          child: Text(
            'Error loading PDF: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
