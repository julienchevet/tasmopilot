import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/mqtt_providers.dart';
import '../devices/providers/device_providers.dart';
import 'package:tasmopilot/l10n/generated/app_localizations.dart';

class MqttDiscoveryDialog extends ConsumerWidget {
  final int siteId;

  const MqttDiscoveryDialog({super.key, required this.siteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final discoveryAsyncValue = ref.watch(mqttDiscoveryProvider(siteId));

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.mqttDiscovery),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(mqttRefreshProvider(siteId))();
            },
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: discoveryAsyncValue.when(
          data: (devices) {
            if (devices.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      l10n.mqttDiscoveryDesc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final discovered = devices[index];
                final existingDevices = ref.watch(devicesProvider(siteId)).value ?? [];
                
                final isAlreadyAdded = existingDevices.any((d) => 
                  (d.macAddress != null && d.macAddress == discovered.macAddress) ||
                  (d.ipAddress == discovered.ipAddress)
                );

                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isAlreadyAdded ? Colors.grey : Colors.blue, 
                        width: 1.5
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'MQTT',
                      style: TextStyle(
                        color: isAlreadyAdded ? Colors.grey : Colors.blue,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(discovered.hostname),
                  subtitle: Text(discovered.ipAddress),
                  trailing: IconButton(
                    icon: Icon(
                      isAlreadyAdded ? Icons.check : Icons.add_circle,
                      color: isAlreadyAdded ? Colors.grey : null
                    ),
                    onPressed: isAlreadyAdded ? null : () {
                      ref.read(deviceControllerProvider).addDevice(
                        siteId: siteId,
                        name: discovered.hostname,
                        ipAddress: discovered.ipAddress,
                        macAddress: discovered.macAddress,
                        module: discovered.module,
                        version: discovered.version,
                        topic: discovered.topic,
                        friendlyName1: discovered.friendlyNames != null && discovered.friendlyNames!.isNotEmpty ? discovered.friendlyNames![0] : null,
                        friendlyName2: discovered.friendlyNames != null && discovered.friendlyNames!.length > 1 ? discovered.friendlyNames![1] : null,
                        rssi: discovered.rssi,
                        uptime: discovered.uptime,
                        powerState: discovered.powerState,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${discovered.hostname} ${l10n.add} !')),
                      );
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('${l10n.error}: $error')),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
