// email_verification_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationPage extends StatelessWidget {
  final User? user;

  const EmailVerificationPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 5, 147, 28),
        title: const Text(
          'Email Verification',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'A verification link has been sent to your email. Please check your inbox.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _resendEmailVerification(context);
              },
              child: const Text('Resend Verification Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Sign out the user and navigate back to the sign-in page
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to resend the email verification link
  Future<void> _resendEmailVerification(BuildContext context) async {
    if (user != null) {
      await user!.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email has been resent!'),
        ),
      );
    }
  }
}
