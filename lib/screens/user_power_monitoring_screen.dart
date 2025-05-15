import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';

class UserPowerMonitoringScreen extends StatefulWidget {
  final InternetAddress esp32IP;

  UserPowerMonitoringScreen({Key? key, required this.esp32IP}) : super(key: key);

  @override
  _UserPowerMonitoringScreenState createState() => _UserPowerMonitoringScreenState();
}

class _UserPowerMonitoringScreenState extends State<UserPowerMonitoringScreen> {
  final DatabaseReference _powerRef = FirebaseDatabase.instance.ref("sensorData/power");
  List<FlSpot> _chartData = [];
  double _lastX = 0;

  @override
  void initState() {
    super.initState();

    _powerRef.onValue.listen((event) {
      final raw = event.snapshot.value;
      final value = double.tryParse(raw.toString()) ?? 0;

      setState(() {
        _chartData.add(FlSpot(_lastX, value));
        _lastX += 1;
        if (_chartData.length > 20) {
          _chartData.removeAt(0);
        }
      });
    });
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPowerCard("Real-time Power Output", context),
              const SizedBox(height: 24),
              Text(
                "Connected to ESP32 at: ${widget.esp32IP.address}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerCard(String title, BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.8;
    final latestValue = _chartData.isNotEmpty
        ? _chartData.last.y.toStringAsFixed(2)
        : "--";

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
            "$latestValue V",
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
