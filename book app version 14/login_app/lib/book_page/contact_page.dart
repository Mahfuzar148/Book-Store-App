import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  final String phoneNumber;
  final String email;

  const ContactPage({
    super.key,
    required this.phoneNumber,
    required this.email,
  });

  // Function to show error messages
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Function to add Bangladesh country code if missing
  String _getFormattedPhoneNumber() {
    String formattedPhone = phoneNumber;

    // Check if the phone number doesn't start with '+880', and add it if missing
    if (!formattedPhone.startsWith('+880')) {
      formattedPhone = '+880$formattedPhone';
    }

    return formattedPhone;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 10,
      backgroundColor: Colors.white,
      title: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: const Text(
          'Contact to Buy',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      content: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Email Contact
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Email'),
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: email,
                  query:
                      'subject=Book Inquiry&body=Hello, I am interested in your book.',
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  _showError(context, 'Could not launch Email app');
                }
              },
            ),
            const Divider(height: 1, thickness: 1),
            // Phone Call
            ListTile(
              leading: const Icon(Icons.call, color: Colors.green),
              title: const Text('Call'),
              onTap: () async {
                final Uri callUri = Uri(
                  scheme: 'tel',
                  path: _getFormattedPhoneNumber(),
                );
                if (await canLaunchUrl(callUri)) {
                  await launchUrl(callUri);
                } else {
                  _showError(context, 'Could not initiate a phone call');
                }
              },
            ),
            const Divider(height: 1, thickness: 1),
            // WhatsApp Contact
            ListTile(
              leading:
                  const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
              title: const Text('WhatsApp'),
              onTap: () async {
                final Uri whatsappUri = Uri.parse(
                    'https://wa.me/${_getFormattedPhoneNumber().replaceFirst('+', '')}?text=Hello, I am interested in your book');
                if (await canLaunchUrl(whatsappUri)) {
                  await launchUrl(whatsappUri);
                } else {
                  _showError(context, 'Could not launch WhatsApp');
                }
              },
            ),
            const Divider(height: 1, thickness: 1),
            // Telegram Contact
            ListTile(
              leading:
                  const Icon(FontAwesomeIcons.telegram, color: Colors.blue),
              title: const Text('Telegram'),
              onTap: () async {
                final Uri telegramUri = Uri.parse(
                    'https://t.me/${_getFormattedPhoneNumber().replaceFirst('+', '')}');
                if (await canLaunchUrl(telegramUri)) {
                  await launchUrl(telegramUri);
                } else {
                  _showError(context, 'Could not launch Telegram');
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the Contact dialog
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Colors.redAccent,
            ),
            child: const Text(
              'Cancel',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
