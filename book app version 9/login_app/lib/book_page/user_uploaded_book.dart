import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserUploadedBooksPage extends StatefulWidget {
  const UserUploadedBooksPage({super.key});

  @override
  _UserUploadedBooksPageState createState() => _UserUploadedBooksPageState();
}

class _UserUploadedBooksPageState extends State<UserUploadedBooksPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;
  List<Map<String, dynamic>> uploadedBooks = [];
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUploadedBooks();
  }

  Future<void> _fetchUploadedBooks() async {
    currentUser = _auth.currentUser;

    if (currentUser != null) {
      try {
        // Fetch books where email matches the current user's email
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('books')
            .where('email', isEqualTo: currentUser!.email)
            .get();

        setState(() {
          uploadedBooks = snapshot.docs
              .map((doc) =>
                  {'id': doc.id, ...doc.data() as Map<String, dynamic>})
              .toList();
          isLoading = false;
        });
      } catch (error) {
        print('Error fetching uploaded books: $error');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateBookInfo(
      String bookId, Map<String, dynamic> bookData) async {
    TextEditingController titleController =
        TextEditingController(text: bookData['title']);
    TextEditingController authorController =
        TextEditingController(text: bookData['author']);
    TextEditingController descriptionController =
        TextEditingController(text: bookData['description']);

    String? imageUrl; // Declare the variable for the new image URL

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Book Info'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(titleController, 'Title', Icons.book),
                _buildTextField(authorController, 'Author', Icons.person),
                _buildTextField(
                    descriptionController, 'Description', Icons.description),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      String? newImageUrl =
                          await _uploadImage(File(image.path));
                      if (newImageUrl != null) {
                        imageUrl =
                            newImageUrl; // Update the imageUrl if new image is uploaded
                      }
                      // Trigger rebuild to show selected image
                      setState(() {});
                    }
                  },
                  child: const Text('Change Book Image'),
                ),
                const SizedBox(height: 10),
                // Show selected image if imageUrl is available
                if (imageUrl != null)
                  Image.file(File(imageUrl!),
                      height: 100), // Display the selected image
                // Show current image if available
                if (bookData['imageUrl'] != null)
                  Image.network(bookData['imageUrl'],
                      height: 100), // Display the current image
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Prepare data for update
                Map<String, dynamic> updatedData = {
                  'title': titleController.text,
                  'author': authorController.text,
                  'description': descriptionController.text,
                };

                // Update image URL only if a new one is selected
                if (imageUrl != null) {
                  updatedData['imageUrl'] = imageUrl;
                }

                // Update the book info in Firestore
                await FirebaseFirestore.instance
                    .collection('books')
                    .doc(bookId)
                    .update(updatedData);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Book info updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Reload the uploaded books after update
                await _fetchUploadedBooks();
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _uploadImage(File image) async {
    try {
      // Create a reference to the Firebase Storage location
      final ref = FirebaseStorage.instance
          .ref()
          .child('book_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(image); // Upload the image
      return await ref.getDownloadURL(); // Get and return the download URL
    } catch (e) {
      print('Error uploading image: $e');
      return null; // Handle error
    }
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Uploaded Books'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : uploadedBooks.isEmpty
              ? const Center(child: Text('No uploaded books available.'))
              : ListView.builder(
                  itemCount: uploadedBooks.length,
                  itemBuilder: (context, index) {
                    final book = uploadedBooks[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(book['title']),
                        subtitle: Text('Author: ${book['author']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _updateBookInfo(book['id'], book),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
