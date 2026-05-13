import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tasmota_api_service.dart';

final tasmotaApiProvider = Provider<TasmotaApiService>((ref) {
  return TasmotaApiService();
});

// A family provider that polls the device status every 5 seconds
final deviceStatusProvider = StreamProvider.family.autoDispose<bool, String>((ref, ipAddress) async* {
  final api = ref.read(tasmotaApiProvider);
  
  // Initial fetch
  try {
    yield await api.getPower(ipAddress);
  } catch (e) {
    // Ignore initial error, maybe device is offline
  }

  bool isDisposed = false;
  ref.onDispose(() => isDisposed = true);

  // Poll every 5 seconds
  while (!isDisposed) {
    await Future.delayed(const Duration(seconds: 5));
    if (isDisposed) break;
    try {
      yield await api.getPower(ipAddress);
    } catch (e) {
      // Keep previous state or yield error?
      // In a real app we might yield an error state to show offline
    }
  }
});

class DeviceControlController {
  final Ref ref;
  DeviceControlController(this.ref);

  Future<void> togglePower(String ipAddress) async {
    final api = ref.read(tasmotaApiProvider);
    await api.togglePower(ipAddress);
    // Invalidate the status provider to fetch new state immediately
    ref.invalidate(deviceStatusProvider(ipAddress));
  }
}

final deviceControlControllerProvider = Provider<DeviceControlController>((ref) {
  return DeviceControlController(ref);
});
