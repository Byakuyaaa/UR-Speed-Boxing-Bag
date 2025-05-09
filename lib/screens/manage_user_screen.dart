import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUserScreen extends StatefulWidget {
  @override
  _ManageUserScreenState createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _addUser() async {
    if (_emailController.text.trim().isEmpty) return;
    await _firestore.collection('users').add({
      'email': _emailController.text.trim(),
      'role': _roleController.text.trim().isEmpty ? 'user' : _roleController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    _emailController.clear();
    _roleController.clear();
  }

  Future<void> _editUser(String docId, String currentEmail, String currentRole) async {
    _emailController.text = currentEmail;
    _roleController.text = currentRole;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _roleController, decoration: InputDecoration(labelText: 'Role (user/admin)')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _emailController.clear();
              _roleController.clear();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('users').doc(docId).update({
                'email': _emailController.text.trim(),
                'role': _roleController.text.trim(),
              });
              Navigator.pop(context);
              _emailController.clear();
              _roleController.clear();
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
      appBar: AppBar(title: Text(
          style: TextStyle(fontSize: 18, color: Colors.white),
          "Manage Users"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // add-user row
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
                IconButton(icon: Icon(Icons.add), onPressed: _addUser),
              ],
            ),
            SizedBox(height: 20),
            // user list
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
                      final email = data['email'] as String? ?? '';
                      final role = data['role'] as String? ?? '';
                      return ListTile(
                        title: Text(email),
                        subtitle: Text('Role: $role'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editUser(docs[i].id, email, role),
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