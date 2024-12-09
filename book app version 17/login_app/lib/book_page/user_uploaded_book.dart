import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_app/custom_appbar.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchUploadedBooks();
  }

  Future<String> _getUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email ?? '';

      if (userEmail.isEmpty) {
        for (var provider in user.providerData) {
          if (provider.providerId == 'google.com') {
            userEmail = provider.email ?? '';
            break;
          }
        }
      }
      return userEmail;
    }
    return '';
  }

  Future<void> _fetchUploadedBooks() async {
    currentUser = _auth.currentUser;

    String userEmail = await _getUserEmail();

    if (userEmail.isNotEmpty) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('books')
            .where('ownersEmail', isEqualTo: userEmail)
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
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteBook(String bookId) async {
    try {
      await FirebaseFirestore.instance.collection('books').doc(bookId).delete();
      setState(() {
        uploadedBooks.removeWhere((book) => book['id'] == bookId);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Book deleted successfully'),
        duration: Duration(seconds: 2),
      ));
    } catch (error) {
      print('Error deleting book: $error');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error deleting book'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  void _updateBook(Map<String, dynamic> book) {
    // Push a new page to update book information
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateBookPage(book: book),
      ),
    ).then((updatedBook) {
      if (updatedBook != null) {
        setState(() {
          int index = uploadedBooks
              .indexWhere((item) => item['id'] == updatedBook['id']);
          if (index != -1) {
            uploadedBooks[index] = updatedBook;
          }
        });
      }
    });
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    String imageUrl = book['image'] ?? '';
    bool isValidUrl = Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false;

    // Debugging print statements
    debugPrint('Book title: ${book['title']}');
    debugPrint('Book image URL: $imageUrl');
    debugPrint('Is Valid URL: $isValidUrl');

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blueAccent, // Colorful border
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(8), // Padding inside the border
        child: Column(
          // Changed Row to Column here to allow vertical stacking
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and book info section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                Container(
                  height:
                      150, // Adjusting the height to a fixed value instead of double.infinity
                  width: MediaQuery.of(context).size.width * 0.45, // 45% width
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors
                        .grey.shade200, // Background for the image section
                  ),
                  child: isValidUrl
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover, // Ensure image fills the height
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded /
                                          (progress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error, size: 50);
                            },
                          ),
                        )
                      : const Icon(Icons.book, size: 50, color: Colors.grey),
                ),
                const SizedBox(width: 8), // Space between image and text
                // Book info section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        book['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow:
                            TextOverflow.visible, // Ensure full text is shown
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Author: ${book['author']}',
                        overflow:
                            TextOverflow.visible, // Ensure full text is shown
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${book['category']}',
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Price: \$${book['price']}',
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pages: ${book['pages']}',
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Space between book details and button
            // Update button section (placed below the card content)
            Center(
              child: IconButton(
                onPressed: () {
                  // Navigate to the UpdateBookPage with the current book data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateBookPage(book: book),
                    ),
                  );
                },
                icon: const FaIcon(
                  FontAwesomeIcons.pen, // Pen icon for "Update"
                  color: Colors.blue,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarForAll(title: 'Your Uploaded Books'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : uploadedBooks.isEmpty
              ? const Center(child: Text('No uploaded books available.'))
              : ListView.builder(
                  itemCount: uploadedBooks.length,
                  itemBuilder: (context, index) {
                    final book = uploadedBooks[index];
                    return _buildBookCard(book);
                  },
                ),
    );
  }
}

class UpdateBookPage extends StatefulWidget {
  final Map<String, dynamic> book;

  const UpdateBookPage({super.key, required this.book});

  @override
  _UpdateBookPageState createState() => _UpdateBookPageState();
}

class _UpdateBookPageState extends State<UpdateBookPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _pagesController;
  File? _imageFile; // For storing the selected image

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book['title']);
    _authorController = TextEditingController(text: widget.book['author']);
    _categoryController = TextEditingController(text: widget.book['category']);
    _descriptionController =
        TextEditingController(text: widget.book['description']);
    _priceController =
        TextEditingController(text: widget.book['price'].toString());
    _pagesController =
        TextEditingController(text: widget.book['pages'].toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  // Function to pick an image from gallery or camera
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery); // Change to ImageSource.camera for camera
    if (image != null) {
      setState(() {
        _imageFile = File(image.path); // Save the selected image
      });
    }
  }

  Future<void> _updateBook() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        String? imageUrl;

        if (_imageFile != null) {
          // Upload image to Firebase Storage
          final storageRef = FirebaseStorage.instance.ref().child(
              'book_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
          final uploadTask = storageRef.putFile(_imageFile!);
          final snapshot = await uploadTask.whenComplete(() {});
          imageUrl = await snapshot.ref
              .getDownloadURL(); // Get the URL of the uploaded image
        } else {
          // Use the current image URL from Firestore if no new image is selected
          imageUrl = widget.book['image'];
        }

        // Update book data in Firestore
        await FirebaseFirestore.instance
            .collection('books')
            .doc(widget.book['id'])
            .update({
          'title': _titleController.text,
          'author': _authorController.text,
          'category': _categoryController.text,
          'description': _descriptionController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'pages': int.tryParse(_pagesController.text) ?? 0,
          'image': imageUrl, // Update the image URL field
        });

        final updatedBook = {
          'id': widget.book['id'],
          'title': _titleController.text,
          'author': _authorController.text,
          'category': _categoryController.text,
          'description': _descriptionController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'pages': int.tryParse(_pagesController.text) ?? 0,
          'image': imageUrl, // Add image URL to the updated data
        };

        Navigator.pop(context, updatedBook);
      } catch (error) {
        print('Error updating book: $error');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error updating book'),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Book'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              Navigator.pop(context); // Cancel and return to the previous page
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Book Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an author';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pagesController,
                decoration: const InputDecoration(labelText: 'Pages'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of pages';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Image selection button
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Select Image from Gallery'),
                onPressed: _pickImage,
              ),
              const SizedBox(height: 16),
              // Preview selected image if available
              if (_imageFile != null)
                Image.file(
                  _imageFile!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateBook,
                child: const Text('Update Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
