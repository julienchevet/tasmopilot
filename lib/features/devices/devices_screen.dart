import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../discovery/discovery_dialog.dart';
import '../mqtt/providers/mqtt_providers.dart';
import '../mqtt/mqtt_discovery_dialog.dart';
import 'providers/device_control_providers.dart';
import '../../core/mqtt/mqtt_service.dart';
import '../sites/providers/site_providers.dart';
import 'providers/device_providers.dart';
import 'models/device.dart';
import 'package:tasmopilot/l10n/generated/app_localizations.dart';

class DevicesScreen extends ConsumerWidget {
  final int siteId;
  final String siteName;

  const DevicesScreen({
    super.key,
    required this.siteId,
    required this.siteName,
  });

  Color _getMqttColor(TasmotaMqttStatus state, bool isDark) {
    switch (state) {
      case TasmotaMqttStatus.connected:
        return isDark ? const Color(0xFF00E676) : Colors.white;
      case TasmotaMqttStatus.connecting:
        return Colors.orangeAccent;
      case TasmotaMqttStatus.error:
        return Colors.redAccent;
      case TasmotaMqttStatus.disconnected:
        return isDark ? Colors.grey : Colors.white54;
    }
  }

  void _showMqttDiscoveryDialog(BuildContext context, int siteId) {
    showDialog(
      context: context,
      builder: (context) => MqttDiscoveryDialog(siteId: siteId),
    );
  }

  Widget _buildMqttBadge(TasmotaMqttStatus status, bool isDark) {
    final color = _getMqttColor(status, isDark);
    final isConnected = status == TasmotaMqttStatus.connected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isConnected ? color.withOpacity(0.2) : null,
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'MQTT',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final devicesAsyncValue = ref.watch(devicesProvider(siteId));
    final mqttStatusAsync = ref.watch(mqttStatusProvider(siteId));
    final mqttStatus = mqttStatusAsync.value ?? TasmotaMqttStatus.disconnected;

    final sitesAsync = ref.watch(sitesProvider);
    final hasMqttConfig = sitesAsync.maybeWhen(
      data: (sites) {
        final site = sites.firstWhere((s) => s.id == siteId);
        return site.mqttHost != null && site.mqttHost!.isNotEmpty;
      },
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.devices} - $siteName'),
        actions: [
          if (hasMqttConfig)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: InkWell(
                onTap: () {
                  if (mqttStatus == TasmotaMqttStatus.connected) {
                    _showMqttDiscoveryDialog(context, siteId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('MQTT Status: ${mqttStatus.name}'),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: _buildMqttBadge(
                      mqttStatus,
                      Theme.of(context).brightness == Brightness.dark,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.radar),
            tooltip: l10n.scanNetwork,
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
            padding: const EdgeInsets.all(12),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return _buildDeviceCard(context, ref, device);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            '${l10n.error}: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDeviceDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.addDevice),
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, WidgetRef ref, Device device) {
    final liveStatusAsync = ref.watch(deviceStatusProvider(device.ipAddress));
    final liveStatus = liveStatusAsync.value;

    final isPowerOn =
        liveStatus?.isPowerOn ?? (device.powerState?.contains('ON') ?? false);
    final rssi = liveStatus?.rssi ?? device.rssi;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/site/$siteId/device', extra: device),
        onLongPress: () => _confirmDeleteDevice(context, ref, device.id!),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: CircleAvatar(
                      backgroundColor: isPowerOn
                          ? Colors.green.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      child: Icon(
                        Icons.power_settings_new,
                        color: isPowerOn ? Colors.green : Colors.grey,
                      ),
                    ),
                    onPressed: () {
                      ref
                          .read(deviceControlControllerProvider)
                          .togglePower(device.ipAddress);
                    },
                  ),
                  const SizedBox(
                    width: 4,
                  ), // Reduced from 12 since IconButton has padding
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${device.ipAddress}${device.version != null ? ' • v${device.version}' : ''}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (rssi != null) _buildWifiBadge(rssi),
                ],
              ),
              if (device.uptime != null || device.module != null) ...[
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      device.module ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                    if (device.uptime != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            device.uptime!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWifiBadge(int rssi) {
    Color color = Colors.red;
    IconData icon = Icons.wifi_1_bar;
    if (rssi > 75) {
      color = Colors.green;
      icon = Icons.wifi;
    } else if (rssi > 50) {
      color = Colors.orange;
      icon = Icons.wifi_2_bar;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$rssi%',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.devices_other, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.noDevices, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            l10n.noDevices, // Fallback
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDeviceDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ipController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.addDevice),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  hintText: 'ex: Lampe Salon',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ipController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.ipAddress,
                  hintText: 'ex: 192.168.1.50',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final ip = ipController.text.trim();
                if (name.isNotEmpty && ip.isNotEmpty) {
                  ref
                      .read(deviceControllerProvider)
                      .addDevice(siteId: siteId, name: name, ipAddress: ip);
                  Navigator.of(context).pop();
                }
              },
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteDevice(
    BuildContext context,
    WidgetRef ref,
    int deviceId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteDevice),
          content: Text(l10n.deleteDeviceConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(deviceControllerProvider)
                    .deleteDevice(siteId, deviceId);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }
}
