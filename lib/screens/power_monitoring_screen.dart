import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'power_generated_screen.dart';

class PowerMonitoringScreen extends StatefulWidget {
  final InternetAddress esp32IP;

  const PowerMonitoringScreen({required this.esp32IP});

  @override
  State<PowerMonitoringScreen> createState() => _PowerMonitoringScreenState();
}

class _PowerMonitoringScreenState extends State<PowerMonitoringScreen> {
  final _powerRef = FirebaseDatabase.instance.ref("sensorData/power");
  final _batteryRef = FirebaseDatabase.instance.ref("sensorData/batteryPercentage");
  final _perPunchRef = FirebaseDatabase.instance.ref("sensorData/joulesPerPunch");

  bool _connecting = true;
  String _status = "Connecting to ESP32…";

  final List<FlSpot> _chartData = [];
  double _lastX = 0;

  double? _currentPower;
  double? _currentBattery;
  double? _perPunchJoules;

  StreamSubscription<DatabaseEvent>? _powerSub;
  StreamSubscription<DatabaseEvent>? _batterySub;
  StreamSubscription<DatabaseEvent>? _perPunchSub;

  @override
  void initState() {
    super.initState();
    _attemptConnection();
    _listenToFirebase();
  }

  @override
  void dispose() {
    _powerSub?.cancel();
    _batterySub?.cancel();
    _perPunchSub?.cancel();
    super.dispose();
  }

  void _listenToFirebase() {
    _powerSub = _powerRef.onValue.listen((event) {
      final val = double.tryParse(event.snapshot.value.toString());
      if (val != null) {
        setState(() {
          _currentPower = val;
          _chartData.add(FlSpot(_lastX, val));
          _lastX += 1;
          if (_chartData.length > 20) _chartData.removeAt(0);
        });
      }
    });

    _batterySub = _batteryRef.onValue.listen((event) {
      final val = double.tryParse(event.snapshot.value.toString());
      if (val != null) {
        setState(() => _currentBattery = val);
      }
    });

    _perPunchSub = _perPunchRef.onValue.listen((event) {
      final val = double.tryParse(event.snapshot.value.toString());
      if (val != null) {
        setState(() => _perPunchJoules = val);
      }
    });
  }

  Future<void> _attemptConnection() async {
    try {
      final ipString = widget.esp32IP.address;
      final uri = Uri.parse('http://$ipString/');
      final resp = await http.get(uri).timeout(const Duration(seconds: 5));

      if (resp.statusCode == 200 && resp.body.contains("ESP32 OK")) {
        setState(() => _connecting = false);
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
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Smart Boxing Energy",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.deepOrange.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _connecting ? _buildConnectingUI() : _buildPowerContent(context, screenSize),
      ),
    );
  }

  Widget _buildConnectingUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.deepOrange),
          const SizedBox(height: 12),
          Text(_status, style: TextStyle(color: Colors.white)),
          if (!_status.contains("Connecting"))
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back to Device List"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPowerContent(BuildContext context, Size screenSize) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
      child: Center(
        child: Column(
          children: [
            SizedBox(height: screenSize.height * 0.03),
            _buildPowerCard(
              "Real-time Power Output",
              _currentPower != null ? "${_currentPower!.toStringAsFixed(2)} V" : "Loading...",
              screenSize,
            ),
            SizedBox(height: screenSize.height * 0.02),
            _buildPowerCard(
              "Battery Percentage",
              _currentBattery != null ? "${_currentBattery!.toStringAsFixed(2)}%" : "Loading...",
              screenSize,
            ),
            SizedBox(height: screenSize.height * 0.02),
            _buildPowerCard(
              "Per Punch Energy",
              _perPunchJoules != null ? "${_perPunchJoules!.toStringAsFixed(6)} J" : "Loading...",
              screenSize,
            ),
            SizedBox(height: screenSize.height * 0.035),
            const Text(
              "Live Power Sensor Graph",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: 1.4,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _chartData,
                      isCurved: true,
                      color: Colors.orangeAccent,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenSize.height * 0.04),
            _buildNavigateButton(context, screenSize),
            SizedBox(height: screenSize.height * 0.04),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerCard(String title, String value, Size screenSize) {
    return Container(
      width: screenSize.width * 0.85,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepOrange, Colors.orangeAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigateButton(BuildContext context, Size screenSize) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.analytics, size: 24, color: Colors.white),
      label: const Text(
        "View Generated Power",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.08,
          vertical: screenSize.height * 0.018,
        ),
        backgroundColor: Colors.deepOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 4,
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PowerGeneratedScreen()),
      ),
    );
  }
}
