import 'dart:async';
import 'dart:io'; // Needed for InternetAddress
import 'package:flutter/material.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'connection_screen.dart';

class DeviceListScreen extends StatefulWidget {
  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final List<String> devices = [];
  final MDnsClient _mDnsClient = MDnsClient();
  bool scanning = true;

  @override
  void initState() {
    super.initState();
    _startMDnsScan();
  }

  Future<void> _startMDnsScan() async {
    try {
      await _mDnsClient.start();

      await for (final ptr in _mDnsClient.lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer('_http._tcp.local'),
      )) {
        final deviceName = ptr.domainName;
        if (deviceName.contains('esp32') && !devices.contains(deviceName)) {
          setState(() {
            devices.add(deviceName);
          });
        }
      }
    } catch (e) {
      print('mDNS scan error: $e');
    } finally {
      setState(() {
        scanning = false;
      });
      _mDnsClient.stop();
    }
  }

  Future<InternetAddress?> _resolveDeviceIP(String domainName) async {
    await for (final record in _mDnsClient.lookup<IPAddressResourceRecord>(
      ResourceRecordQuery.addressIPv4(domainName),
    )) {
      return record.address;
    }
    return null;
  }

  @override
  void dispose() {
    _mDnsClient.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Available Devices")),
      body: scanning
          ? Center(child: CircularProgressIndicator())
          : devices.isNotEmpty
          ? ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.memory),
            title: Text(devices[index]),
            trailing: ElevatedButton(
              child: Text("Connect"),
              onPressed: () async {
                final ip = await _resolveDeviceIP(devices[index]);
                if (ip != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConnectionScreen(
                        deviceName: devices[index],
                        deviceIP: ip,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Could not resolve IP address."),
                    ),
                  );
                }
              },
            ),
          );
        },
      )
          : Center(child: Text("No devices found.")),
    );
  }
}