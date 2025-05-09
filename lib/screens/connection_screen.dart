import 'dart:async';
import 'dart:io';
import 'package:multicast_dns/multicast_dns.dart';
import 'safe_mdns_client.dart';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import 'power_generated_screen.dart';

class ConnectionScreen extends StatefulWidget {
  final InternetAddress esp32IP;
  const ConnectionScreen({required this.esp32IP});

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  bool _connecting = true;
  String _status = "Connecting to ESP32…";

  @override
  void initState() {
    super.initState();
    _attemptConnection();
  }

  Future<void> _attemptConnection() async {
    try {
      // Connect to the ESP32's Wi-Fi SSID if it's an AP,
      // otherwise assume you're already on the same LAN.
      // Here we skip Wi-Fi-IoT and go straight to HTTP test:
      final ipString = widget.esp32IP.address;
      final uri = Uri.parse('http://$ipString/');
      final resp = await http.get(uri).timeout(Duration(seconds: 5));

      if (resp.statusCode == 200 && resp.body.contains("ESP32 OK")) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PowerGeneratedScreen()),
        );
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
      appBar: AppBar(title: Text("Connecting to ESP32")),
      body: Center(
        child: _connecting
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(_status),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red),
            SizedBox(height: 12),
            Text(_status),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Back to Device List"),
            )
          ],
        ),
      ),
    );
  }
}