// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_app/customDrawer.dart';
import 'package:login_app/custom_appbar.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;
  Map<String, dynamic>? userInfo;
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();
  TextEditingController dobController = TextEditingController();

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
          dobController.text = userInfo?['dob'] ??
              ''; // Initialize dobController with fetched DOB
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
                _buildDateField(
                    dobController, 'Date of Birth', Icons.calendar_view_day),
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

// start the _pickAndUploadImage method
  Future<void> _pickAndUploadImage() async {
    // Show a dialog to let the user choose between Camera and Gallery
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: const Text('Select the source of the image.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(ImageSource.camera);
              },
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(ImageSource.gallery);
              },
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without selecting
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (source == null) return; // User canceled the dialog

    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return; // No image selected

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${currentUser!.uid}.jpg');
      await ref.putFile(File(image.path));
      final photoURL = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('user_info')
          .doc(currentUser!.uid)
          .update({'photoURL': photoURL});

      setState(() {
        userInfo?['photoURL'] = photoURL;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile image updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      print('Error uploading image: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // end the _pickAndUploadImage method

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDateField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          // Show the date picker dialog
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );

          // If the user picked a date (not null), format and set the text
          if (pickedDate != null) {
            String formattedDate =
                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
            controller.text =
                formattedDate; // Set the formatted date in the controller
          }
        },
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: Colors.blue),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: const CustomAppBarForAll(title: 'User Profile'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userInfo == null
              ? const Center(child: Text('No user info available.'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildUserProfileCard(),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _updateUserInfo,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.blueAccent,
                          ),
                          child: const Text('Update User Info',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
      drawer: CustomDrawer(user: user),
    );
  }

  Widget _buildUserProfileCard() {
    return Card(
      elevation: 8, // Base elevation for the card
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20), // Rounded corners for modern look
      ),
      shadowColor: Colors.black.withOpacity(0.2), // Shadow color for card
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent.shade100,
              Colors.white
            ], // Gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 65, // Slightly larger avatar
                  backgroundColor: Colors.grey.shade200,
                  child: ClipOval(
                    child: userInfo!['photoURL'] != null
                        ? Image.network(
                            userInfo!['photoURL'],
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          )
                        : Image.asset(
                            'assets/images/default_avatar.png',
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: Colors.blue, // Background color for button
                    shape: const CircleBorder(),
                    elevation: 4,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _pickAndUploadImage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              userInfo!['displayName'] ?? 'No Name',
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Use the helper function for ListTiles to keep the code clean
            _buildInfoTile(Icons.email, "Email", userInfo!['email']),
            _buildInfoTile(Icons.phone, "Phone Number", userInfo!['phone']),
            _buildInfoTile(Icons.home, "Address", userInfo!['address']),
            _buildInfoTile(Icons.wc, "Gender", userInfo!['gender']),
            _buildInfoTile(Icons.flag, "Nationality", userInfo!['nationality']),
            _buildInfoTile(Icons.mosque, "Religion", userInfo!['religion']),
            _buildInfoTile(FontAwesomeIcons.birthdayCake, "Date of Birth",
                userInfo!['dob']),
          ],
        ),
      ),
    );
  }

// Helper function to create a ListTile for user information
  Widget _buildInfoTile(IconData icon, String title, String? subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle ?? 'No Info',
            style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
