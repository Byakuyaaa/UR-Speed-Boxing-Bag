import 'dart:async';
import 'dart:io';
import 'package:multicast_dns/multicast_dns.dart';

class SafeMdnsClient {
  MDnsClient? _client;
  RawDatagramSocket? _socket;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    try {
      _client = MDnsClient();
      await _client!.start();
    } on SocketException catch (e) {
      if (e.osError?.message.contains('reusePort') ?? false) {
        print('reusePort unsupported, fallback starting manually...');
        _socket = await RawDatagramSocket.bind(
          InternetAddress.anyIPv4,
          5353,
          reusePort: false,
        );
        _client = MDnsClient(
          rawDatagramSocketFactory: (dynamic address, int port, {bool? reuseAddress, bool? reusePort, int? ttl}) async {
            return _socket!;
          },
        );
        await _client!.start();
      } else {
        rethrow;
      }
    }
    _started = true;
  }

  void stop() {
    _client?.stop();
    _socket?.close();
    _started = false;
  }

  Stream<T> lookup<T extends ResourceRecord>(ResourceRecordQuery query) {
    if (!_started) {
      throw StateError('SafeMdnsClient is not started.');
    }
    return _client!.lookup<T>(query);
  }
}