import 'dart:async';
import 'package:flutter/material.dart';
import 'device_list_screen.dart';

class SearchingScreen extends StatefulWidget {
  @override
  _SearchingScreenState createState() => _SearchingScreenState();
}

class _SearchingScreenState extends State<SearchingScreen> {
  int dotCount = 0;
  late Timer dotTimer;
  late Timer navTimer;

  @override
  void initState() {
    super.initState();
    // Animate dots (like a loading indicator)
    dotTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        dotCount = (dotCount + 1) % 6;
      });
    });
    // Simulate a device search delay then navigate to device list
    navTimer = Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => DeviceListScreen()));
    });
  }

  @override
  void dispose() {
    dotTimer.cancel();
    navTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = '.' * dotCount;
    return Scaffold(
      appBar: AppBar(title: Text("Searching for Devices")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text("Scanning$dots", style: TextStyle(fontSize: 18)),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back),
            ),
          ],
        ),
      ),
    );
  }
}