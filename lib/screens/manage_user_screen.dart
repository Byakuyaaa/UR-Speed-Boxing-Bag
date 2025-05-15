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
      // Step 1: Create user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Save to Firestore (optional but useful for roles)
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User added successfully')));

      // Clear inputs
      _emailController.clear();
      _roleController.clear();
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    }
  }

  Future<void> _editUser(String docId, String currentEmail, String currentRole, String currentPassword) async {
    _emailController.text = currentEmail;
    _roleController.text = currentRole;
    _passwordController.text = currentPassword;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _roleController, decoration: InputDecoration(labelText: 'Role (user/admin)')),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _emailController.clear();
              _roleController.clear();
              _passwordController.clear();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('users').doc(docId).update({
                'email': _emailController.text.trim(),
                'role': _roleController.text.trim(),
                'password': _passwordController.text.trim(), // ⚠️ In production, hash this
              });
              Navigator.pop(context);
              _emailController.clear();
              _roleController.clear();
              _passwordController.clear();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String docId) async {
    await _firestore.collection('users').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Users", style: TextStyle(fontSize: 18, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add-user row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Enter user email'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _roleController,
                    decoration: InputDecoration(labelText: 'Role (user/admin)'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Password'),
                  ),
                ),
                IconButton(icon: Icon(Icons.add), onPressed: _addUser),
              ],
            ),
            SizedBox(height: 20),
            // User list
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
                    return Center(child: Text('No users found.'));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final data = docs[i].data();
                      final email = data['email'] ?? '';
                      final role = data['role'] ?? '';
                      final password = data['password'] ?? '';
                      return ListTile(
                        title: Text(email),
                        subtitle: Text('Role: $role'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editUser(docs[i].id, email, role, password),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteUser(docs[i].id),
                            ),
                          ],
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
    );
  }
}
