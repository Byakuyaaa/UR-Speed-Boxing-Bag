import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class PowerGeneratedScreen extends StatefulWidget {
  @override
  _PowerGeneratedScreenState createState() => _PowerGeneratedScreenState();
}

class _PowerGeneratedScreenState extends State<PowerGeneratedScreen> {
  String selectedPeriod = "week";
  double powerGenerated = 0;
  double avgUser = 0;
  double proUser = 0;
  List<FlSpot> graphSpots = [];

  @override
  void initState() {
    super.initState();
    fetchPowerData();
  }

  Future<void> fetchPowerData() async {
    final doc = await FirebaseFirestore.instance.collection('powerGenerated').doc('current').get();
    final comparisonDoc = await FirebaseFirestore.instance.collection('powerGenerated').doc('userComparison').get();
    final graphSnap = await FirebaseFirestore.instance.collection('powerGenerated').doc('graphData').collection(selectedPeriod).get();

    setState(() {
      powerGenerated = doc[selectedPeriod];
      avgUser = comparisonDoc['avgUser'];
      proUser = comparisonDoc['proUser'];

      graphSpots = graphSnap.docs.map((e) {
        return FlSpot(double.tryParse(e.id.replaceAll(RegExp(r'\D'), ''))?.toDouble() ?? 0, e['y'].toDouble());
      }).toList();
    });
  }

  Widget buildGraph() {
    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: graphSpots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
              ),
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildToggleButton(String label, String period) {
    return ElevatedButton(
      onPressed: () {
        setState(() => selectedPeriod = period);
        fetchPowerData();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedPeriod == period ? Colors.blue : Colors.grey[300],
      ),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("POWER GENERATED")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildToggleButton("WEEKS", "week"),
                buildToggleButton("DAYS", "day"),
                buildToggleButton("HRS", "hour"),
              ],
            ),
            SizedBox(height: 20),
            Text("KW/H Saved in a Month"),
            buildGraph(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text("Avg."),
                    Container(
                      padding: EdgeInsets.all(12),
                      color: Colors.grey[200],
                      child: Text("${avgUser.toStringAsFixed(2)}"),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text("Pro"),
                    Container(
                      padding: EdgeInsets.all(12),
                      color: Colors.grey[200],
                      child: Text("${proUser.toStringAsFixed(2)}"),
                    ),
                  ],
                ),
              ],
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}