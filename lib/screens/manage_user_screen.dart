import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageUserScreen extends StatefulWidget {
  @override
  _ManageUserScreenState createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _roleController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _addUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final role = _roleController.text.trim().isEmpty ? 'user' : _roleController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User added successfully')),
      );

      _emailController.clear();
      _roleController.clear();
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  Future<void> _deleteUser(String docId) async {
    await _firestore.collection('users').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Manage Users", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.deepOrange.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Input Fields Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildInputField(_emailController, "User Email"),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildInputField(_roleController, "Role (user/admin)"),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildInputField(_passwordController, "Password", obscure: true),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.orangeAccent),
                        onPressed: _addUser,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // User List
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _firestore.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return Center(child: Text('No users found.', style: TextStyle(color: Colors.white)));
                      }
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final data = docs[i].data();
                          final email = data['email'] ?? '';
                          final role = data['role'] ?? '';
                          return Card(
                            color: Colors.black54,
                            child: ListTile(
                              title: Text(email, style: TextStyle(color: Colors.white)),
                              subtitle: Text('Role: $role', style: TextStyle(color: Colors.white70)),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _deleteUser(docs[i].id),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.orangeAccent),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.orangeAccent),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
    );
  }
}
