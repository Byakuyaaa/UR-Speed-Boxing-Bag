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
    _powerStream = _database.child('powerGenerated/readings').onValue;
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
                  _summaryBox("Last 1 Hr", totalHour),
                  SizedBox(height: 12),
                  _summaryBox("Last 24 Hrs", totalDay),
                  SizedBox(height: 12),
                  _summaryBox("Last 7 Days", totalWeek),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${value.toStringAsFixed(4)} kWh",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }


}