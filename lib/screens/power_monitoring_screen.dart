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
  _PowerMonitoringScreenState createState() => _PowerMonitoringScreenState();
}

class _PowerMonitoringScreenState extends State<PowerMonitoringScreen> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("sensorData/power");

  bool _connecting = true;
  String _status = "Connecting to ESP32…";

  List<FlSpot> _chartData = [];
  double _lastX = 0;

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
        title: const Text(
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
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(_status),
            if (!_status.contains("Connecting"))
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Back to Device List"),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.exists) {
            final value = snapshot.data!.snapshot.value;
            final power = double.tryParse(value.toString()) ?? 0.0;
            final powerStr = power.toStringAsFixed(2);

            // Update chart data
            _chartData.add(FlSpot(_lastX, power));
            _lastX += 1;
            if (_chartData.length > 20) {
              _chartData.removeAt(0);
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPowerCard(context, "Real-time Power Output", "$powerStr V"),
                const SizedBox(height: 30),
                const Text(
                  "Live Power Sensor Graph",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                AspectRatio(
                  aspectRatio: 1.6,
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _chartData,
                          isCurved: true,
                          color: Colors.blueAccent,
                          belowBarData: BarAreaData(show: false),
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildNavigateButton(context),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
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
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigateButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.analytics, size: 28),
      label: const Text(
        "View Generated Power",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
