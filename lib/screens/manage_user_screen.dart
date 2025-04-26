import 'package:flutter/material.dart';

class ManageUserScreen extends StatefulWidget {
  @override
  _ManageUserScreenState createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  final List<String> _users = ['User 1', 'User 2', 'User 3'];
  final TextEditingController _userController = TextEditingController();

  void _addUser() {
    if (_userController.text.trim().isEmpty) return;
    setState(() {
      _users.add(_userController.text.trim());
      _userController.clear();
    });
  }

  void _removeUser(int index) {
    setState(() {
      _users.removeAt(index);
    });
  }

  @override
  void dispose() {
    _userController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Users')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: InputDecoration(
                labelText: 'Enter new user name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addUser,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _users.isEmpty
                  ? Center(child: Text("No users added yet."))
                  : ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_users[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _removeUser(index),
                    ),
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
