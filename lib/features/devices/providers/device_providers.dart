import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device.dart';
import '../repositories/device_repository.dart';

// Provider for the repository
final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepository();
});

final devicesProvider = FutureProvider.family<List<Device>, int>((ref, siteId) async {
  final repository = ref.read(deviceRepositoryProvider);
  return repository.getDevicesForSite(siteId);
});

// Provider for a single device
final deviceProvider = Provider.family<Device?, ({int siteId, int deviceId})>((ref, arg) {
  final devicesAsync = ref.watch(devicesProvider(arg.siteId));
  return devicesAsync.maybeWhen(
    data: (devices) => devices.firstWhere((d) => d.id == arg.deviceId),
    orElse: () => null,
  );
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
    String? module,
    String? version,
    String? topic,
    String? fullTopic,
    String? mqttHost,
    int? mqttPort,
    String? mqttUser,
    String? mqttPassword,
    String? mqttClientId,
    String? webPassword,
    String? ssid1,
    String? wifiPassword1,
    String? ssid2,
    String? wifiPassword2,
    String? hostname,
    String? groupTopic,
    String? friendlyName1,
    String? friendlyName2,
    int? rssi,
    String? uptime,
    String? powerState,
  }) async {
    final repository = ref.read(deviceRepositoryProvider);
    final newDevice = Device(
      siteId: siteId,
      name: name,
      ipAddress: ipAddress,
      macAddress: macAddress,
      createdAt: DateTime.now(),
      module: module,
      version: version,
      topic: topic,
      fullTopic: fullTopic,
      mqttHost: mqttHost,
      mqttPort: mqttPort,
      mqttUser: mqttUser,
      mqttPassword: mqttPassword,
      mqttClientId: mqttClientId,
      webPassword: webPassword,
      ssid1: ssid1,
      wifiPassword1: wifiPassword1,
      ssid2: ssid2,
      wifiPassword2: wifiPassword2,
      hostname: hostname,
      groupTopic: groupTopic,
      friendlyName1: friendlyName1,
      friendlyName2: friendlyName2,
      rssi: rssi,
      uptime: uptime,
      powerState: powerState,
    );
    await repository.createDevice(newDevice);
    ref.invalidate(devicesProvider(siteId)); // Refreshes the list
  }

  Future<void> updateDevice(Device device) async {
    final repository = ref.read(deviceRepositoryProvider);
    await repository.updateDevice(device);
    ref.invalidate(devicesProvider(device.siteId)); // Refreshes the list
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
