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
        return isDark ? const Color(0xFF00E676) : const Color(0xFF16A34A);
      case TasmotaMqttStatus.connecting:
        return isDark ? Colors.orangeAccent : const Color(0xFFD97706);
      case TasmotaMqttStatus.error:
        return isDark ? Colors.redAccent : const Color(0xFFDC2626);
      case TasmotaMqttStatus.disconnected:
        return isDark ? Colors.grey : const Color(0xFF64748B);
    }
  }

  void _showMqttDiscoveryDialog(BuildContext context, int siteId) {
    showDialog(
      context: context,
      builder: (context) => MqttDiscoveryDialog(siteId: siteId),
    );
  }

  Widget _buildMqttBadge(
    BuildContext context,
    TasmotaMqttStatus status,
    bool isDark,
  ) {
    final color = _getMqttColor(status, isDark);
    final isConnected = status == TasmotaMqttStatus.connected;
    final isConnecting = status == TasmotaMqttStatus.connecting;

    final label = switch (status) {
      TasmotaMqttStatus.connected => 'MQTT ●',
      TasmotaMqttStatus.connecting => 'MQTT ◌',
      TasmotaMqttStatus.error => 'MQTT ✕',
      TasmotaMqttStatus.disconnected => 'MQTT ○',
    };

    return GestureDetector(
      onTap: () => _showMqttDiscoveryDialog(context, siteId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(isConnected || isConnecting ? 0.15 : 0.08),
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(siteName),
            actions: [
              if (hasMqttConfig)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8,
                  ),
                  child: Center(
                    child: _buildMqttBadge(
                      context,
                      mqttStatus,
                      Theme.of(context).brightness == Brightness.dark,
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.radar_rounded),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => DiscoveryDialog(siteId: siteId),
                  );
                },
              ),
            ],
          ),
          devicesAsyncValue.when(
            data: (devices) {
              if (devices.isEmpty) {
                return SliverFillRemaining(child: _buildEmptyState(context));
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisExtent: 180,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final device = devices[index];
                    return _buildDeviceCard(context, ref, device);
                  }, childCount: devices.length),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(child: Text('${l10n.error}: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDeviceDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addDevice),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, WidgetRef ref, Device device) {
    final liveStatusAsync = ref.watch(deviceStatusProvider(device.ipAddress));
    final liveStatus = liveStatusAsync.value;
    final isPowerOn =
        liveStatus?.isPowerOn ?? (device.powerState?.contains('ON') ?? false);
    final rssi = liveStatus?.rssi ?? device.rssi;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isPowerOn
              ? [
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ]
              : [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isPowerOn
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
          width: 1.5,
        ),
        boxShadow: [
          if (isPowerOn)
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/site/$siteId/device', extra: device),
          onLongPress: () => _confirmDeleteDevice(context, ref, device.id!),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusIcon(context, isPowerOn),
                    if (rssi != null) _buildWifiBadge(rssi),
                  ],
                ),
                const Spacer(),
                Text(
                  device.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  device.ipAddress,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isPowerOn ? 'ON' : 'OFF',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        color: isPowerOn
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: isPowerOn,
                        onChanged: (val) {
                          ref
                              .read(deviceControlControllerProvider)
                              .togglePower(device.ipAddress);
                        },
                        activeThumbColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, bool isOn) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isOn
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isOn ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
        size: 20,
        color: isOn ? Theme.of(context).colorScheme.primary : Colors.grey,
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
