import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/discovery_providers.dart';
import '../devices/providers/device_providers.dart';
import 'package:tasmopilot/l10n/generated/app_localizations.dart';

class DiscoveryDialog extends ConsumerWidget {
  final int siteId;

  const DiscoveryDialog({super.key, required this.siteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final discoveryAsyncValue = ref.watch(discoveryProvider);

    return AlertDialog(
      title: Text(l10n.deviceSearch),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: discoveryAsyncValue.when(
          data: (devices) {
            return Column(
              children: [
                if (discoveryAsyncValue.isLoading) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    l10n.scanningNetwork,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),
                ],
                if (devices.isEmpty && !discoveryAsyncValue.isLoading)
                  Expanded(
                    child: Center(
                      child: Text(l10n.noDevicesFound),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final discovered = devices[index];
                        final existingDevices = ref.watch(devicesProvider(siteId)).value ?? [];
                        
                        final isAlreadyAdded = existingDevices.any((d) => 
                          (d.macAddress != null && d.macAddress == discovered.macAddress) ||
                          (d.ipAddress == discovered.ipAddress)
                        );

                        return ListTile(
                          leading: Icon(
                            isAlreadyAdded ? Icons.check_circle : Icons.wifi, 
                            color: isAlreadyAdded ? Colors.grey : Colors.green
                          ),
                          title: Text(discovered.hostname.replaceAll('.local.', '')),
                          subtitle: Text(discovered.ipAddress),
                          trailing: IconButton(
                            icon: Icon(
                              isAlreadyAdded ? Icons.check : Icons.add_circle, 
                              color: isAlreadyAdded ? Colors.grey : Theme.of(context).colorScheme.primary
                            ),
                            onPressed: isAlreadyAdded ? null : () {
                              ref.read(deviceControllerProvider).addDevice(
                                siteId: siteId,
                                name: discovered.hostname
                                    .replaceAll('.local.', '')
                                    .replaceAll('._http._tcp', '')
                                    .replaceAll('._hap._tcp', ''),
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
                                SnackBar(content: Text('${discovered.ipAddress} ${l10n.add} !')),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.initializingScan),
              ],
            ),
          ),
          error: (error, stack) => Center(
            child: Text('Erreur: $error', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
        if (!discoveryAsyncValue.isLoading)
          TextButton(
            onPressed: () => ref.invalidate(discoveryProvider),
            child: Text(l10n.rescan),
          ),
      ],
    );
  }
}
