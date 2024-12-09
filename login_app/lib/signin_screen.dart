import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Starting point of the SignInScreen widget
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

// State class for SignInScreen
class _SignInScreenState extends State<SignInScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Building the UI for the sign-in screen
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 7, 168, 29),
        title:
            const Text('Sign In Page', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(children: [
            SizedBox(height: size.height * 0.15),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Welcome Back!',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: size.height * 0.05),

            // Email TextFormField
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Email',
                  hintText: 'abc@gmail.com',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
            ),

            // Password TextFormField
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.05),

            // Sign In Button
            SizedBox(
              width: size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color.fromARGB(255, 7, 168, 29),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    login(
                      email: emailController.text.trim(),
                      password: passwordController.text,
                    );
                  }
                },
                child: const Text('Sign In',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  //---- Login method start here ------
  Future<void> login({required String email, required String password}) async {
    try {
      // Attempting to sign in the user
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Check if the email is verified
      if (credential.user != null && credential.user!.emailVerified) {
        // Show success message in a pop-up window
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Signed in successfully!'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );

        // Navigate to the dashboard or next screen here if needed
        // Example: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
      } else {
        // Email is not verified, show an error message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Email Not Verified'),
              content:
                  const Text('Please verify your email before logging in.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      // Log the entire error object for debugging
      print(
          'FirebaseAuthException: ${e.toString()}'); // Log the entire error object
      print('Error code: ${e.code}'); // Log the specific error code
      print('Error Message: ${e.message}'); // Log the entire error message

      // Variable to hold custom error message
      String customErrorMessage;

      // Custom error messages based on Firebase error codes
      switch (e.code) {
        case 'user-not-found':
          customErrorMessage =
              'No account found for this email. Please sign up.';
          break;
        case 'wrong-password':
          customErrorMessage =
              'The password you entered is incorrect. Please try again.';
          break;
        case 'invalid-email':
          customErrorMessage =
              'The email address is invalid. Please enter a valid email.';
          break;
        case 'too-many-requests':
          customErrorMessage = 'Too many attempts. Please try again later.';
          break;
        default:
          // This will only trigger if an unexpected error occurs
          customErrorMessage = e.toString();
          break;
      }

      // Show the custom error message in a pop-up window
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(customErrorMessage), // Show the custom error message
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle any other exceptions that are not FirebaseAuthException
      String unexpectedErrorMessage =
          'An unexpected error occurred. Please try again later.';

      // Print unexpected error message to the console
      print(unexpectedErrorMessage);

      // Show the unexpected error message in a pop-up window
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content:
                Text(unexpectedErrorMessage), // Show unexpected error message
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  //----login method end here-----
}
