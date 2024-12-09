import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class CustomPdfUploader extends StatefulWidget {
  final Function(String downloadURL)?
      onUploadSuccess; // Callback when upload is successful

  const CustomPdfUploader({super.key, this.onUploadSuccess});

  @override
  _CustomPdfUploaderState createState() => _CustomPdfUploaderState();
}

class _CustomPdfUploaderState extends State<CustomPdfUploader> {
  File? _pdfFile;
  bool _isUploading = false;

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadPdf(BuildContext context) async {
    if (_pdfFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String fileName = basename(_pdfFile!.path);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('book_pdf/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(_pdfFile!);

      await uploadTask.whenComplete(() async {
        String downloadURL = await firebaseStorageRef.getDownloadURL();
        widget.onUploadSuccess
            ?.call(downloadURL); // Notify the parent about the upload
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF uploaded successfully!')),
        );
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload PDF: $error')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _pickPdf,
          child: const Text('Pick PDF'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _uploadPdf(context),
          child: _isUploading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Upload Your PDF'),
        ),
      ],
    );
  }
}
