import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'components/my_button.dart';
import 'components/my_textfield.dart';


class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Register function
  void register() async {
    // Show loading circle
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Check if passwords match
    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      displayMessageToUser("Passwords don't match!", context);
      return;
    } else {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        await createUserDocument(userCredential);

        // Close the loading dialog
        if (context.mounted) Navigator.pop(context);

        // Navigate back or show success message
        if (context.mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
          displayMessageToUser('Registration successful!', context);
        }
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        String message;
        switch (e.code) {
          case 'weak-password':
            message = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            message = 'The account already exists for that email.';
            break;
          case 'invalid-email':
            message = 'The email provided is not valid.';
            break;
          default:
            message = 'An error occurred. Please try again.';
        }
        displayMessageToUser(message, context);
      } catch (e) {
        Navigator.pop(context);
        displayMessageToUser('An error occurred. Please try again.', context);
      }
    }
  }

  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': usernameController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Icon(
                  Icons.person,
                  size: 90,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 25),
                // App name
                const Text(
                  "E D U - A I",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),
                // Username TextField
                MyTextfield(
                  hinttext: "Username",
                  obscuretext: false,
                  controller: usernameController,
                ),
                const SizedBox(height: 25),
                // Email TextField
                MyTextfield(
                  hinttext: "Email",
                  obscuretext: false,
                  controller: emailController,
                ),
                const SizedBox(height: 25),
                // Password TextField
                MyTextfield(
                  hinttext: "Password",
                  obscuretext: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 25),
                // Confirm Password TextField
                MyTextfield(
                  hinttext: "Confirm Password",
                  obscuretext: true,
                  controller: confirmPasswordController,
                ),
                const SizedBox(height: 25),
                // Register Button
                MyButton(
                  text: "Register",
                  onTap: register,
                ),
                const SizedBox(height: 25),
                // Already have an account? Login here
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Login Here",
                        style: TextStyle(
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

// Helper function to display messages
void displayMessageToUser(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ),
  );
}
