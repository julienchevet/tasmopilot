import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/discovered_device.dart';
import '../services/subnet_scanner_service.dart';
final subnetScannerProvider = Provider<SubnetScannerService>((ref) {
  return SubnetScannerService();
});

// AutoDispose FutureProvider to trigger a scan when someone watches it
final discoveryProvider = FutureProvider.autoDispose<List<DiscoveredDevice>>((ref) async {
  final subnetService = ref.read(subnetScannerProvider);
  return await subnetService.scanSubnet();
});
