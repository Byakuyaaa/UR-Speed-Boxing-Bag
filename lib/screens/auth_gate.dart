import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'start_page.dart';
import 'main_menu_screen.dart';

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MainMenuScreen();
        } else {
          return StartPage();
        }
      },
    );
  }
}