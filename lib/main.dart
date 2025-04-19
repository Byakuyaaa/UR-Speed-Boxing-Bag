// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'firebase_options.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'dart:async';
// import 'device_list_screen.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   FirebaseDatabase.instance.databaseURL = "https://smartboxingenergy-b5cdf-default-rtdb.asia-southeast1.firebasedatabase.app/";
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: AuthGate(),
//     );
//   }
// }
//
// class AuthGate extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return MainMenuScreen();
//         } else {
//           return LoginScreen();
//         }
//       },
//     );
//   }
// }
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   Future<void> login() async {
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );
//     } on FirebaseAuthException catch (e) {
//       String message = '';
//       if (e.code == 'user-not-found') {
//         message = 'No user found for that email.';
//       } else if (e.code == 'wrong-password') {
//         message = 'Wrong password provided.';
//       } else {
//         message = 'Login failed: ${e.message}';
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text("Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//               SizedBox(height: 20),
//               TextField(controller: emailController, decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder())),
//               SizedBox(height: 10),
//               TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()), obscureText: true),
//               SizedBox(height: 20),
//               ElevatedButton(onPressed: login, child: Text("Login")),
//               TextButton(
//                 onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen())),
//                 child: Text("Don't have an account? Sign up"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class RegisterScreen extends StatefulWidget {
//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   Future<void> register() async {
//     try {
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );
//     } on FirebaseAuthException catch (e) {
//       String message = '';
//       if (e.code == 'email-already-in-use') {
//         message = 'The email is already in use.';
//       } else if (e.code == 'weak-password') {
//         message = 'The password is too weak.';
//       } else {
//         message = 'Sign up failed: ${e.message}';
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text("Sign Up", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//               SizedBox(height: 20),
//               TextField(controller: emailController, decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder())),
//               SizedBox(height: 10),
//               TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()), obscureText: true),
//               SizedBox(height: 20),
//               ElevatedButton(onPressed: register, child: Text("Sign Up")),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class MainMenuScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("K.E.H.S.B.B. App")),
//       body: Center( // Centers everything inside
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min, // Shrinks to fit content
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               ElevatedButton.icon(
//                 icon: Icon(Icons.cable),
//                 label: Text("Connect to the Equipment"),
//                 onPressed: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => SearchingScreen()),
//                 ),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton.icon(
//                 icon: Icon(Icons.bolt),
//                 label: Text("Power Monitoring"),
//                 onPressed: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => PowerMonitoringScreen()),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// class PowerMonitoringScreen extends StatelessWidget {
//   final DatabaseReference ref = FirebaseDatabase.instance.ref("sensorData/power");
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Power Monitoring")),
//       body: StreamBuilder<DatabaseEvent>(
//         stream: ref.onValue,
//         builder: (context, snapshot) {
//           if (snapshot.hasData && snapshot.data!.snapshot.exists) {
//             final value = snapshot.data!.snapshot.value;
//             final power = value.toString();
//
//             return Center(
//               child: _buildPowerCard("Real-time Power Output", "$power V", Colors.blue),
//             );
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildPowerCard(String title, String value, Color color) {
//     return Card(
//       elevation: 6,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class SearchingScreen extends StatefulWidget {
//   @override
//   _SearchingScreenState createState() => _SearchingScreenState();
// }
//
// class _SearchingScreenState extends State<SearchingScreen> {
//   int dotCount = 0;
//   late Timer dotTimer;
//   late Timer navTimer;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Animate dots (like loading...)
//     dotTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
//       setState(() {
//         dotCount = (dotCount + 1) % 6;
//       });
//     });
//
//     // Simulate a device search delay
//     navTimer = Timer(Duration(seconds: 4), () {
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DeviceListScreen()));
//     });
//   }
//
//   @override
//   void dispose() {
//     dotTimer.cancel();
//     navTimer.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     String dots = '.' * dotCount;
//
//     return Scaffold(
//       appBar: AppBar(title: Text("Searching for Devices")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.wifi, size: 100, color: Colors.blue),
//             SizedBox(height: 20),
//             Text("Scanning$dots", style: TextStyle(fontSize: 18)),
//             SizedBox(height: 40),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               child: Icon(Icons.arrow_back),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // (FirebaseDatabase.instance.databaseURL is now set in the screens that use RTDB if needed)
  FirebaseDatabase.instance.databaseURL = "https://smartboxingenergy-b5cdf-default-rtdb.asia-southeast1.firebasedatabase.app/";
  runApp(MyApp());
}

class MyApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: 'K.E.H.S.B.B. App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthGate(),
    );
  }
}
