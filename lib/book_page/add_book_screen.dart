import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _availabilityController = TextEditingController();
  final TextEditingController _pagesController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 1; // Set initial selected index to 1 (Add Book)

  Future<void> _pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref =
          FirebaseStorage.instance.ref().child('book_images/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _addBook() async {
    String? imageUrl;

    // Upload image to Firebase Storage if available
    if (_image != null) {
      imageUrl = await _uploadImage(_image!);
    }

    // Add book details to Firestore
    await FirebaseFirestore.instance.collection('books').add({
      'title': _titleController.text,
      'author': _authorController.text,
      'availability': _availabilityController.text,
      'pages': int.tryParse(_pagesController.text) ?? 0,
      'isbn': _isbnController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'image': imageUrl ?? '', // Store empty string if no image is uploaded
    });

    // Clear the text fields after adding
    _titleController.clear();
    _authorController.clear();
    _availabilityController.clear();
    _pagesController.clear();
    _isbnController.clear();
    _priceController.clear();
    setState(() {
      _image = null;
    });

    // Optionally, navigate back or show a success message
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book',
            style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 12, 160, 59),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open drawer
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Book Management Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: const Text('Home'),
              onTap: () => Navigator.pushNamed(context, '/home'),
            ),
            ListTile(
              leading: const Icon(Icons.book, color: Colors.blue),
              title: const Text('Add Book'),
              onTap: () => Navigator.pushNamed(context, '/addBook'),
            ),
            ListTile(
              leading: const Icon(Icons.library_books, color: Colors.blue),
              title: const Text('Available Books'),
              onTap: () => Navigator.pushNamed(context, '/availableBooks'),
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.blue),
              title: const Text('Search Books'),
              onTap: () => Navigator.pushNamed(context, '/searchBooks'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
            TextField(
              controller: _availabilityController,
              decoration: const InputDecoration(labelText: 'Availability'),
            ),
            TextField(
              controller: _pagesController,
              decoration: const InputDecoration(labelText: 'Number of Pages'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _isbnController,
              decoration: const InputDecoration(labelText: 'ISBN'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            // Show real book icon if no image is selected
            _image != null
                ? Image.file(_image!, height: 100)
                : Image.asset('assets/icons/book_icon.png',
                    height: 100), // Default book icon
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Pick Book Image',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child:
                  const Text('Add Book', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromRGBO(20, 201, 71, 1),
        unselectedItemColor: const Color.fromARGB(255, 152, 9, 9),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Book'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'Available Books'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Search Books'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/addBook');
              break;
            case 2:
              Navigator.pushNamed(context, '/availableBooks');
              break;
            case 3:
              Navigator.pushNamed(context, '/searchBooks');
              break;
          }
        },
      ),
    );
  }
}
