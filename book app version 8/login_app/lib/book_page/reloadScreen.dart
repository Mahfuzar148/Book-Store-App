import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ReloadScreen extends StatefulWidget {
  const ReloadScreen({super.key});

  @override
  _ReloadScreenState createState() => _ReloadScreenState();
}

class _ReloadScreenState extends State<ReloadScreen> {
  bool isLoading = false;

  // Function to reload book data and user info
  Future<void> _reloadBooks() async {
    setState(() {
      isLoading = true; // Show loading indicator while reloading
    });

    try {
      // Simulate reloading or re-fetching books from Firestore
      await FirebaseFirestore.instance.collection('books').get();

      // Update user info if logged in
      await _updateUserInfo();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Books and user info refreshed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      // Show error message if reloading fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh data: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loading indicator
      });
    }
  }

  // Function to update user info in Firestore
  Future<void> _updateUserInfo() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Update Firestore user data
        CollectionReference users =
            FirebaseFirestore.instance.collection('user_info');
        await users.doc(user.uid).set(
            {
              'displayName': user.displayName,
              'email': user.email,
              'photoURL': user.photoURL,
              'lastSignInTime': Timestamp.now(),
            },
            SetOptions(
                merge:
                    true)); // Merge data to prevent overwriting existing fields
      }
    } else {
      // Handle case where Google sign-in is canceled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign-in canceled.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reload Books'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed:
                  isLoading ? null : _reloadBooks, // Disable button if loading
              child: isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Reload Book Data'),
            ),
          ],
        ),
      ),
    );
  }
}
