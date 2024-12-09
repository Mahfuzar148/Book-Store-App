import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:login_app/book_page/user_uploaded_book.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  _UserDashboardPageState createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;
  Map<String, dynamic>? userInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    currentUser = _auth.currentUser;

    if (currentUser != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('user_info')
            .doc(currentUser!.uid)
            .get();

        setState(() {
          userInfo = snapshot.data() as Map<String, dynamic>?;
          isLoading = false;
        });
      } catch (error) {
        print('Error fetching user info: $error');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateUserInfo() async {
    TextEditingController nameController =
        TextEditingController(text: userInfo?['displayName']);
    TextEditingController emailController =
        TextEditingController(text: userInfo?['email']);
    TextEditingController phoneController =
        TextEditingController(text: userInfo?['phone']);
    TextEditingController addressController =
        TextEditingController(text: userInfo?['address']);
    TextEditingController genderController =
        TextEditingController(text: userInfo?['gender']);
    TextEditingController nationalityController =
        TextEditingController(text: userInfo?['nationality']);
    TextEditingController religionController =
        TextEditingController(text: userInfo?['religion']);
    TextEditingController dobController =
        TextEditingController(text: userInfo?['dob']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update User Info'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(nameController, 'Name', Icons.person),
                _buildTextField(emailController, 'Email', Icons.email),
                _buildTextField(phoneController, 'Phone Number', Icons.phone),
                _buildTextField(addressController, 'Address', Icons.home),
                _buildTextField(genderController, 'Gender', Icons.wc),
                _buildTextField(
                    nationalityController, 'Nationality', Icons.flag),
                _buildTextField(
                    religionController, 'Religion', FontAwesomeIcons.mosque),
                _buildTextField(
                    dobController, 'Date of Birth', Icons.calendar_today),
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
                await FirebaseFirestore.instance
                    .collection('user_info')
                    .doc(currentUser!.uid)
                    .set({
                  'displayName': nameController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'address': addressController.text,
                  'gender': genderController.text,
                  'nationality': nationalityController.text,
                  'religion': religionController.text,
                  'dob': dobController.text,
                  'photoURL':
                      userInfo?['photoURL'], // Keep the existing photo URL
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User info updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Reload the user data after update
                await _fetchUserData();
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              Icon(icon, color: Colors.blue), // Change icon color to blue
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pop(context); // Close the dashboard after logout
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userInfo == null
              ? const Center(child: Text('No user info available.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildUserProfileCard(),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateUserInfo,
                        child: const Text('Update User Info'),
                      ),
                    ],
                  ),
                ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Drawer Header',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reload App Data'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.update,
                  color: Colors.blue), // Blue icon color for Update
              title: const Text('Update User Info'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _updateUserInfo(); // Call the update method directly
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Your Uploaded Books'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const UserUploadedBooksPage()), // Navigate to the uploaded books page
                );
              },
            ),

            // Add more drawer items as needed
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: userInfo!['photoURL'] != null
                  ? NetworkImage(userInfo!['photoURL'])
                  : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              userInfo!['displayName'] ?? 'No Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              userInfo!['email'] ?? 'No Email',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(Icons.phone, userInfo!['phone'] ?? 'No Phone Number'),
            _buildInfoRow(Icons.home, userInfo!['address'] ?? 'No Address'),
            _buildInfoRow(Icons.wc, userInfo!['gender'] ?? 'No Gender'),
            _buildInfoRow(
                Icons.flag, userInfo!['nationality'] ?? 'No Nationality'),
            _buildInfoRow(FontAwesomeIcons.mosque,
                userInfo!['religion'] ?? 'No Religion'),
            _buildInfoRow(
                Icons.calendar_today, userInfo!['dob'] ?? 'No Date of Birth'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4, // 3D effect for each data field
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue), // Blue icon color
              const SizedBox(width: 10),
              Expanded(
                child: Text(info, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
