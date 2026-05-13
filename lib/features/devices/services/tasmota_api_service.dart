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

  Future<bool> togglePower(String ipAddress) async {
    final uri = Uri.parse('http://$ipAddress/cm?cmnd=Power%20TOGGLE');
    final response = await http.get(uri).timeout(const Duration(seconds: 4));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Tasmota can return "POWER" or "POWER1"
      final powerState = data['POWER'] ?? data['POWER1'];
      return powerState == 'ON';
    } else {
      throw Exception('Failed to toggle power');
    }
  }

  Future<bool> getPower(String ipAddress) async {
    final uri = Uri.parse('http://$ipAddress/cm?cmnd=Power');
    final response = await http.get(uri).timeout(const Duration(seconds: 4));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final powerState = data['POWER'] ?? data['POWER1'];
      return powerState == 'ON';
    } else {
      throw Exception('Failed to get power status');
    }
  }
}
