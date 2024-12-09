import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadBookImage extends StatefulWidget {
  const UploadBookImage({super.key});

  @override
  State<UploadBookImage> createState() => _UploadBookImageState();
}

class _UploadBookImageState extends State<UploadBookImage> {
  // --- Image Picker instance ---
  final ImagePicker _imagePicker = ImagePicker();
  String? imageUrl; // Holds the image URL after uploading

  // --- Function to pick the image from gallery ---
  Future<void> pickImage() async {
    try {
      XFile? res = await _imagePicker.pickImage(source: ImageSource.gallery);

      if (res != null) {
        await uploadImageToFirebase(File(res.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed to pick image: $e"),
        ),
      );
    }
  }

  // --- Function to upload image to Firebase ---
  Future<void> uploadImageToFirebase(File image) async {
    try {
      Reference reference = FirebaseStorage.instance
          .ref()
          .child("images/${DateTime.now().microsecondsSinceEpoch}.png");

      await reference.putFile(image).whenComplete(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            content: Text("Image uploaded successfully"),
          ),
        );
      });

      String downloadUrl = await reference.getDownloadURL();

      setState(() {
        imageUrl = downloadUrl; // Update the image URL and rebuild the widget
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed to upload image: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Professional background color
      appBar: AppBar(
        title: const Text('Upload Book Image'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: [
              // --- Default Book Image Section start ---
              const CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white,
                child: Icon(Icons.book,
                    size: 100, color: Colors.blue), // Default book icon
              ),
              const SizedBox(height: 20),
              // --- Default Book Image Section end ---

              // --- Upload Book Image Button start ---
              ElevatedButton(
                onPressed: () {
                  pickImage(); // Call the function to pick and upload image
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 25.0), // Button padding
                  backgroundColor: Colors.blueGrey, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ), // Rounded corners
                ),
                child: const Text(
                  'Upload Book Image',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              // --- Upload Book Image Button end ---

              const SizedBox(height: 20),

              // --- Uploaded Image Section start ---
              if (imageUrl != null)
                Column(
                  children: [
                    const Text(
                      'Uploaded Image:',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Image.network(
                      imageUrl!,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              // --- Uploaded Image Section end ---
            ],
          ),
        ),
      ),
    );
  }
}
