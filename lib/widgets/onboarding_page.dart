import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final String text;
  final double size;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.text,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image that changes based on the imagePath
          Positioned.fill(
            child: Image.asset(
              imagePath, // Dynamically set the image path
              fit: BoxFit.cover, // Makes the image cover the entire screen
            ),
          ),

          // Title positioned as per your reference
          Positioned(
            top: MediaQuery.of(context).size.height * 0.09, // Adjusted for title positioning
            left: 20,
            right: 20,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: size,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 15, 94, 140),
              ),
              textAlign: TextAlign.left, // Left-aligned title
            ),
          ),

          // Centered Column with subtitle and text
          Positioned(
            top: MediaQuery.of(context).size.height *
                0.65, // Adjusted for the subtitle's position
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center, // Center aligned
                ),
                SizedBox(height: 20), // Space between subtitle and text
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center, // Center aligned
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
