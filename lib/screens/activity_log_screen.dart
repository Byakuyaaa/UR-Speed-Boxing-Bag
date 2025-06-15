import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminActivityLogScreen extends StatelessWidget {
  const AdminActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Activity Log"),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('activityLogs')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(child: Text("No activity logs found."));

          final logs = snapshot.data!.docs;
          print("Logs count: ${logs.length}");

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index].data()! as Map<String, dynamic>;
              final action = log['action'] ?? 'Unknown';
              final targetEmail = log['targetEmail'] ?? 'N/A';
              final adminEmail = log['adminEmail'] ?? 'N/A';
              final timestamp = (log['timestamp'] as Timestamp?)?.toDate();

              return ListTile(
                leading: const Icon(Icons.history),
                title: Text("$action - $targetEmail"),
                subtitle: Text("By: $adminEmail"),
                trailing: Text(
                  timestamp != null
                      ? "${timestamp.toLocal()}".split('.')[0]
                      : "Unknown time",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
