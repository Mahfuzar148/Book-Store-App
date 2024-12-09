import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(book['title']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Author: ${book['author']}'),
            Text('Category: ${book['category']}'),
            Text('Price: \$${book['price']}'),
            Text('Pages: ${book['pages']}'),
          ],
        ),
        leading: isValidUrl
            ? Image.network(
                imageUrl,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
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
              )
            : const Icon(Icons.book, size: 50),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.pen),
              onPressed: () => _updateBook(book),
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.trash),
              onPressed: () => _deleteBook(book['id']),
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

  Future<void> _updateBook() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
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
        });

        final updatedBook = {
          'id': widget.book['id'],
          'title': _titleController.text,
          'author': _authorController.text,
          'category': _categoryController.text,
          'description': _descriptionController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'pages': int.tryParse(_pagesController.text) ?? 0,
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
