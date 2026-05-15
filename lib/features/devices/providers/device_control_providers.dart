import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tasmota_api_service.dart';

final tasmotaApiProvider = Provider<TasmotaApiService>((ref) {
  return TasmotaApiService();
});

class DeviceLiveStatus {
  final bool isPowerOn;
  final int? rssi;
  final Map<String, dynamic> rawData;
  
  DeviceLiveStatus({
    required this.isPowerOn, 
    this.rssi,
    required this.rawData,
  });

  // Helper getters for common fields
  String? get version => rawData['StatusFWR']?['Version'];
  String? get module => rawData['Status']?['Module'];
  String? get uptime => rawData['StatusSTS']?['Uptime'];
  String? get ssid => rawData['StatusSTS']?['Wifi']?['SSID'];
  String? get mqttHost => rawData['StatusMQT']?['Host'];
  String? get macAddress => rawData['StatusNET']?['Mac'];
}

// A family provider that polls the device status every 5 seconds
final deviceStatusProvider = StreamProvider.family.autoDispose<DeviceLiveStatus, String>((ref, ipAddress) async* {
  final api = ref.read(tasmotaApiProvider);
  
  Future<DeviceLiveStatus> fetchStatus() async {
    final status = await api.getStatus(ipAddress);
    
    final powerKey = status['Status']?['Power'] ?? 0;
    final rssi = status['StatusSTS']?['Wifi']?['RSSI'];
    final powerState = status['StatusSTS']?['POWER'] ?? status['StatusSTS']?['POWER1'] ?? (powerKey == 1 ? 'ON' : 'OFF');
    
    return DeviceLiveStatus(
      isPowerOn: powerState == 'ON',
      rssi: rssi,
      rawData: status,
    );
  }

  // Initial fetch
  try {
    yield await fetchStatus();
  } catch (e) {
    // Ignore initial error
  }

  bool isDisposed = false;
  ref.onDispose(() => isDisposed = true);

  while (!isDisposed) {
    await Future.delayed(const Duration(seconds: 5));
    if (isDisposed) break;
    try {
      yield await fetchStatus();
    } catch (e) {
      // Ignore
    }
  }
});

class DeviceControlController {
  final Ref ref;
  DeviceControlController(this.ref);

  Future<void> togglePower(String ipAddress, {int? relayIndex}) async {
    final api = ref.read(tasmotaApiProvider);
    await api.togglePower(ipAddress, relayIndex: relayIndex);
    ref.invalidate(deviceStatusProvider(ipAddress));
  }
}

final deviceControlControllerProvider = Provider<DeviceControlController>((ref) {
  return DeviceControlController(ref);
});
