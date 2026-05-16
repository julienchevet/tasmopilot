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
    final l10n = AppLocalizations.of(context)!;
    final currentDevice =
        ref.watch(
          deviceProvider((siteId: device.siteId, deviceId: device.id!)),
        ) ??
        device;
    final statusAsyncValue = ref.watch(
      deviceStatusProvider(currentDevice.ipAddress),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(currentDevice.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded),
            tooltip: 'Web UI',
            onPressed: () => _launchWebInterface(context, currentDevice.ipAddress),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 70, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPowerSection(context, ref, currentDevice, statusAsyncValue),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'SYSTÈME'),
              if (_hasSystemInfo(currentDevice))
                _buildSystemCard(context, currentDevice),
              const SizedBox(height: 24),
              _buildSectionHeader(context, l10n.network),
              _buildNetworkCard(context, currentDevice, statusAsyncValue),
              const SizedBox(height: 24),
              if (statusAsyncValue.hasValue)
                _buildRawDataSection(context, statusAsyncValue.value!),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
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
    final List<String> friendlyNames = [
      if (device.friendlyName1 != null) device.friendlyName1!,
      if (device.friendlyName2 != null) device.friendlyName2!,
    ];

    if (friendlyNames.length > 1) {
      final List<String> powerStates = device.powerState?.split(',') ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'CONTRÔLES'),
          Card(
            child: Column(
              children: List.generate(friendlyNames.length, (index) {
                final isOn = powerStates.length > index ? powerStates[index] == 'ON' : false;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isOn ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.power_settings_new_rounded,
                      color: isOn ? Colors.green : Colors.grey,
                    ),
                  ),
                  title: Text(
                    friendlyNames[index],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Switch(
                    value: isOn,
                    onChanged: (value) {
                      ref.read(deviceControlControllerProvider).togglePower(device.ipAddress, relayIndex: index + 1);
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      );
    }

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 10),
          statusAsyncValue.when(
            data: (status) => _buildPowerButton(context, ref, device, status.isPowerOn),
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => _buildErrorState(context, ref, device, error),
          ),
          const SizedBox(height: 24),
          if (statusAsyncValue.hasValue)
            Text(
              statusAsyncValue.value?.isPowerOn == true ? l10n.powerOn : l10n.powerOff,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: statusAsyncValue.value?.isPowerOn == true ? Colors.green : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSystemCard(BuildContext context, Device device) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Column(
        children: [
          if (device.module != null)
            _buildControlTile(Icons.memory_rounded, l10n.module, device.module!),
          if (device.version != null)
            _buildControlTile(Icons.info_outline_rounded, l10n.version, device.version!, color: Colors.blue),
          if (device.uptime != null)
            _buildControlTile(Icons.timer_outlined, l10n.uptime, device.uptime!),
        ],
      ),
    );
  }

  Widget _buildControlTile(IconData icon, String title, String trailing, {Color? color}) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Text(
        trailing,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 14,
        ),
      ),
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
    final wifi = statusAsyncValue.value?.rawData['StatusSTS']?['Wifi'];
    final ssid = wifi?['SSID'] as String?;

    return Card(
      child: Column(
        children: [
          _buildControlTile(Icons.settings_ethernet_rounded, l10n.ipAddress, device.ipAddress),
          if (device.macAddress != null)
            _buildControlTile(Icons.fingerprint_rounded, l10n.macAddress, device.macAddress!),
          if (ssid != null) ...[
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.wifi_tethering_rounded, size: 22),
              title: Text(l10n.wifiSsid, style: const TextStyle(fontSize: 14)),
              trailing: Text(
                ssid,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: wifi['Channel'] != null
                  ? Text('${l10n.channel}: ${wifi['Channel']}', style: const TextStyle(fontSize: 12))
                  : null,
            ),
          ],
          if (rssi != null) ...[
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: _buildWifiIcon(rssi),
              title: Text(l10n.wifiSignal, style: const TextStyle(fontSize: 14)),
              trailing: Text('$rssi%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
          if (device.topic != null) ...[
            const Divider(height: 1, indent: 56),
            _buildControlTile(Icons.label_outline_rounded, l10n.mqttTopic, device.topic!),
          ],
        ],
      ),
    );
  }

  Widget _buildWifiIcon(int rssi) {
    if (rssi > 75) return const Icon(Icons.wifi_rounded, color: Colors.green, size: 22);
    if (rssi > 50) return const Icon(Icons.wifi_2_bar_rounded, color: Colors.orange, size: 22);
    return const Icon(Icons.wifi_1_bar_rounded, color: Colors.red, size: 22);
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
        ref.read(deviceControlControllerProvider).togglePower(device.ipAddress).catchError((e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorDeviceUnreachable)));
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: isOn 
                ? [Colors.green.shade400, Colors.green.shade700] 
                : [Colors.grey.shade700, Colors.grey.shade900],
          ),
          boxShadow: [
            BoxShadow(
              color: (isOn ? Colors.green : Colors.black).withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
            if (isOn)
              BoxShadow(
                color: Colors.green.withOpacity(0.5),
                blurRadius: 50,
                spreadRadius: -10,
              ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.power_settings_new_rounded,
          size: 80,
          color: isOn ? Colors.white : Colors.white24,
        ),
      ),
    );
  }

  Widget _buildRawDataSection(BuildContext context, DeviceLiveStatus status) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: Colors.black.withOpacity(0.3),
      child: ExpansionTile(
        title: Text(l10n.rawData, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        leading: const Icon(Icons.code_rounded),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: SelectableText(
              JsonEncoder.withIndent('  ').convert(status.rawData),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Colors.greenAccent,
              ),
            ),
          ),
        ],
      ),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.red),
          ),
          const SizedBox(height: 24),
          Text(l10n.deviceUnreachable, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => ref.invalidate(deviceStatusProvider(device.ipAddress)),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
