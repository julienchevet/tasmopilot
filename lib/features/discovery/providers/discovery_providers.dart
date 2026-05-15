import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/discovered_device.dart';
import '../services/subnet_scanner_service.dart';
final subnetScannerProvider = Provider<SubnetScannerService>((ref) {
  return SubnetScannerService();
});

// AutoDispose StreamProvider to trigger a scan and receive devices in real-time
final discoveryProvider = StreamProvider.autoDispose<List<DiscoveredDevice>>((ref) async* {
  final subnetService = ref.read(subnetScannerProvider);
  final List<DiscoveredDevice> discovered = [];
  
  // Initially yield an empty list
  yield discovered;
  
  await for (final device in subnetService.scanSubnet()) {
    if (!discovered.contains(device)) {
      discovered.add(device);
      // Yield a new copy of the list to trigger UI update
      yield List.from(discovered);
    }
  }
});
