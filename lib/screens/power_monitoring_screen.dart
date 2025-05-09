import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'power_generated_screen.dart'; // Your existing screen

class PowerMonitoringScreen extends StatelessWidget {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("sensorData/power");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text(
            style: TextStyle(fontSize: 18, color: Colors.white),
            "Smart Boxing Energy"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: StreamBuilder<DatabaseEvent>(
            stream: ref.onValue,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.snapshot.exists) {
                final value = snapshot.data!.snapshot.value;
                final power = double.tryParse(value.toString())?.toStringAsFixed(2) ?? "0.00";

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPowerCard(context, "Real-time Power Output", "$power V"),
                    SizedBox(height: 40),
                    _buildNavigateButton(context),
                  ],
                );
              } else {
                return Center(child: CircularProgressIndicator(color: Colors.blueAccent));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPowerCard(BuildContext context, String title, String value) {
    final width = MediaQuery.of(context).size.width * 0.8; // 80% of screen width
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigateButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(Icons.analytics, size: 28),
      label: Text(
        "View Generated Power",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PowerGeneratedScreen()),
        );
      },
    );
  }
}