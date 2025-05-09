import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class userPowerMonitoringScreen extends StatelessWidget {
  final DatabaseReference _powerRef =
  FirebaseDatabase.instance.ref("sensorData/power");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text(style: TextStyle(fontSize: 18, color: Colors.white), "Smart Boxing Energy"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: StreamBuilder<DatabaseEvent>(
            stream: _powerRef.onValue,
            builder: (context, snapshot) {
              String display;
              if (snapshot.hasError) {
                display = "Error";
              } else if (snapshot.hasData && snapshot.data!.snapshot.exists) {
                final raw = snapshot.data!.snapshot.value;
                final power = double.tryParse(raw.toString())?.toStringAsFixed(2) ?? "0.00";
                display = "$power V";
              } else {
                display = "--";
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPowerCard("Real-time Power Output", display, context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPowerCard(String title, String value, BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.8; // 80% width
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
}