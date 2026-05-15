import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/discovered_device.dart';

class SubnetScannerService {
  /// Gets the local IPv4 address (e.g. 192.168.1.15)
  Future<String?> _getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      for (var interface in interfaces) {
        for (var address in interface.addresses) {
          // Check for private IPv4 ranges
          final addr = address.address;
          if (addr.startsWith('192.168.') ||
              addr.startsWith('10.') ||
              (addr.startsWith('172.') && _isPrivateIPv4(addr))) {
            return addr;
          }
        }
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  bool _isPrivateIPv4(String address) {
    final parts = address.split('.');
    if (parts.length != 4) return false;
    if (parts[0] == '172') {
      final second = int.tryParse(parts[1]) ?? 0;
      return second >= 16 && second <= 31;
    }
    return false;
  }

  /// Scans the entire /24 subnet for Tasmota devices and emits them via a Stream
  Stream<DiscoveredDevice> scanSubnet() {
    final controller = StreamController<DiscoveredDevice>();
    
    _performScan(controller);
    
    return controller.stream;
  }

  Future<void> _performScan(StreamController<DiscoveredDevice> controller) async {
    try {
      final localIp = await _getLocalIpAddress();
      if (localIp == null) {
        await controller.close();
        return;
      }

      final subnet = localIp.substring(0, localIp.lastIndexOf('.'));
      
      // Limit concurrency to 15 workers to avoid OS resource exhaustion
      const int maxConcurrent = 15;
      int currentSuffix = 1;

      Future<void> worker() async {
        while (true) {
          final suffix = currentSuffix++;
          if (suffix > 254) break;
          
          final ip = '$subnet.$suffix';
          final device = await _checkIfTasmota(ip);
          if (device != null) {
            controller.add(device);
          }
        }
      }

      final workers = List.generate(maxConcurrent, (_) => worker());
      await Future.wait(workers);
    } catch (e) {
      // Stream error if necessary
    } finally {
      await controller.close();
    }
  }

  Future<DiscoveredDevice?> _checkIfTasmota(String ip) async {
    try {
      // Very fast socket check first to avoid HTTP timeouts on dead IPs
      // We use 600ms as a balance between speed and reliability
      final socket = await Socket.connect(ip, 80, timeout: const Duration(milliseconds: 600));
      socket.destroy();

      // If port 80 is open, ask Tasmota API for full status (Status 0)
      final uri = Uri.parse('http://$ip/cm?cmnd=Status%200');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map) {
          final statusObj = data['Status'];
          final statusNet = data['StatusNET'];
          final statusFwr = data['StatusFWR'];
          final statusSts = data['StatusSTS'];

          if (statusObj == null || statusNet == null) return null;

          final hostname = statusNet['Hostname'] ?? 'Tasmota';
          final mac = statusNet['Mac'];
          final module = statusObj['DeviceName']; // or Module
          final version = statusFwr?['Version'];
          final topic = statusObj['Topic'];
          
          List<String> friendlyNames = [];
          if (statusObj['FriendlyName'] is List) {
            friendlyNames = List<String>.from(statusObj['FriendlyName']);
          } else if (statusObj['FriendlyName'] != null) {
            friendlyNames = [statusObj['FriendlyName'].toString()];
          }

          int? rssi = statusSts?['Wifi']?['RSSI'];
          String? uptime = statusSts?['Uptime'];
          
          // Get all power states
          List<String> powers = [];
          if (statusSts != null) {
            statusSts.forEach((key, value) {
              if (key.startsWith('POWER')) {
                powers.add(value.toString());
              }
            });
          }

          return DiscoveredDevice(
            ipAddress: ip,
            hostname: hostname,
            macAddress: mac,
            module: module,
            version: version,
            topic: topic,
            friendlyNames: friendlyNames,
            rssi: rssi,
            uptime: uptime,
            powerState: powers.isNotEmpty ? powers.join(',') : null,
          );
        }
      }
    } catch (e) {
      // Ignore any errors (Connection refused, timeout, JSON error, etc.)
    }
    return null;
  }
}
