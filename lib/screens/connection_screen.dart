import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main_menu_screen.dart';

class ConnectionScreen extends StatefulWidget {
  final String deviceName;
  final InternetAddress deviceIP;

  const ConnectionScreen({
    required this.deviceName,
    required this.deviceIP,
  });

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  bool isConnecting = true;
  String statusMessage = "Connecting...";

  @override
  void initState() {
    super.initState();
    _attemptConnection();
  }

  Future<void> _attemptConnection() async {
    final url = Uri.parse('http://${widget.deviceIP.address}/'); // your ESP32 root

    try {
      final response = await http.get(url).timeout(Duration(seconds: 5));
      if (response.statusCode == 200 && response.body.contains("ESP32 OK")) {
        _navigateToMainMenu();
      } else {
        setState(() {
          isConnecting = false;
          statusMessage = "Device responded, but not as expected.";
        });
      }
    } on TimeoutException {
      setState(() {
        isConnecting = false;
        statusMessage = "Connection timed out.";
      });
    } on SocketException {
      setState(() {
        isConnecting = false;
        statusMessage = "Could not reach device.";
      });
    } catch (e) {
      setState(() {
        isConnecting = false;
        statusMessage = "Unexpected error: $e";
      });
    }
  }

  void _navigateToMainMenu() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainMenuScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Connecting")),
      body: Center(
        child: isConnecting
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Connecting to ${widget.deviceName}..."),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red),
            SizedBox(height: 10),
            Text(statusMessage),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Back to Device List"),
            ),
          ],
        ),
      ),
    );
  }
}
