import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Set a fixed height for the AppBar
      height: 120.0, // Height of the AppBar
      child: ClipPath(
        clipper: CustomShapeClipper(), // Use a custom shape clipper
        child: Container(
          color: Colors.deepOrange, // Set background color to Deep Orange
          child: AppBar(
            // Remove the background color from the AppBar to use the container color
            backgroundColor: Colors.transparent,
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 26, // Title font size
                fontWeight: FontWeight.bold,
                color: Colors.white, // Title color
              ),
            ),
            // centerTitle: true, // Center the title
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    backgroundColor: Colors.deepOrange, // Button color
                    shadowColor:
                        Colors.blue.withOpacity(0.5), // Button shadow color
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Button text color
                    ),
                  ),
                ),
              ),
            ],
            elevation: 0, // Remove the default AppBar shadow
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(120.0); // Height of the AppBar
}

// Custom Shape Clipper
class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 25); // Create a curved effect
    path.quadraticBezierTo(
        size.width / 2, size.height + 15, size.width, size.height - 25);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true; // Reclip whenever the shape changes
  }
}
