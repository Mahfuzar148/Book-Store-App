import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

Future<String?> uploadImage() async {
  final ImagePicker picker = ImagePicker();
  // Let the user pick an image
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    File imageFile = File(image.path);
    try {
      // Generate a unique file name
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('book_images/$fileName');

      // Upload the image to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL of the uploaded image
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL; // Return the image URL
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  } else {
    print('No image selected.');
    return null;
  }
}
