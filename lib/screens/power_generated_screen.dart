import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class PowerGeneratedScreen extends StatefulWidget {
  @override
  _PowerGeneratedScreenState createState() => _PowerGeneratedScreenState();
}

class _PowerGeneratedScreenState extends State<PowerGeneratedScreen> {
  double totalHour = 0;
  double totalDay = 0;
  double totalWeek = 0;
  List<FlSpot> monthlySpots = [];
  double monthlyTotal = 0;

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Stream<DatabaseEvent>? _powerStream;

  @override
  void initState() {
    super.initState();
    _powerStream = _database.child('powerGenerated').onValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              style: TextStyle(fontSize: 18, color: Colors.white),
              "Power Generated"),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          elevation: 0,),
      body: StreamBuilder<DatabaseEvent>(
        stream: _powerStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.exists) {
            final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

            double hourlyKwh = (data['hourly'] ?? 0).toDouble();
            double dailyKwh = (data['daily'] ?? 0).toDouble();
            double weeklyKwh = (data['weekly'] ?? 0).toDouble();

            totalHour = hourlyKwh;
            totalDay = dailyKwh;
            totalWeek = weeklyKwh;
            monthlyTotal = weeklyKwh / 4; // Estimated monthly

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _summaryBox("Last 1 Hr", totalHour),
                      _summaryBox("Last 24 Hrs", totalDay),
                      _summaryBox("Last 7 Days", totalWeek),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    "kWh Saved (Estimated)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${monthlyTotal.toStringAsFixed(4)} kWh (approx.)",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  _lineChart(),
                  Spacer(),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading data"));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _summaryBox(String label, double value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${value.toStringAsFixed(4)} kWh",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineChart() {
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: monthlySpots.isEmpty ? [FlSpot(0, 0)] : monthlySpots,
              isCurved: true,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}