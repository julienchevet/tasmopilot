import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tasmopilot/l10n/generated/app_localizations.dart';
import 'models/device.dart';
import 'providers/device_control_providers.dart';
import 'providers/device_providers.dart';

class DeviceControlScreen extends ConsumerWidget {
  final Device device;

  const DeviceControlScreen({super.key, required this.device});

  Future<void> _launchWebInterface(
    BuildContext context,
    String ipAddress,
  ) async {
    final url = Uri.parse('http://$ipAddress');
    try {
      // Try launching in external browser first
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // Fallback to platform default if external fails
        await launchUrl(url);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Copier IP',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: ipAddress));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('IP copiée !'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDevice =
        ref.watch(
          deviceProvider((siteId: device.siteId, deviceId: device.id!)),
        ) ??
        device;
    final statusAsyncValue = ref.watch(
      deviceStatusProvider(currentDevice.ipAddress),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(currentDevice.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Ouvrir l\'interface Web',
            onPressed: () =>
                _launchWebInterface(context, currentDevice.ipAddress),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Power Controls Section ---
            _buildPowerSection(context, ref, currentDevice, statusAsyncValue),

            const SizedBox(height: 24),

            // --- Live Info (WiFi / MQTT) ---
            _buildLiveDetails(context, statusAsyncValue.value),

            const SizedBox(height: 16),

            // --- System Information Card ---
            if (_hasSystemInfo(currentDevice))
              _buildSystemCard(context, currentDevice),

            const SizedBox(height: 16),

            // --- Network Information Card ---
            _buildNetworkCard(context, currentDevice, statusAsyncValue),

            const SizedBox(height: 16),

            // --- Raw Data Expansion ---
            if (statusAsyncValue.hasValue)
              _buildRawDataSection(context, statusAsyncValue.value!),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  bool _hasSystemInfo(Device dev) =>
      dev.module != null || dev.version != null || dev.uptime != null;

  Widget _buildPowerSection(
    BuildContext context,
    WidgetRef ref,
    Device device,
    AsyncValue<DeviceLiveStatus> statusAsyncValue,
  ) {
    final l10n = AppLocalizations.of(context)!;
    // If we have multiple relays (friendlyNames), we show a list
    final List<String> friendlyNames = [
      if (device.friendlyName1 != null) device.friendlyName1!,
      if (device.friendlyName2 != null) device.friendlyName2!,
    ];

    if (friendlyNames.length > 1) {
      final List<String> powerStates = device.powerState?.split(',') ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'CONTRÔLES',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: Colors.grey),
            ),
          ),
          Card(
            child: Column(
              children: List.generate(friendlyNames.length, (index) {
                final isOn = powerStates.length > index
                    ? powerStates[index] == 'ON'
                    : false;
                return ListTile(
                  leading: Icon(
                    Icons.power_settings_new,
                    color: isOn ? Colors.green : Colors.grey,
                  ),
                  title: Text(friendlyNames[index]),
                  trailing: Switch(
                    value: isOn,
                    onChanged: (value) {
                      // We need to implement toggle for specific relay
                      ref
                          .read(deviceControlControllerProvider)
                          .togglePower(device.ipAddress, relayIndex: index + 1);
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      );
    }

    // Default single relay big button
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 16),
          statusAsyncValue.when(
            data: (status) =>
                _buildPowerButton(context, ref, device, status.isPowerOn),
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) =>
                _buildErrorState(context, ref, device, error),
          ),
          const SizedBox(height: 16),
          if (statusAsyncValue.hasValue)
            Text(
              statusAsyncValue.value?.isPowerOn == true
                  ? l10n.powerOn
                  : l10n.powerOff,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusAsyncValue.value?.isPowerOn == true
                    ? Colors.green
                    : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSystemCard(BuildContext context, Device device) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'SYSTÈME',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.grey),
          ),
        ),
        Card(
          child: Column(
            children: [
              if (device.module != null)
                ListTile(
                  leading: const Icon(Icons.memory),
                  title: Text(l10n.module),
                  trailing: Text(
                    device.module!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              if (device.version != null)
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.version),
                  trailing: Text(
                    device.version!,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              if (device.uptime != null)
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: Text(l10n.uptime),
                  trailing: Text(device.uptime!),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkCard(
    BuildContext context,
    Device device,
    AsyncValue<DeviceLiveStatus> statusAsyncValue,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final liveRssi = statusAsyncValue.value?.rssi;
    final rssi = liveRssi ?? device.rssi;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.network.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.grey),
          ),
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.settings_ethernet),
                title: Text(l10n.ipAddress),
                trailing: Text(device.ipAddress),
              ),
              if (device.macAddress != null)
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: Text(l10n.macAddress),
                  trailing: Text(device.macAddress!),
                ),
              if (device.topic != null)
                ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: Text(l10n.mqttTopic),
                  trailing: Text(device.topic!),
                ),
              if (rssi != null)
                ListTile(
                  leading: _buildWifiIcon(rssi),
                  title: Text(l10n.wifiSignal),
                  trailing: Text('$rssi%'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWifiIcon(int rssi) {
    if (rssi > 75) return const Icon(Icons.wifi, color: Colors.green);
    if (rssi > 50) return const Icon(Icons.wifi_2_bar, color: Colors.orange);
    return const Icon(Icons.wifi_1_bar, color: Colors.red);
  }

  Widget _buildPowerButton(
    BuildContext context,
    WidgetRef ref,
    Device device,
    bool isOn,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        ref
            .read(deviceControlControllerProvider)
            .togglePower(device.ipAddress)
            .catchError((e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.errorDeviceUnreachable)),
                );
              }
            });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOn ? Colors.green : Colors.grey[800],
          boxShadow: [
            BoxShadow(
              color: (isOn ? Colors.green : Colors.black).withAlpha(128),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.power_settings_new,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLiveDetails(BuildContext context, DeviceLiveStatus? status) {
    final l10n = AppLocalizations.of(context)!;
    final wifi = status?.rawData['StatusSTS']?['Wifi'];
    final mqtt = status?.rawData['StatusMQT'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.liveDetails,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.grey),
          ),
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.wifi_tethering),
                title: Text(l10n.wifiSsid),
                trailing: Text(
                  wifi?['SSID'] ?? l10n.loading,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: wifi?['SSID'] == null ? Colors.grey : null,
                  ),
                ),
                subtitle: wifi != null
                    ? Text(
                        '${l10n.channel}: ${wifi['Channel']} • BSSID: ${wifi['BSSId']}',
                      )
                    : Text(l10n.searchingSignal),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.cloud_queue),
                title: Text(l10n.mqttBroker),
                trailing: Text(
                  mqtt?['Host'] ?? l10n.loading,
                  style: TextStyle(
                    color: mqtt?['Host'] == null ? Colors.grey : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: mqtt != null
                    ? Text('${l10n.client}: ${mqtt['Id']}')
                    : Text(l10n.verifyingConnection),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRawDataSection(BuildContext context, DeviceLiveStatus status) {
    final l10n = AppLocalizations.of(context)!;
    return ExpansionTile(
      title: Text(l10n.rawData),
      leading: const Icon(Icons.code),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            JsonEncoder.withIndent('  ').convert(status.rawData),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.greenAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    Device device,
    Object error,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(l10n.deviceUnreachable),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                ref.invalidate(deviceStatusProvider(device.ipAddress)),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
