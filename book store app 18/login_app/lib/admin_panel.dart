import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// --- Admin Panel Class Begins ---
class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

// --- Admin Panel State Class Begins ---
class _AdminPanelState extends State<AdminPanel> {
  bool isAdmin = false; // To check if the logged-in user is admin
  List<DocumentSnapshot> users = []; // To store all users
  Map<String, bool> isEditing = {}; // Track edit mode for each user
  User? currentUser;

  // --- Init State Begins ---
  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }
  // --- Init State Ends ---

  // --- Check Admin Status Function Begins ---
  // --- Check Admin Status Function Begins ---
  // --- Check Admin Status Function Begins ---
  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    // Check if user is logged in via Firebase
    if (user != null) {
      String email = user.email ?? ''; // First, check the default email

      // If user is logged in via Google Sign-In, fetch email from Google
      if (email.isEmpty) {
        // Check provider data for Google provider
        for (var provider in user.providerData) {
          if (provider.providerId == 'google.com') {
            email = provider.email ?? ''; // Fetch the email from Google
            break;
          }
        }
      }

      // Check if the email matches the admin email
      if (email == 'mahfuzar148@gmail.com') {
        setState(() {
          isAdmin = true;
          currentUser = user;
        });
      }
    }
  }

// --- Check Admin Status Function Ends ---

  // --- Delete User Function Begins ---
  Future<void> _deleteUser(DocumentSnapshot user) async {
    await FirebaseFirestore.instance
        .collection('user_info')
        .doc(user.id)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User deleted successfully.')),
    );
  }
  // --- Delete User Function Ends ---

  // --- Toggle Edit Mode Function Begins ---
  void _toggleEdit(String userId) {
    setState(() {
      isEditing[userId] = !(isEditing[userId] ?? false);
    });
  }
  // --- Toggle Edit Mode Function Ends ---

  // --- Update User Function Begins ---
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
  // --- Update User Function Ends ---

  // --- Launch Phone Dialer Function Begins ---
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
  // --- Launch Phone Dialer Function Ends ---

  // --- Launch Email App Function Begins ---
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
  // --- Launch Email App Function Ends ---

  // --- Build User Avatar Function Begins ---
  Widget _buildUserAvatar(String? email, String? gender) {
    return _getDefaultAvatar(
        gender); // Directly use default avatar based on gender
  }

  // --- Get Default Avatar Function Begins ---
  Widget _getDefaultAvatar(String? gender) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.grey[300],
      child: const Icon(
        Icons.person, // Use specific icons
        size: 30,
        color: Colors.blue, // Set icon color to blue
      ),
    );
  }
  // --- Get Default Avatar Function Ends ---

  // --- Build Widget Begins ---
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

                    // --- User List Tile UI Begins ---
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
                              // --- Edit Mode UI Begins ---
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
                              // --- Edit Mode UI Ends ---
                            ] else ...[
                              // --- Display Mode UI Begins ---
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _buildUserAvatar(
                                      data['email'], data['gender']),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(data['name'] ?? 'No Name',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 5),
                                      Text(data['email'] ?? 'No Email'),
                                      const SizedBox(height: 5),
                                      Text(data['phone'] ?? 'No Phone'),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.call,
                                        color: Colors.blue,
                                        size: 20,
                                        semanticLabel: 'Call'),
                                    onPressed: data['phone'] != null
                                        ? () =>
                                            _launchPhoneDialer(data['phone'])
                                        : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.email,
                                        color: Colors.blue,
                                        size: 20,
                                        semanticLabel: 'Email'),
                                    onPressed: data['email'] != null
                                        ? () => _launchEmailApp(data['email'])
                                        : null,
                                  ),
                                  if (isAdmin)
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue,
                                          size: 20,
                                          semanticLabel: 'Edit'),
                                      onPressed: () => _toggleEdit(userId),
                                    ),
                                  if (isAdmin)
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                          semanticLabel: 'Delete'),
                                      onPressed: () => _deleteUser(user),
                                    ),
                                ],
                              ),
                              // --- Display Mode UI Ends ---
                            ],
                          ],
                        ),
                      ),
                    );
                    // --- User List Tile UI Ends ---
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  // --- Build Widget Ends ---
}
// --- Admin Panel Class Ends ---
