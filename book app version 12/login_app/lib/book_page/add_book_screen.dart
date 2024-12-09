import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_app/customDrawer.dart';
import 'package:login_app/custom_appbar.dart';

class AddBookScreen extends StatefulWidget {
  final User? user;
  const AddBookScreen({super.key, this.user});

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
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _ownersPhoneController = TextEditingController();
  final TextEditingController _ownersEmailController = TextEditingController();

  File? _image;
  File? _pdfFile; // File for PDF
  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 1; // Set initial selected index to 1 (Add Book)
  bool _isLoading = false; // Loading state

  Future<void> _pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
      });
    }
  }

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
      });
    }
  }

  Future<String?> _uploadFile(File file, String path) async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child(path);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<void> _addBook() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    String? imageUrl;
    String? pdfUrl;
    String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();

    // Upload image to Firebase Storage if available
    if (_image != null) {
      imageUrl = await _uploadFile(_image!, 'book_files/$uniqueId/image.jpg');
    }

    // Upload PDF to Firebase Storage if available
    if (_pdfFile != null) {
      pdfUrl = await _uploadFile(_pdfFile!, 'book_files/$uniqueId/book.pdf');
    }

    // Add book details to Firestore
    await FirebaseFirestore.instance.collection('books').add({
      'title': _titleController.text,
      'author': _authorController.text,
      'category': _categoryController.text,
      'ownersEmail': _ownersEmailController.text,
      'ownersPhone': _ownersPhoneController.text,
      'availability': _availabilityController.text,
      'pages': int.tryParse(_pagesController.text) ?? 0,
      'isbn': _isbnController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'image': imageUrl ?? '', // Store empty string if no image is uploaded
      'pdf': pdfUrl ?? '', // Store empty string if no PDF is uploaded
    });

    setState(() {
      _isLoading = false; // Hide loading indicator
    });

    // Show a success message using SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Book added successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3), // Duration the message will be shown
      ),
    );

    // Clear the text fields after adding
    _titleController.clear();
    _authorController.clear();
    _availabilityController.clear();
    _pagesController.clear();
    _isbnController.clear();
    _priceController.clear();
    _categoryController.clear();
    _ownersEmailController.clear();
    _ownersPhoneController.clear();
    setState(() {
      _image = null;
      _pdfFile = null;
    });

    // Optionally, navigate back or show a success message
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarForAll(title: 'Add Book'),
      drawer: CustomDrawer(user: widget.user),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextField(_titleController, 'Title', Icons.book),
                  _buildTextField(_authorController, 'Author', Icons.person),
                  _buildTextField(
                      _categoryController, 'Category', Icons.category),
                  _buildTextField(
                      _ownersEmailController, "Owner's Email", Icons.email),
                  _buildTextField(_ownersPhoneController,
                      "Owner's Phone Number", Icons.phone),
                  _buildTextField(_availabilityController, 'Availability',
                      Icons.check_circle),
                  _buildTextField(
                      _pagesController, 'Number of Pages', Icons.article,
                      isNumber: true),
                  _buildTextField(
                      _isbnController, 'Publication', Icons.book_online),
                  _buildTextField(_priceController, 'Price', Icons.attach_money,
                      isNumber: true), // Unicode Taka symbol for price

                  const SizedBox(height: 10),
                  _image != null
                      ? Image.file(_image!, height: 100)
                      : Image.asset('assets/icons/book_icon.png',
                          height: 100), // Default book icon

                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Pick Book Image',
                        style: TextStyle(color: Colors.white)),
                  ),

                  // PDF picking button
                  ElevatedButton(
                    onPressed: _pickPdf,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Pick Book PDF',
                        style: TextStyle(color: Colors.white)),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Add Book',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(), // Loading indicator
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromRGBO(20, 201, 71, 1),
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add Book'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books), label: 'Available Books'),
        ],
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (_selectedIndex) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/addBook');
              break;
            case 2:
              Navigator.pushNamed(context, '/availableBooks');
              break;
          }
        },
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumber = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 12, 160, 59)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
      ),
    );
  }
}
