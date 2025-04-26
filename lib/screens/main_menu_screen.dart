import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'searching_screen.dart';
import 'power_monitoring_screen.dart';
import 'device_list_screen.dart';
import 'manage_user_screen.dart';

class MainMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("K.E.H.S.B.B. App"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,  // ← stretch buttons full width
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.cable),
                label: Text("Connect to the Equipment"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 60),  // ← full width, fixed height
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SearchingScreen()),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.bolt),
                label: Text("Power Monitoring"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 60),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PowerMonitoringScreen()),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.devices),
                label: Text("Device List"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 60),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DeviceListScreen()),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.people),
                label: Text("Manage Users"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 60),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ManageUserScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}