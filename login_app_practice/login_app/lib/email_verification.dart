import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationPage extends StatefulWidget {
  final User? user;

  const EmailVerificationPage({super.key, required this.user});

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // Check if email is already verified on initialization
    isEmailVerified = widget.user!.emailVerified;

    // If not verified, start periodic checking
    if (!isEmailVerified) {
      timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        _checkEmailVerification();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Function to check email verification status
  Future<void> _checkEmailVerification() async {
    await widget.user!.reload(); // Reload the user data
    setState(() {
      isEmailVerified =
          widget.user!.emailVerified; // Update the verification status
    });

    if (isEmailVerified) {
      timer?.cancel(); // Stop checking if email is verified
    }
  }

  // Function to handle email verification resending
  Future<void> _resendEmailVerification(BuildContext context) async {
    if (widget.user != null) {
      await widget.user!.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email has been resent!'),
        ),
      );
    }
  }

  // Handle "Next" button press
  void _onNextButtonPressed() {
    if (isEmailVerified) {
      // Navigate to the next page (login page)
      Navigator.pushReplacementNamed(
          context, '/login'); // Replace with your login route
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your email before proceeding.'),
        ),
      );
    }
  }

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
            // Show Next button only if email is verified
            if (isEmailVerified)
              ElevatedButton(
                onPressed: _onNextButtonPressed,
                child: const Text('Next'),
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
}
