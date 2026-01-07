// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:novatalk/Screens/SignInScreen.dart';
import 'package:novatalk/Screens/bottom_bar.dart';
import 'package:novatalk/Widgets/common/custom_textfield.dart';
import 'package:novatalk/Widgets/common/social_button.dart';



class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final Box credentialsBox;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    credentialsBox = Hive.isBoxOpen('credentials')
        ? Hive.box('credentials')
        : await Hive.openBox('credentials');
  }

  Future<void> _signUp() async {
  final String name = _nameController.text.trim();
  final String email = _emailController.text.trim();
  final String password = _passwordController.text;

  if (name.isEmpty || email.isEmpty || password.isEmpty) {
    _showSnackbar("Please fill all the fields.");
    return;
  }

  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
    _showSnackbar("Please enter a valid email address.");
    return;
  }

  if (password.length < 8) {
    _showSnackbar("Password must be at least 8 characters long.");
    return;
  }

  if (password != _confirmPasswordController.text) {
    _showSnackbar("Passwords do not match.");
    return;
  }

    try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade300,
              child: CircularProgressIndicator(color: Colors.indigo),
            ),
          ],
        ),
      ),
    );

    // Step 1: Create the user
    UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Step 4: Store user data in Firestore
    await _firestore.collection('users').doc(userCredential.user?.uid).set({
      'name': name,
      'email': email,
    });

    Navigator.pop(context); // Remove the loading indicator
    _showSnackbar("Sign-Up Successful!");
    _navigateToPage(const BottomBar());
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context); // Ensure loading indicator is removed
    String errorMessage;

    switch (e.code) {
      case 'email-already-in-use':
        errorMessage =
            "The email address is already in use by another account.";
        break;
      case 'invalid-email':
        errorMessage = "The email address is not valid.";
        break;
      case 'weak-password':
        errorMessage =
            "The password is too weak. Please choose a stronger password.";
        break;
      default:
        errorMessage =
            "An unexpected error occurred. Please check your connection and try again.";
    }

    _showSnackbar(errorMessage);

    // Rollback: Delete partially created user if any
    if (_auth.currentUser != null) {
      await _auth.currentUser!.delete();
    }
  } on FirebaseException catch (e) {
    Navigator.pop(context); // Ensure loading indicator is removed
    _showSnackbar(
        "A server error occurred: ${e.message ?? 'Unknown error'}. Please try again.");

    // Rollback: Delete partially created user if any
    if (_auth.currentUser != null) {
      await _auth.currentUser!.delete();
    }
  } catch (e) {
    Navigator.pop(context); // Ensure loading indicator is removed
    _showSnackbar("An unexpected error occurred. Please try again.");
    debugPrint("Error: $e");

    // Rollback: Delete partially created user if any
    if (_auth.currentUser != null) {
      await _auth.currentUser!.delete();
    }
  }
}





  Future<void> _signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': googleUser.displayName,
        'email': googleUser.email,
        'profileImage': googleUser.photoUrl,
      }, SetOptions(merge: true));

      _showSnackbar("Signed up with Google successfully!");
      _navigateToPage(const BottomBar());
    } catch (e) {
      _showSnackbar("Failed to sign up with Google. Please try again.");
      debugPrint("Google Sign-up Error: $e");
    }
  }

  void _showSnackbar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(
        message,
        style: const TextStyle(fontSize: 16),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.indigo.shade600,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}


  void _navigateToPage(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade400,
              Colors.blue.shade200,
              Colors.blue.shade50,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    InkWell(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                                child: Image.asset(
                                  'lib/logo.png',
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Welcome to NovaTalk",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _nameController,
                  hintText: "Full Name",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _emailController,
                  hintText: "Email Address",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _passwordController,
                  hintText: "Password",
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: "Confirm Password",
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    backgroundColor: Colors.indigo.shade600,
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "OR",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SocialButton(
                      icon: "assets/google_icon.png",
                      text: "Google",
                      onPressed: _signUpWithGoogle,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(color: Color.fromARGB(255, 12, 12, 12)),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to LoginPage
                        _navigateToPage(const SignInPage());
                      },
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          color: Color.fromARGB(255, 94, 214, 250),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
