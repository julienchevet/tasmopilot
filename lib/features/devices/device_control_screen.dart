import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/device.dart';
import 'providers/device_control_providers.dart';

class DeviceControlScreen extends ConsumerWidget {
  final Device device;

  const DeviceControlScreen({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsyncValue = ref.watch(deviceStatusProvider(device.ipAddress));

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Device settings (edit name, ip, etc.)
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              device.ipAddress,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 64),
            
            statusAsyncValue.when(
              data: (isOn) => _buildPowerButton(context, ref, isOn),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => _buildErrorState(context, ref, error),
            ),
            
            const SizedBox(height: 32),
            if (statusAsyncValue.hasValue)
              Text(
                statusAsyncValue.value == true ? 'ALLUMÉ' : 'ÉTEINT',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: statusAsyncValue.value == true ? Colors.green : Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerButton(BuildContext context, WidgetRef ref, bool isOn) {
    return GestureDetector(
      onTap: () {
        // Optimistic UI update could be added here, but for now we wait for network
        ref.read(deviceControlControllerProvider).togglePower(device.ipAddress).catchError((e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur: Impossible de contacter l\'appareil')),
            );
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOn ? Colors.green : Colors.grey[800],
          boxShadow: [
            BoxShadow(
              color: (isOn ? Colors.green : Colors.black).withAlpha(128),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: const Icon(
          Icons.power_settings_new,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Column(
      children: [
        const Icon(Icons.wifi_off, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        const Text('Appareil hors ligne ou inaccessible'),
        TextButton(
          onPressed: () => ref.invalidate(deviceStatusProvider(device.ipAddress)),
          child: const Text('Réessayer'),
        )
      ],
    );
  }
}
