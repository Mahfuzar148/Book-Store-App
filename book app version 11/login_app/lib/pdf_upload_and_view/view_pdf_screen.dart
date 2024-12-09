import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class ViewPdfScreen extends StatefulWidget {
  const ViewPdfScreen({super.key});

  @override
  _ViewPdfScreenState createState() => _ViewPdfScreenState();
}

class _ViewPdfScreenState extends State<ViewPdfScreen> {
  String? _pdfUrl;

  Future<void> _getPdfUrl() async {
    Reference pdfRef = FirebaseStorage.instance.ref().child('pdfs/sample.pdf');
    String url = await pdfRef.getDownloadURL();

    setState(() {
      _pdfUrl = url;
    });
  }

  Future<void> _downloadPdf() async {
    if (_pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No PDF found to download')),
      );
      return;
    }

    Dio dio = Dio();

    // Request permission to write to storage
    var status = await Permission.storage.request();
    if (status.isGranted) {
      Directory? directory = Directory('/storage/emulated/0/Download');
      String downloadPath = '${directory.path}/sample.pdf';

      try {
        await dio.download(_pdfUrl!, downloadPath);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF downloaded successfully!')),
        );
        OpenFile.open(downloadPath);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View PDF')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _getPdfUrl();
                if (_pdfUrl != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF URL retrieved')),
                  );
                }
              },
              child: const Text('View PDF'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _downloadPdf,
              child: const Text('Download PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
