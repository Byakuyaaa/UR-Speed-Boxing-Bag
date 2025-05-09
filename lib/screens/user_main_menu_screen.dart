import 'package:flutter/material.dart';
import 'searching_screen.dart';
import 'user_power_monitoring_screen.dart';
import 'device_list_screen.dart';

class UserMainMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("K.E.H.S.B.B. - User"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuButton(
                  icon: Icons.cable,
                  label: "Connect to the Equipment",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SearchingScreen()),
                  ),
                ),
                SizedBox(height: 20),
                _buildMenuButton(
                  icon: Icons.bolt,
                  label: "Power Monitoring",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => userPowerMonitoringScreen()),
                  ),
                ),
                SizedBox(height: 20),
                _buildMenuButton(
                  icon: Icons.devices,
                  label: "Device List",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DeviceListScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(label, style: TextStyle(fontSize: 18)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo,
        minimumSize: Size(double.infinity, 60),
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
    );
  }
}
