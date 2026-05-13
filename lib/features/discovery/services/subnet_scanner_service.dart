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
          if (address.address.startsWith('192.168.') ||
              address.address.startsWith('10.') ||
              address.address.startsWith('172.')) {
            return address.address;
          }
        }
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  /// Scans the entire /24 subnet for Tasmota devices
  Future<List<DiscoveredDevice>> scanSubnet() async {
    final localIp = await _getLocalIpAddress();
    if (localIp == null) return [];

    final subnet = localIp.substring(0, localIp.lastIndexOf('.'));
    final List<DiscoveredDevice> devices = [];
    final List<Future<void>> tasks = [];

    // Scan IPs from .1 to .254
    for (int i = 1; i < 255; i++) {
      final ip = '$subnet.$i';
      tasks.add(_checkIfTasmota(ip, devices));
    }

    // Wait for all HTTP checks to finish
    await Future.wait(tasks);
    return devices;
  }

  Future<void> _checkIfTasmota(String ip, List<DiscoveredDevice> devices) async {
    try {
      // Very fast socket check first to avoid HTTP timeouts on dead IPs
      // We use 800ms to be safe on slower Wi-Fi networks
      final socket = await Socket.connect(ip, 80, timeout: const Duration(milliseconds: 800));
      socket.destroy();

      // If port 80 is open, ask Tasmota API
      final uri = Uri.parse('http://$ip/cm?cmnd=Status');
      final response = await http.get(uri).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Tasmota's 'Status' command returns {"Status":{"DeviceName":"..."}}
        if (data is Map && data.containsKey('Status')) {
          final statusObj = data['Status'];
          final deviceName = statusObj['DeviceName'] ?? statusObj['FriendlyName']?[0] ?? 'Tasmota';
          
          devices.add(DiscoveredDevice(
            ipAddress: ip,
            hostname: deviceName,
          ));
        }
      }
    } catch (e) {
      // Ignore any errors (Connection refused, timeout, JSON error, etc.)
    }
  }
}
