import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerOrderPage extends StatefulWidget {
  final Map<String, dynamic> bookData;

  const CustomerOrderPage({super.key, required this.bookData});

  @override
  State<CustomerOrderPage> createState() => _CustomerOrderPageState();
}

class _CustomerOrderPageState extends State<CustomerOrderPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(); // Added for quantity
  bool _isLoading = false;
  double _totalPrice = 0.0;

  // Calculate total price based on the number of books and book price
  void _calculateTotalPrice() {
    final quantity = int.tryParse(_quantityController.text); // Parse quantity
    final pricePerBook = widget.bookData['price']; // Get price from bookData

    if (quantity != null && pricePerBook != null) {
      setState(() {
        // Convert quantity to double to match pricePerBook type
        _totalPrice = (quantity.toDouble()) * pricePerBook;
      });
    } else {
      setState(() {
        _totalPrice = 0.0;
      });
    }
  }

  Future<void> _confirmOrder() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      _showError('All fields are required.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Show confirmation dialog
        _showOrderConfirmationDialog();
      } else {
        _showError('User not logged in.');
      }
    } catch (e) {
      _showError('Failed to place order: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Show success dialog after placing order
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Order Confirmation'),
          content: const Text('Your order has been placed successfully!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show order confirmation dialog with Cancel and Confirm buttons
  void _showOrderConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Price: \$$_totalPrice'),
              const SizedBox(height: 10),
              const Text('Do you want to confirm the order?'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Save order data to Firestore
                await FirebaseFirestore.instance
                    .collection('customer_order')
                    .add({
                  'title': widget.bookData['title'],
                  'author': widget.bookData['author'],
                  'category': widget.bookData['category'],
                  'description': widget.bookData['description'],
                  'pages': widget.bookData['pages'],
                  'price': widget.bookData['price'],
                  'imageURL': widget.bookData['image'],
                  'pdfURL': widget.bookData['pdf'],
                  'publication': widget.bookData['publication'],
                  'ownersEmail': widget.bookData['ownersEmail'],
                  'ownersPhone': widget.bookData['ownersPhone'],
                  'customerName': _nameController.text,
                  'customerEmail': _emailController.text,
                  'customerPhone': _phoneController.text,
                  'customerAddress': _addressController.text,
                  'quantity': _quantityController.text,
                  'totalPrice': _totalPrice,
                  'orderDate': DateTime.now(),
                });

                Navigator.of(context).pop(); // Close the dialog
                _showSuccessDialog(); // Show success dialog
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTextField(_nameController, 'Name', Icons.person),
                _buildTextField(_emailController, 'Email', Icons.email),
                _buildTextField(_phoneController, 'Phone', Icons.phone),
                _buildTextField(_addressController, 'Address', Icons.home),
                _buildTextField(
                    _quantityController, 'Number of Books', Icons.book),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _calculateTotalPrice();
                    _confirmOrder();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Confirm Order'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
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
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: InputBorder.none,
        ),
        keyboardType: label == 'Number of Books'
            ? TextInputType.number
            : TextInputType.text,
      ),
    );
  }
}
