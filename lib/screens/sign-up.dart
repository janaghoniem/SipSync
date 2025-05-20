import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign-in.dart';
import '../user-data.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 94, 140), // Main BG color
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Smooth scrolling
        child: SizedBox(
          height:
              MediaQuery.of(context).size.height +
              100, // Ensures full scrollability
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(),
                  ), // Empty space for top design
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 242, 242, 242), // Gray BG
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 60),
                            Text(
                              "Sign Up",
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // White Container for Input Fields
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              child: Column(
                                children: [
                                  // Name Field
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: Colors.grey,
                                      ),
                                      hintText: "Full Name",
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter your name";
                                      }
                                      return null;
                                    },
                                  ),
                                  Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1,
                                  ),

                                  // Email Field
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: Colors.grey,
                                      ),
                                      hintText: "Email",
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter your email";
                                      } else if (!RegExp(
                                        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                                      ).hasMatch(value)) {
                                        return "Enter a valid email";
                                      }
                                      return null;
                                    },
                                  ),
                                  Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1,
                                  ),

                                  // Password Field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: Colors.grey,
                                      ),
                                      hintText: "Password",
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter your password";
                                      } else if (value.length < 6) {
                                        return "Password must be at least 6 characters long";
                                      }
                                      return null;
                                    },
                                  ),
                                  Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1,
                                  ),

                                  // Confirm Password Field
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: Colors.grey,
                                      ),
                                      hintText: "Confirm Password",
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please confirm your password";
                                      } else if (value !=
                                          _passwordController.text) {
                                        return "Passwords do not match";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Sign Up Button
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Check if the email already exists
                                  bool emailExists = registeredUsers.any(
                                    (user) =>
                                        user.email == _emailController.text,
                                  );

                                  if (emailExists) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Email is already registered! Try signing in.",
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Register new user
                                    registeredUsers.add(
                                      User(
                                        name: _nameController.text,
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      ),
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Account created successfully! Please sign in.",
                                        ),
                                      ),
                                    );

                                    // Navigate to sign-in screen
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const SignInScreen(),
                                      ),
                                    );
                                  }
                                }
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  15,
                                  94,
                                  140,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                "Sign Up",
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Already Have an Account? Sign In
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignInScreen(),
                                  ),
                                );
                              },
                              child:  Text(
                                "Already have an account? Sign In",
                                style: GoogleFonts.poppins(color: Colors.blue),
                              ),
                            ),

                            const SizedBox(height: 5),

                            // Social Icons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialIcon(
                                  FontAwesomeIcons.facebook,
                                  Colors.blue,
                                ),
                                const SizedBox(width: 20),
                                _buildGoogleIcon(),
                                const SizedBox(width: 20),
                                _buildSocialIcon(
                                  FontAwesomeIcons.apple,
                                  Colors.black,
                                ),
                              ],
                            ),
                            const SizedBox(height: 30), // Added spacing
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Water Drop Logo
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    height: 230,
                    child: Image.asset(
                      'assets/water-drop.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Social Icons
  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Image.asset('assets/google-icon.png', height: 30, width: 30),
    );
  }
}
