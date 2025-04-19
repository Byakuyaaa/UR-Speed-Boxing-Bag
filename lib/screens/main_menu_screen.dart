import 'package:flutter/material.dart';
import 'searching_screen.dart';
import 'power_monitoring_screen.dart';
import 'device_list_screen.dart';
import 'manage_user_screen.dart';

class MainMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("K.E.H.S.B.B. App")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.cable),
                label: Text("Connect to the Equipment"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SearchingScreen()),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.bolt),
                label: Text("Power Monitoring"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PowerMonitoringScreen()),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.devices),
                label: Text("Device List"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DeviceListScreen()),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.people),
                label: Text("Manage Users"),
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
