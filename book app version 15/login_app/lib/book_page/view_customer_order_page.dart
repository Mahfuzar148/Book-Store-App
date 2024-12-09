// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:login_app/custom_appbar.dart';
import 'package:url_launcher/url_launcher.dart'; // For email and call actions

class ViewCustomerOrderPage extends StatefulWidget {
  const ViewCustomerOrderPage({super.key});

  @override
  _ViewCustomerOrderPageState createState() => _ViewCustomerOrderPageState();
}

class _ViewCustomerOrderPageState extends State<ViewCustomerOrderPage> {
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }

  Future<void> _getUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email ?? '';

      if (email.isEmpty) {
        for (var provider in user.providerData) {
          if (provider.providerId == 'google.com') {
            email = provider.email ?? '';
            break;
          }
        }
      }
      setState(() {
        userEmail = email;
      });
    }
  }

  Stream<QuerySnapshot> getCustomerOrdersStream() {
    return FirebaseFirestore.instance
        .collection('customer_order')
        .where('ownersEmail', isEqualTo: userEmail)
        .snapshots();
  }

  Widget buildCustomerOrderList(AsyncSnapshot<QuerySnapshot> snapshot) {
    final orders = snapshot.data!.docs;

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

  Widget buildCustomerCard(
      String customerName, List<Map<String, dynamic>> customerOrders) {
    return Card(
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      shadowColor: Colors.black45,
      child: InkWell(
        onTap: () {
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
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent,
                Colors.indigo.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            leading: const Icon(
              FontAwesomeIcons.userAlt,
              color: Colors.white,
              size: 30.0,
            ),
            title: Text(
              customerName,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: const Text(
              'View orders',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white70,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  FontAwesomeIcons.arrowRight,
                  color: Colors.white,
                  size: 20.0,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    await _deleteOrder(customerName);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteOrder(String customerName) async {
    try {
      // Print customer info to console
      //print('Deleting all orders for customer: $customerName');

      // Show confirmation dialog before deleting
      bool? shouldDelete = await _showDeleteConfirmationDialog();
      if (shouldDelete != true) return;

      // Delete all orders for the specified customer by filtering on customerName
      final ordersQuerySnapshot = await FirebaseFirestore.instance
          .collection('customer_order')
          .where('customerName', isEqualTo: customerName)
          .get();

      // Loop through the fetched orders and delete each from Firestore
      for (var order in ordersQuerySnapshot.docs) {
        final orderId = order.id; // Get the document ID as the order ID
        await FirebaseFirestore.instance
            .collection('customer_order')
            .doc(orderId) // Use the order ID to delete the document
            .delete();
        //print('Deleted order with ID: $orderId');
      }

      // After successful deletion, show a confirmation SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Deleted all orders for customer: $customerName')),
      );
    } catch (e) {
      // In case of an error, show an error SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting orders: $e')),
      );
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete these orders?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
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
        title: const Text('Customer Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
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

  Future<void> _makeCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not make the call to $phoneNumber';
    }
  }

  Future<void> _sendEmail(String emailAddress) async {
    final url = 'mailto:$emailAddress';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not send email to $emailAddress';
    }
  }

  void showCustomerInfoDialog(BuildContext context, String customerName,
      String email, String phone, String address) {
    // Helper function to launch Google Maps
    Future<void> openGoogleMaps(String address) async {
      final Uri googleMapsUri = Uri(
        scheme: 'https',
        host: 'www.google.com',
        path: '/maps/search/',
        queryParameters: {'q': address},
      );

      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(
          googleMapsUri,
          mode: LaunchMode
              .externalApplication, // Ensures it opens in Google Maps or the browser
        );
      } else {
        throw Exception('Could not open Google Maps for $address');
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 10.0,
          child: Container(
            padding: const EdgeInsets.all(20.0),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(
                colors: [Colors.blueAccent.shade200, Colors.indigoAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Info: $customerName',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.locationDot,
                        color: Colors.white),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            openGoogleMaps(address), // Open Google Maps
                        child: Text(
                          'Address: $address',
                          style: const TextStyle(
                            color: Colors.white,

                            // Underline to indicate clickable text
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.envelope,
                        color: Colors.white),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Email: $email',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.phone, color: Colors.white),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Phone: $phone',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5.0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _sendEmail(email); // Send email
                      },
                      icon: const FaIcon(FontAwesomeIcons.envelope,
                          color: Colors.white),
                      label: const Text('Email ',
                          style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5.0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _makeCall(phone); // Make a call
                      },
                      icon: const FaIcon(FontAwesomeIcons.phone,
                          color: Colors.white),
                      label: const Text(
                        'Call',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 5.0,
                    ),
                    onPressed: () {
                      openGoogleMaps(address); // Open Google Maps
                    },
                    icon: const FaIcon(FontAwesomeIcons.mapMarkerAlt,
                        color: Colors.white),
                    label: const Text('Search Address',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12.0),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 5.0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const FaIcon(FontAwesomeIcons.timesCircle,
                        color: Colors.white),
                    label: const Text('Close',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildCustomerInfoCard(BuildContext context) {
    final order = orders.first;
    final customerName = order['customerName'] ?? 'Not available';
    final customerEmail = order['customerEmail'] ?? 'Not available';
    final customerPhone = order['customerPhone'] ?? 'Not available';
    final customerAddress = order['customerAddress'] ?? 'Not available';

    return Card(
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: InkWell(
        onTap: () {
          showCustomerInfoDialog(
            context,
            customerName,
            customerEmail,
            customerPhone,
            customerAddress,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blueAccent.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30.0,
                  backgroundColor: Colors.white,
                  child: FaIcon(
                    FontAwesomeIcons.user,
                    color: Colors.blueAccent.shade700,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Text(
                        'Tap to view more details',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showCustomerInfoDialog(
                      context,
                      customerName,
                      customerEmail,
                      customerPhone,
                      customerAddress,
                    );
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.infoCircle,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOrderCard(Map<String, dynamic> book, double totalPrice) {
    return Card(
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade300, Colors.tealAccent.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Image
              if (book['imageURL'] != null && book['imageURL'].isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    book['imageURL'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 12.0),

              // Book Title
              Text(
                book['title'] ?? 'No Title',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6.0),

              // Book Author
              Text(
                'Author: ${book['author'] ?? 'Unknown'}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 10.0),

              // Total Price
              Text(
                'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCustomerOrderDetailList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders.length + 1,
      itemBuilder: (context, index) {
        // Final summary card for customer info
        if (index == orders.length) {
          return buildCustomerInfoCard(context);
        }

        // Order card with enhanced 3D design
        final order = orders[index];
        final book = order;
        final totalPrice = order['totalPrice'];

        return Card(
          elevation: 15.0,
          margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade300, Colors.purple.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Image (if available)
                  if (book['imageURL'] != null && book['imageURL'].isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        book['imageURL'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 12.0),

                  // Book Title
                  Text(
                    book['title'] ?? 'No Title Available',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Book Author
                  Text(
                    'Author: ${book['author'] ?? 'Unknown Author'}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Total Price
                  Text(
                    'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarForAll(title: 'Orders of $customerName'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 20, // Higher elevation for a strong 3D effect
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            shadowColor: Colors.black45,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  Text(
                    'Orders of $customerName',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),

                  // List of Orders
                  Expanded(
                    child: buildCustomerOrderDetailList(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
