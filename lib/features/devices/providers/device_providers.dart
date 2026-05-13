import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device.dart';
import '../repositories/device_repository.dart';

// Provider for the repository
final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepository();
});

// FutureProvider to load devices per site
final devicesProvider = FutureProvider.family<List<Device>, int>((ref, siteId) async {
  final repository = ref.read(deviceRepositoryProvider);
  return repository.getDevicesForSite(siteId);
});

// Controller to handle actions and refresh the UI
class DeviceController {
  final Ref ref;
  DeviceController(this.ref);

  Future<void> addDevice({
    required int siteId,
    required String name,
    required String ipAddress,
    String? macAddress,
  }) async {
    final repository = ref.read(deviceRepositoryProvider);
    final newDevice = Device(
      siteId: siteId,
      name: name,
      ipAddress: ipAddress,
      macAddress: macAddress,
      createdAt: DateTime.now(),
    );
    await repository.createDevice(newDevice);
    ref.invalidate(devicesProvider(siteId)); // Refreshes the list
  }

  Future<void> deleteDevice(int siteId, int deviceId) async {
    final repository = ref.read(deviceRepositoryProvider);
    await repository.deleteDevice(deviceId);
    ref.invalidate(devicesProvider(siteId)); // Refreshes the list
  }
}

final deviceControllerProvider = Provider<DeviceController>((ref) {
  return DeviceController(ref);
});
