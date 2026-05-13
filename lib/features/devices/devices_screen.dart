import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../discovery/discovery_dialog.dart';
import 'providers/device_providers.dart';

class DevicesScreen extends ConsumerWidget {
  final int siteId;
  final String siteName;

  const DevicesScreen({
    super.key,
    required this.siteId,
    required this.siteName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsyncValue = ref.watch(devicesProvider(siteId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Appareils - $siteName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.radar),
            tooltip: 'Scanner le réseau (mDNS)',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => DiscoveryDialog(siteId: siteId),
              );
            },
          ),
        ],
      ),
      body: devicesAsyncValue.when(
        data: (devices) {
          if (devices.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.lightbulb_outline, color: Colors.white),
                  ),
                  title: Text(
                    device.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('IP: ${device.ipAddress}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmDeleteDevice(context, ref, device.id!),
                  ),
                  onTap: () {
                    context.go('/site/$siteId/device', extra: device);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDeviceDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un appareil'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.devices_other, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Aucun appareil sur ce site',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajoutez un appareil manuellement ou utilisez\nla découverte réseau.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDeviceDialog(BuildContext context, WidgetRef ref) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ipController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un appareil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'appareil',
                  hintText: 'ex: Lampe Salon',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ipController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Adresse IP',
                  hintText: 'ex: 192.168.1.50',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final ip = ipController.text.trim();
                if (name.isNotEmpty && ip.isNotEmpty) {
                  ref.read(deviceControllerProvider).addDevice(
                    siteId: siteId,
                    name: name,
                    ipAddress: ip,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteDevice(BuildContext context, WidgetRef ref, int deviceId) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer l\'appareil ?'),
          content: const Text('Cette action est irréversible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                ref.read(deviceControllerProvider).deleteDevice(siteId, deviceId);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
