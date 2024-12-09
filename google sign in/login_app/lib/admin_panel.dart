import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  bool isAdmin = false; // To check if the logged-in user is admin
  List<DocumentSnapshot> users = []; // To store all users
  Map<String, bool> isEditing = {}; // Track edit mode for each user

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  // Function to check if the logged-in user is the admin
  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email == 'mahfuzar148@gmail.com') {
      setState(() {
        isAdmin = true;
      });
    }
  }

  // Function to delete user data
  Future<void> _deleteUser(DocumentSnapshot user) async {
    await FirebaseFirestore.instance
        .collection('user_info')
        .doc(user.id)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User deleted successfully.')),
    );
  }

  // Toggle edit mode for the user
  void _toggleEdit(String userId) {
    setState(() {
      isEditing[userId] = !(isEditing[userId] ?? false);
    });
  }

  // Function to update user data
  Future<void> _updateUser(DocumentSnapshot user, String name, String email,
      String phone, String gender) async {
    await FirebaseFirestore.instance
        .collection('user_info')
        .doc(user.id)
        .update({
      'name': name,
      'email': email,
      'phone': phone.isNotEmpty ? phone : FieldValue.delete(),
      'gender': gender.isNotEmpty ? gender : FieldValue.delete(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User updated successfully.')),
    );

    _toggleEdit(user.id); // Exit edit mode after updating
  }

  // Function to launch the phone dialer
  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch phone dialer.'),
        ),
      );
    }
  }

  // Function to send email using the default email app
  Future<void> _launchEmailApp(String emailAddress) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch email app.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('user_info').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          users = snapshot.data?.docs ?? [];

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final data = user.data() as Map<String, dynamic>;
                    final userId = user.id;

                    // Store existing values in case of edit
                    TextEditingController nameController =
                        TextEditingController(text: data['name'] ?? '');
                    TextEditingController emailController =
                        TextEditingController(text: data['email'] ?? '');
                    TextEditingController phoneController =
                        TextEditingController(text: data['phone'] ?? '');
                    TextEditingController genderController =
                        TextEditingController(text: data['gender'] ?? '');

                    return Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isEditing[userId] ?? false) ...[
                              // Edit Mode: show input fields for editing
                              TextField(
                                controller: nameController,
                                decoration:
                                    const InputDecoration(labelText: 'Name'),
                              ),
                              TextField(
                                controller: emailController,
                                decoration:
                                    const InputDecoration(labelText: 'Email'),
                              ),
                              TextField(
                                controller: phoneController,
                                decoration:
                                    const InputDecoration(labelText: 'Phone'),
                              ),
                              TextField(
                                controller: genderController,
                                decoration:
                                    const InputDecoration(labelText: 'Gender'),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => _toggleEdit(userId),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _updateUser(
                                        user,
                                        nameController.text,
                                        emailController.text,
                                        phoneController.text,
                                        genderController.text,
                                      );
                                    },
                                    child: const Text('Update'),
                                  ),
                                ],
                              ),
                            ] else ...[
                              // Display Mode: show user data
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['name'] ?? 'No Name',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Gender: ${data['gender'] ?? 'Not Specified'}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Phone Icon Button
                                  if (data.containsKey('phone') &&
                                      data['phone'] != null)
                                    IconButton(
                                      icon: const Icon(Icons.phone,
                                          color: Colors.green),
                                      onPressed: () =>
                                          _launchPhoneDialer(data['phone']),
                                    ),
                                  // Email Icon Button
                                  if (data.containsKey('email') &&
                                      data['email'] != null)
                                    IconButton(
                                      icon: const Icon(Icons.email,
                                          color: Colors.blue),
                                      onPressed: () =>
                                          _launchEmailApp(data['email']),
                                    ),
                                  // Edit Icon Button
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () => _toggleEdit(userId),
                                  ),
                                  // Delete Icon Button
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteUser(user),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
