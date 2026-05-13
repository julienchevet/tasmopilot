import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/discovery_providers.dart';
import '../devices/providers/device_providers.dart';

class DiscoveryDialog extends ConsumerWidget {
  final int siteId;

  const DiscoveryDialog({super.key, required this.siteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discoveryAsyncValue = ref.watch(discoveryProvider);

    return AlertDialog(
      title: const Text('Recherche d\'appareils'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: discoveryAsyncValue.when(
          data: (devices) {
            if (devices.isEmpty) {
              return const Center(
                child: Text('Aucun appareil HTTP/Tasmota trouvé sur le réseau local.'),
              );
            }
            return ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  leading: const Icon(Icons.wifi, color: Colors.green),
                  title: Text(device.hostname.replaceAll('.local.', '')),
                  subtitle: Text(device.ipAddress),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    onPressed: () {
                      // Add device to database
                      ref.read(deviceControllerProvider).addDevice(
                        siteId: siteId,
                        name: device.hostname.replaceAll('.local.', '').replaceAll('._http._tcp', '').replaceAll('._hap._tcp', ''),
                        ipAddress: device.ipAddress,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${device.ipAddress} ajouté !')),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            );
          },
          loading: () => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              Text(
                'Ping des 254 adresses IP en cours...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          error: (error, stack) => Center(
            child: Text('Erreur: $error', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
        if (!discoveryAsyncValue.isLoading)
          TextButton(
            onPressed: () => ref.invalidate(discoveryProvider),
            child: const Text('Relancer le scan'),
          ),
      ],
    );
  }
}
