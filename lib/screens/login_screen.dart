import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'register_screen.dart';
import 'user_main_menu_screen.dart'; // For normal users
import 'main_menu_screen.dart'; // You’ll create this screen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> login() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final role = doc.data()?['role'] ?? 'user'; // fallback to user

          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainMenuScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => UserMainMenuScreen()),
            );
          }
        } else {
          // No document found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User data not found in Firestore.")),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.message}")),
      );
    } catch (e) {
      // Catch any other error (like Firebase document access issues)
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => login(),
                ),
                SizedBox(height: 20),
                ElevatedButton(onPressed: login, child: Text("Login")),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  ),
                  child: Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}