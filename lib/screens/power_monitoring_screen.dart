import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'power_generated_screen.dart';

class PowerMonitoringScreen extends StatefulWidget {
  final InternetAddress esp32IP;

  const PowerMonitoringScreen({required this.esp32IP});

  @override
  _PowerMonitoringScreenState createState() => _PowerMonitoringScreenState();
}

class _PowerMonitoringScreenState extends State<PowerMonitoringScreen> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("sensorData/power");

  bool _connecting = true;
  String _status = "Connecting to ESP32…";

  @override
  void initState() {
    super.initState();
    _attemptConnection();
  }

  Future<void> _attemptConnection() async {
    try {
      final ipString = widget.esp32IP.address;
      final uri = Uri.parse('http://$ipString/');
      final resp = await http.get(uri).timeout(Duration(seconds: 5));

      if (resp.statusCode == 200 && resp.body.contains("ESP32 OK")) {
        setState(() {
          _connecting = false;
        });
      } else {
        setState(() {
          _connecting = false;
          _status = "Unexpected response from ESP32.";
        });
      }
    } on TimeoutException {
      setState(() {
        _connecting = false;
        _status = "Connection timed out.";
      });
    } on SocketException {
      setState(() {
        _connecting = false;
        _status = "Could not reach ESP32.";
      });
    } catch (e) {
      setState(() {
        _connecting = false;
        _status = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text(
          "Smart Boxing Energy",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Center(
        child: _connecting
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(_status),
            if (!_status.contains("Connecting"))
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Back to Device List"),
                ),
              ),
          ],
        )
            : _buildPowerContent(context),
      ),
    );
  }

  Widget _buildPowerContent(BuildContext context) {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildPowerCard(BuildContext context, String title, String value) {
    final width = MediaQuery.of(context).size.width * 0.8;
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
