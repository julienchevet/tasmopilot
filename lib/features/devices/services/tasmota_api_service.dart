import 'dart:convert';
import 'package:http/http.dart' as http;

class TasmotaApiService {
  Future<Map<String, dynamic>> getStatus(String ipAddress) async {
    final uri = Uri.parse('http://$ipAddress/cm?cmnd=Status%200');
    final response = await http.get(uri).timeout(const Duration(seconds: 4));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load status');
    }
  }

  Future<bool> togglePower(String ipAddress, {int? relayIndex}) async {
    final cmd = relayIndex != null ? 'Power$relayIndex%20TOGGLE' : 'Power%20TOGGLE';
    final uri = Uri.parse('http://$ipAddress/cm?cmnd=$cmd');
    final response = await http.get(uri).timeout(const Duration(seconds: 4));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Tasmota can return "POWER", "POWER1", "POWER2", etc.
      final key = relayIndex != null ? 'POWER$relayIndex' : 'POWER';
      final powerState = data[key] ?? data['POWER'] ?? data['POWER1'];
      return powerState == 'ON';
    } else {
      throw Exception('Failed to toggle power');
    }
  }

  Future<bool> getPower(String ipAddress, {int? relayIndex}) async {
    final cmd = relayIndex != null ? 'Power$relayIndex' : 'Power';
    final uri = Uri.parse('http://$ipAddress/cm?cmnd=$cmd');
    final response = await http.get(uri).timeout(const Duration(seconds: 4));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final key = relayIndex != null ? 'POWER$relayIndex' : 'POWER';
      final powerState = data[key] ?? data['POWER'] ?? data['POWER1'];
      return powerState == 'ON';
    } else {
      throw Exception('Failed to get power status');
    }
  }
}
