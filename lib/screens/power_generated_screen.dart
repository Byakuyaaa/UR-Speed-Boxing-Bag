import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PowerGeneratedScreen extends StatefulWidget {
  @override
  _PowerGeneratedScreenState createState() => _PowerGeneratedScreenState();
}

class _PowerGeneratedScreenState extends State<PowerGeneratedScreen> {
  double totalHour = 0;
  double totalDay = 0;
  double totalWeek = 0;
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
        title: const Text(
          "Power Generated",
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
        child: StreamBuilder<DatabaseEvent>(
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

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    _buildPowerCard("Last 1 Hr", totalHour),
                    const SizedBox(height: 16),
                    _buildPowerCard("Last 24 Hrs", totalDay),
                    const SizedBox(height: 16),
                    _buildPowerCard("Last 7 Days", totalWeek),
                    const SizedBox(height: 16),
                    _buildPowerCard("Last 30 Days", monthlyTotal),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error loading data",
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(color: Colors.deepOrange),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildPowerCard(String title, double value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${value.toStringAsFixed(4)} kWh",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
