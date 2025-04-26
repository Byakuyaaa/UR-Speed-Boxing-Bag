import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'power_generated_screen.dart'; // Import your screen here

class PowerMonitoringScreen extends StatelessWidget {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("sensorData/power");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Power Monitoring")),
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.exists) {
            final value = snapshot.data!.snapshot.value;
            final power = value.toString();
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: _buildPowerCard("Real-time Power Output", "$power V", Colors.blue)),
                SizedBox(height: 40),
                ElevatedButton.icon(
                  icon: Icon(Icons.analytics),
                  label: Text("View Generated Power"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PowerGeneratedScreen()),
                    );
                  },
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildPowerCard(String title, String value, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}