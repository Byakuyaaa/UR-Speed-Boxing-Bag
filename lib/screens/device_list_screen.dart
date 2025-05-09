import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'safe_mdns_client.dart';
import 'connection_screen.dart'; // Make sure this path is correct

class DeviceListScreen extends StatefulWidget {
  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final List<String> devices = [];
  late final SafeMdnsClient _mDnsClient;
  bool scanning = true;

  @override
  void initState() {
    super.initState();
    _mDnsClient = SafeMdnsClient();
    _startMDnsScan();
  }

  Future<void> _startMDnsScan() async {
    setState(() => scanning = true);
    try {
      await _mDnsClient.start();

      await for (final PtrResourceRecord ptr in _mDnsClient.lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer('_http._tcp.local'),
      )) {
        final name = ptr.domainName;
        if (name.contains('esp32') && !devices.contains(name)) {
          setState(() => devices.add(name));
        }
      }
    } catch (e) {
      print('mDNS scan error: $e');
    } finally {
      setState(() => scanning = false);
      _mDnsClient.stop();
    }
  }

  Future<InternetAddress?> _resolveDeviceIP(String domainName) async {
    await for (final IPAddressResourceRecord record in _mDnsClient.lookup<IPAddressResourceRecord>(
      ResourceRecordQuery.addressIPv4(domainName),
    )) {
      return record.address;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(
          style: TextStyle(fontSize: 18, color: Colors.white),
          "Available Devices"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,),
      body: scanning
          ? Center(child: CircularProgressIndicator())
          : devices.isEmpty
          ? Center(child: Text("No devices found."))
          : ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, i) {
          return ListTile(
            leading: Icon(Icons.memory),
            title: Text(devices[i]),
            trailing: ElevatedButton(
              child: Text("Connect"),
              onPressed: () async {
                final ip = await _resolveDeviceIP(devices[i]);
                if (ip != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConnectionScreen(esp32IP: ip),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Could not resolve IP.")),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}