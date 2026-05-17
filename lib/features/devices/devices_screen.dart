import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../discovery/discovery_dialog.dart';
import '../mqtt/providers/mqtt_providers.dart';
import '../mqtt/mqtt_discovery_dialog.dart';
import 'providers/device_control_providers.dart';
import '../../core/mqtt/mqtt_service.dart';
import '../sites/providers/site_providers.dart';
import '../sites/models/site.dart';
import 'providers/device_providers.dart';
import 'models/device.dart';
import 'package:tasmopilot/l10n/generated/app_localizations.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  // ── MQTT helpers ──────────────────────────────────────────────────────────

  Color _mqttColor(TasmotaMqttStatus s, bool dark) => switch (s) {
    TasmotaMqttStatus.connected =>
      dark ? const Color(0xFF00E676) : const Color(0xFF16A34A),
    TasmotaMqttStatus.connecting =>
      dark ? Colors.orangeAccent : const Color(0xFFD97706),
    TasmotaMqttStatus.error =>
      dark ? Colors.redAccent : const Color(0xFFDC2626),
    TasmotaMqttStatus.disconnected =>
      dark ? Colors.grey : const Color(0xFF64748B),
  };

  Widget _mqttBadge(
    BuildContext context,
    int siteId,
    TasmotaMqttStatus status,
    bool dark,
  ) {
    final color = _mqttColor(status, dark);
    final label = switch (status) {
      TasmotaMqttStatus.connected => 'MQTT ●',
      TasmotaMqttStatus.connecting => 'MQTT ◌',
      TasmotaMqttStatus.error => 'MQTT ✕',
      TasmotaMqttStatus.disconnected => 'MQTT ○',
    };
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => MqttDiscoveryDialog(siteId: siteId),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(
            alpha:
                status == TasmotaMqttStatus.connected ||
                    status == TasmotaMqttStatus.connecting
                ? 0.15
                : 0.08,
          ),
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

  // ── Site picker ───────────────────────────────────────────────────────────

  void _showAddSiteDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final hostCtrl = TextEditingController();
    final portCtrl = TextEditingController(text: '1883');
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool showMqtt = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: Text(l10n.addSite),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: l10n.name,
                      hintText: 'ex: Maison, Bureau…',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: Text(l10n.configureMqtt),
                    value: showMqtt,
                    onChanged: (v) => setState(() => showMqtt = v ?? false),
                  ),
                  if (showMqtt) ...[
                    const Divider(),
                    TextField(
                      controller: hostCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.mqttHost,
                        hintText: '192.168.1.x',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: portCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.mqttPort,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: userCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.mqttUser,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.mqttPass,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  ref
                      .read(sitesProvider.notifier)
                      .addSite(
                        Site(
                          name: name,
                          createdAt: DateTime.now(),
                          mqttHost: showMqtt ? hostCtrl.text.trim() : null,
                          mqttPort: showMqtt
                              ? int.tryParse(portCtrl.text.trim())
                              : null,
                          mqttUsername: showMqtt ? userCtrl.text.trim() : null,
                          mqttPassword: showMqtt ? passCtrl.text.trim() : null,
                        ),
                      );
                  Navigator.of(ctx).pop();
                },
                child: Text(l10n.add),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditSiteDialog(BuildContext context, WidgetRef ref, Site site) {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: site.name);
    final hostCtrl = TextEditingController(text: site.mqttHost ?? '');
    final portCtrl = TextEditingController(
      text: (site.mqttPort ?? 1883).toString(),
    );
    final userCtrl = TextEditingController(text: site.mqttUsername ?? '');
    final passCtrl = TextEditingController(text: site.mqttPassword ?? '');
    bool showMqtt = site.mqttHost != null && site.mqttHost!.isNotEmpty;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: Text(l10n.editSite),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: l10n.name,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: Text(l10n.configureMqtt),
                    value: showMqtt,
                    onChanged: (v) => setState(() => showMqtt = v ?? false),
                  ),
                  if (showMqtt) ...[
                    const Divider(),
                    TextField(
                      controller: hostCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.mqttHost,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: portCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.mqttPort,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: userCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.mqttUser,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.mqttPass,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  ref
                      .read(sitesProvider.notifier)
                      .updateSite(
                        site.copyWith(
                          name: name,
                          mqttHost: showMqtt ? hostCtrl.text.trim() : null,
                          mqttPort: showMqtt
                              ? int.tryParse(portCtrl.text.trim())
                              : null,
                          mqttUsername: showMqtt ? userCtrl.text.trim() : null,
                          mqttPassword: showMqtt ? passCtrl.text.trim() : null,
                        ),
                      );
                  Navigator.of(ctx).pop();
                },
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteSite(
    BuildContext context,
    WidgetRef ref,
    Site site,
    int? selectedId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteSite),
        content: Text(l10n.deleteSiteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(sitesProvider.notifier).deleteSite(site.id!);
              if (selectedId == site.id) {
                ref.read(selectedSiteIdProvider.notifier).select(null);
              }
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  // ── Site picker widget (title area) ───────────────────────────────────────

  Widget _buildSitePicker(
    BuildContext context,
    WidgetRef ref,
    List<Site> sites,
    int? selectedId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final selected = sites.where((s) => s.id == selectedId).firstOrNull;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selected?.name ?? l10n.sites,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 22,
            color: isDark ? Colors.white70 : const Color(0xFF64748B),
          ),
        ],
      ),
      itemBuilder: (ctx) => [
        // ── existing sites ──
        ...sites.map((site) {
          final isActive = site.id == selectedId;
          return PopupMenuItem<String>(
            value: 'select_${site.id}',
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? primary : Colors.transparent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    site.name,
                    style: TextStyle(
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _showEditSiteDialog(context, ref, site);
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _confirmDeleteSite(context, ref, site, selectedId);
                  },
                ),
              ],
            ),
          );
        }),
        // ── divider + add ──
        if (sites.isNotEmpty) const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'add',
          child: Row(
            children: [
              Icon(Icons.add_circle_outline_rounded, color: primary, size: 20),
              const SizedBox(width: 10),
              Text(
                l10n.addSite,
                style: TextStyle(color: primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'add') {
          _showAddSiteDialog(context, ref);
        } else if (value.startsWith('select_')) {
          final id = int.parse(value.substring(7));
          ref.read(selectedSiteIdProvider.notifier).select(id);
        }
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sitesAsync = ref.watch(sitesProvider);
    final selectedId = ref.watch(selectedSiteIdProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return sitesAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('${l10n.error}: $e'))),
      data: (sites) {
        // Auto-select first site if none selected
        if (selectedId == null && sites.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedSiteIdProvider.notifier).select(sites.first.id);
          });
        }

        final effectiveId =
            selectedId ?? (sites.isNotEmpty ? sites.first.id : null);
        final hasMqtt =
            effectiveId != null &&
            sites
                .where((s) => s.id == effectiveId)
                .any((s) => s.mqttHost != null && s.mqttHost!.isNotEmpty);

        final mqttStatus = effectiveId != null
            ? (ref.watch(mqttStatusProvider(effectiveId)).value ??
                  TasmotaMqttStatus.disconnected)
            : TasmotaMqttStatus.disconnected;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: _buildSitePicker(context, ref, sites, effectiveId),
                actions: [
                  if (hasMqtt)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Center(
                        child: _mqttBadge(
                          context,
                          effectiveId,
                          mqttStatus,
                          isDark,
                        ),
                      ),
                    ),
                  if (effectiveId != null)
                    IconButton(
                      icon: const Icon(Icons.radar_rounded),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => DiscoveryDialog(siteId: effectiveId),
                      ),
                    ),
                ],
              ),
              if (effectiveId == null)
                SliverFillRemaining(child: _buildNoSiteState(context, ref))
              else
                _buildDeviceList(context, ref, effectiveId),
            ],
          ),
          floatingActionButton: effectiveId == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () =>
                      _showAddDeviceDialog(context, ref, effectiveId),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.addDevice),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
        );
      },
    );
  }

  // ── Empty / no-site state ─────────────────────────────────────────────────

  Widget _buildNoSiteState(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 72,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          Text(l10n.noSites, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            l10n.addSite,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () => _showAddSiteDialog(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.addSite),
          ),
        ],
      ),
    );
  }

  // ── Device list ───────────────────────────────────────────────────────────

  Widget _buildDeviceList(BuildContext context, WidgetRef ref, int siteId) {
    final l10n = AppLocalizations.of(context)!;
    final devicesAsync = ref.watch(devicesProvider(siteId));
    return devicesAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) =>
          SliverFillRemaining(child: Center(child: Text('${l10n.error}: $e'))),
      data: (devices) {
        if (devices.isEmpty) {
          return SliverFillRemaining(child: _buildEmptyDevices(context));
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
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _buildDeviceCard(context, ref, devices[i], siteId),
              childCount: devices.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyDevices(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(l10n.noDevices, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  // ── Device card ───────────────────────────────────────────────────────────

  Widget _buildDeviceCard(
    BuildContext context,
    WidgetRef ref,
    Device device,
    int siteId,
  ) {
    final liveAsync = ref.watch(deviceStatusProvider(device.ipAddress));
    final live = liveAsync.value;
    final isPowerOn =
        live?.isPowerOn ?? (device.powerState?.contains('ON') ?? false);
    final rssi = live?.rssi ?? device.rssi;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isPowerOn
              ? [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.1),
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
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          if (isPowerOn)
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/device', extra: device),
          onLongPress: () =>
              _confirmDeleteDevice(context, ref, device.id!, siteId),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statusIcon(context, isPowerOn),
                    if (rssi != null) _wifiBadge(rssi),
                  ],
                ),
                const Spacer(),
                Text(
                  device.module ?? device.name,
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
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
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
                              ).colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: isPowerOn,
                        onChanged: (_) => ref
                            .read(deviceControlControllerProvider)
                            .togglePower(device.ipAddress),
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

  Widget _statusIcon(BuildContext context, bool isOn) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: isOn
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      isOn ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
      size: 20,
      color: isOn ? Theme.of(context).colorScheme.primary : Colors.grey,
    ),
  );

  Widget _wifiBadge(int rssi) {
    final color = rssi > 75
        ? Colors.green
        : rssi > 50
        ? Colors.orange
        : Colors.red;
    final icon = rssi > 75
        ? Icons.wifi
        : rssi > 50
        ? Icons.wifi_2_bar
        : Icons.wifi_1_bar;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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

  // ── Dialogs ───────────────────────────────────────────────────────────────

  Future<void> _showAddDeviceDialog(
    BuildContext context,
    WidgetRef ref,
    int siteId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final ipCtrl = TextEditingController();
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addDevice),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.name,
                hintText: 'ex: Lampe Salon',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ipCtrl,
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final ip = ipCtrl.text.trim();
              if (name.isNotEmpty && ip.isNotEmpty) {
                ref
                    .read(deviceControllerProvider)
                    .addDevice(siteId: siteId, name: name, ipAddress: ip);
                Navigator.of(ctx).pop();
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteDevice(
    BuildContext context,
    WidgetRef ref,
    int deviceId,
    int siteId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteDevice),
        content: Text(l10n.deleteDeviceConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(deviceControllerProvider).deleteDevice(siteId, deviceId);
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
