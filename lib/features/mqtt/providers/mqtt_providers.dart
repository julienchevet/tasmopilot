import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../../../core/mqtt/mqtt_service.dart';
import '../../sites/providers/site_providers.dart';
import '../../discovery/models/discovered_device.dart';

// Provider for the MQTT Service instance — NOT autoDispose so the connection
// stays alive as long as any listener (e.g. mqttStatusProvider) holds a ref.
final mqttServiceProvider = Provider.family<TasmotaMqttService, int>((ref, siteId) {
  final service = TasmotaMqttService();
  ref.onDispose(() => service.dispose());
  return service;
});

// StreamProvider to manage the connection life-cycle and status.
// Uses ref.watch so the service lifetime is tied to this provider.
final mqttStatusProvider = StreamProvider.autoDispose.family<TasmotaMqttStatus, int>((ref, siteId) async* {
  // ref.watch keeps the service alive as long as this provider is alive.
  final service = ref.watch(mqttServiceProvider(siteId));

  // Get site info
  final sites = await ref.read(sitesProvider.future);
  final site = sites.firstWhere((s) => s.id == siteId);

  if (site.mqttHost == null || site.mqttHost!.isEmpty) {
    yield TasmotaMqttStatus.disconnected;
    return;
  }

  // Connect only if not already connected/connecting
  if (service.currentState == TasmotaMqttStatus.disconnected ||
      service.currentState == TasmotaMqttStatus.error) {
    service.connect(site).then((connected) {
      if (connected) {
        service.subscribe('tele/+/LWT');
        service.subscribe('tele/+/INFO1');
        service.subscribe('stat/+/STATUS#');
        service.publish('cmnd/tasmotas/Status', '0');
      }
    });
  }

  // Emit the current state immediately, then stream subsequent changes.
  yield service.currentState;
  yield* service.statusStream;
});

// Helper provider for manual refresh
final mqttRefreshProvider = Provider.autoDispose.family<void Function(), int>((ref, siteId) {
  return () {
    final service = ref.watch(mqttServiceProvider(siteId));
    if (service.currentState == TasmotaMqttStatus.connected) {
      service.publish('cmnd/tasmotas/Status', '0');
    }
  };
});

// Stream of discovered devices via MQTT
final mqttDiscoveryProvider = StreamProvider.autoDispose.family<List<DiscoveredDevice>, int>((ref, siteId) async* {
  final service = ref.watch(mqttServiceProvider(siteId));
  final Map<String, DiscoveredDevice> discoveredMap = {};
  
  yield [];

  await for (final message in service.messageStream) {
    final topic = message.topic;
    final payload = MqttPublishPayload.bytesToStringAsString(
        (message.payload as MqttPublishMessage).payload.message);

    final parts = topic.split('/');
    if (parts.length >= 2) {
      final deviceTopic = parts[1];
      
      try {
        final data = json.decode(payload);
        var device = discoveredMap[deviceTopic] ?? DiscoveredDevice(
          ipAddress: '', 
          hostname: deviceTopic,
        );

        if (topic.endsWith('/INFO1')) {
          device = DiscoveredDevice(
            ipAddress: data['IPAddress'] ?? device.ipAddress,
            hostname: data['Hostname'] ?? device.hostname,
            macAddress: device.macAddress,
            module: data['Module'] ?? device.module,
            version: data['Version'] ?? device.version,
          );
        } else if (topic.contains('/STATUS')) {
          // Status 0 returns multiple messages: STATUS, STATUS1, STATUS2...
          if (data.containsKey('StatusNET')) {
            final statusNet = data['StatusNET'];
            device = DiscoveredDevice(
              ipAddress: statusNet['IPAddress'] ?? device.ipAddress,
              hostname: statusNet['Hostname'] ?? device.hostname,
              macAddress: statusNet['Mac'] ?? device.macAddress,
              module: device.module,
              version: device.version,
              topic: device.topic,
              friendlyNames: device.friendlyNames,
              rssi: device.rssi,
              uptime: device.uptime,
              powerState: device.powerState,
            );
          } else if (data.containsKey('Status')) {
            final status = data['Status'];
            List<String> fNames = device.friendlyNames ?? [];
            if (status['FriendlyName'] is List) {
              fNames = List<String>.from(status['FriendlyName']);
            } else if (status['FriendlyName'] != null) {
              fNames = [status['FriendlyName'].toString()];
            }
            device = DiscoveredDevice(
              ipAddress: device.ipAddress,
              hostname: device.hostname,
              macAddress: device.macAddress,
              module: status['DeviceName'] ?? device.module,
              topic: status['Topic'] ?? device.topic,
              friendlyNames: fNames,
              version: device.version,
              rssi: device.rssi,
              uptime: device.uptime,
              powerState: device.powerState,
            );
          } else if (data.containsKey('StatusFWR')) {
            device = DiscoveredDevice(
              ipAddress: device.ipAddress,
              hostname: device.hostname,
              macAddress: device.macAddress,
              module: device.module,
              version: data['StatusFWR']['Version'],
              topic: device.topic,
              friendlyNames: device.friendlyNames,
              rssi: device.rssi,
              uptime: device.uptime,
              powerState: device.powerState,
            );
          } else if (data.containsKey('StatusSTS')) {
            final sts = data['StatusSTS'];
            device = DiscoveredDevice(
              ipAddress: device.ipAddress,
              hostname: device.hostname,
              macAddress: device.macAddress,
              module: device.module,
              version: device.version,
              topic: device.topic,
              friendlyNames: device.friendlyNames,
              rssi: sts['Wifi']?['RSSI'],
              uptime: sts['Uptime'],
              powerState: device.powerState,
            );
          }
        }

        if (device.ipAddress.isNotEmpty) {
          discoveredMap[deviceTopic] = device;
          yield discoveredMap.values.toList();
        }
      } catch (e) {
        // ignore
      }
    }
  }
});
