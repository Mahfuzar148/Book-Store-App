import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_app/login_page.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _auth = FirebaseAuth.instance;
  final bool _isVerified = false; // To track if the email is verified

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    User? user = _auth.currentUser;

    // Continuously check if the email is verified
    while (user != null && !user.emailVerified) {
      await Future.delayed(const Duration(seconds: 3));
      await user.reload();
      user = _auth.currentUser; // Get the latest user state
    }

    // If the email is verified, show the success dialog
    if (user != null && user.emailVerified) {
      _showVerificationDialog(); // Show dialog instead of navigating directly
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email Verified'),
          content: const Text('Your email has been successfully verified!'),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate to the login page
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Next'),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text('Back'),
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
        title: const Text('Email Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'A verification email has been sent to your email address. Please check your inbox and verify your email.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Resend verification email
                  _resendVerificationEmail();
                },
                child: const Text('Resend Verification Email'),
              ),
              const SizedBox(height: 20),
              // Show the Next button only if the email is verified
              if (_isVerified)
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the NextStepPage
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const NextStepPage()),
                    );
                  },
                  child: const Text('Next'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resendVerificationEmail() async {
    User? user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent again!')),
      );
    }
  }
}

// New page to show after email verification
class NextStepPage extends StatelessWidget {
  const NextStepPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Step'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You have successfully verified your email!',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the login page
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Next'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Go back to the Email Verification Page
                Navigator.of(context).pop();
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
