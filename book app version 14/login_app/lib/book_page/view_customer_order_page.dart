import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import for the call button

class ViewCustomerOrderPage extends StatefulWidget {
  const ViewCustomerOrderPage({super.key});

  @override
  _ViewCustomerOrderPageState createState() => _ViewCustomerOrderPageState();
}

class _ViewCustomerOrderPageState extends State<ViewCustomerOrderPage> {
  String userEmail = ''; // Variable to hold the logged-in user's email

  @override
  void initState() {
    super.initState();
    _getUserEmail(); // Get the user's email when the page loads
  }

  // Method to get the current user's email
  Future<void> _getUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email ?? '';

      // If email is empty, check the provider data for Google email
      if (email.isEmpty) {
        for (var provider in user.providerData) {
          if (provider.providerId == 'google.com') {
            email = provider.email ?? '';
            break;
          }
        }
      }
      setState(() {
        userEmail = email; // Update the state with the user's email
      });
    }
  }

  // Function to fetch orders stream based on the user email
  Stream<QuerySnapshot> getCustomerOrdersStream() {
    return FirebaseFirestore.instance
        .collection('customer_order')
        .where('ownersEmail', isEqualTo: userEmail) // Filter by owner's email
        .snapshots();
  }

  // Function to handle building the list of customer orders
  Widget buildCustomerOrderList(AsyncSnapshot<QuerySnapshot> snapshot) {
    final orders = snapshot.data!.docs;

    // Collect customer names from the orders
    final customers = <String, List<Map<String, dynamic>>>{};

    for (var order in orders) {
      final customerName = order['customerName'];
      if (!customers.containsKey(customerName)) {
        customers[customerName] = [];
      }
      customers[customerName]?.add(order.data() as Map<String, dynamic>);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: customers.keys.length,
      itemBuilder: (context, index) {
        final customerName = customers.keys.elementAt(index);
        final customerOrders = customers[customerName]!;

        return buildCustomerCard(customerName, customerOrders);
      },
    );
  }

  // Function to build the customer card widget
  Widget buildCustomerCard(
      String customerName, List<Map<String, dynamic>> customerOrders) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // When a customer name is tapped, navigate to view their orders
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerOrderDetailPage(
                customerName: customerName,
                orders: customerOrders,
              ),
            ),
          );
        },
        child: ListTile(
          title: Text(customerName),
          subtitle: const Text('View orders'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getCustomerOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Loading...'));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          return buildCustomerOrderList(snapshot);
        },
      ),
    );
  }
}

class CustomerOrderDetailPage extends StatelessWidget {
  final String customerName;
  final List<Map<String, dynamic>> orders;

  const CustomerOrderDetailPage({
    super.key,
    required this.customerName,
    required this.orders,
  });

  // Function to launch phone dialer
  Future<void> _makeCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not make the call to $phoneNumber';
    }
  }

  // Function to show customer info dialog
  void showCustomerInfoDialog(
      BuildContext context, String customerEmail, String customerPhone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Customer Info: $customerName'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: $customerEmail'),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Text('Phone: $customerPhone'),
                  IconButton(
                    icon: const Icon(Icons.phone),
                    onPressed: () {
                      _makeCall(customerPhone); // Make the call
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to build the customer order detail list
  Widget buildCustomerOrderDetailList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders.length + 1, // Add one for the customer info button
      itemBuilder: (context, index) {
        if (index == orders.length) {
          // Display the customer info button
          return buildCustomerInfoCard(context);
        }

        final order = orders[index];
        final book = order;
        final totalPrice = order['totalPrice'];

        return buildOrderCard(book, totalPrice);
      },
    );
  }

  // Function to build order card widget
  Widget buildOrderCard(Map<String, dynamic> book, double totalPrice) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the book image (if available)
            if (book['imageURL'] != null && book['imageURL'].isNotEmpty)
              Image.network(
                book['imageURL'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 8.0),
            Text(
              book['title'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            Text(
              'Author: ${book['author'] ?? 'Unknown'}',
              style: const TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Total Price: \$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Function to build customer info card
  Widget buildCustomerInfoCard(BuildContext context) {
    const customerEmail = 'customer@example.com'; // Replace with actual data
    const customerPhone = '1234567890'; // Replace with actual data

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          showCustomerInfoDialog(context, customerEmail, customerPhone);
        },
        child: const ListTile(
          title: Text('Customer Info'),
          subtitle: Text('View customer details'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$customerName Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: buildCustomerOrderDetailList(context),
    );
  }
}
