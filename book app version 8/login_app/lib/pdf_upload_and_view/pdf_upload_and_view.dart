import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_app/pdf_upload_and_view/pdf_uploader.dart';
import 'package:login_app/pdf_upload_and_view/pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';

class MyPdfPage extends StatefulWidget {
  const MyPdfPage({super.key});

  @override
  _MyPdfPageState createState() => _MyPdfPageState();
}

class _MyPdfPageState extends State<MyPdfPage> {
  String? _uploadedFileURL;

  void _onUploadSuccess(String downloadURL) {
    setState(() {
      _uploadedFileURL = downloadURL;
    });
  }

  Future<void> _viewUploadedPdf(BuildContext context) async {
    if (_uploadedFileURL != null) {
      // Download the PDF file from the URL
      String localPath = await _downloadFile(_uploadedFileURL!);
      // Navigate to PDFViewerPage and pass the local file path
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomPdfViewer(filePath: localPath),
        ),
      );
    }
  }

  Future<String> _downloadFile(String url) async {
    try {
      Dio dio = Dio();
      Directory tempDir = await getTemporaryDirectory();
      String fileName =
          url.split('/').last; // Extract the file name from the URL
      String filePath = '${tempDir.path}/$fileName';

      await dio.download(url, filePath);
      return filePath; // Return the local path of the downloaded file
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Upload & View')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPdfUploader(onUploadSuccess: _onUploadSuccess),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadedFileURL != null
                  ? () => _viewUploadedPdf(context)
                  : null,
              child: const Text('View Uploaded PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
