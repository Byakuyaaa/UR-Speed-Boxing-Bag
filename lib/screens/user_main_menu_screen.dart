import 'package:flutter/material.dart';
import 'searching_screen.dart';
import 'user_power_monitoring_screen.dart';
import 'device_list_screen.dart';

class UserMainMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("K.E.H.S.B.B. - User")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,  // ← stretch buttons
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.cable),
                label: Text("Connect to the Equipment"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(0, 60),            // ← fixed height
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
                  minimumSize: Size(0, 60),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => userPowerMonitoringScreen()),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.devices),
                label: Text("Device List"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(0, 60),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DeviceListScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}