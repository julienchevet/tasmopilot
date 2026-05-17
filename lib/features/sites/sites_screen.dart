import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/site_providers.dart';
import 'models/site.dart';
import 'package:tasmopilot/l10n/generated/app_localizations.dart';

class InitialRedirectionNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setRedirected() => state = true;
}

final initialRedirectionProvider =
    NotifierProvider<InitialRedirectionNotifier, bool>(
      InitialRedirectionNotifier.new,
    );

class SitesScreen extends ConsumerWidget {
  const SitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sitesAsyncValue = ref.watch(sitesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: Text(l10n.sites), expandedHeight: 120),
          sitesAsyncValue.when(
            data: (sites) {
              if (sites.isEmpty) {
                return SliverFillRemaining(child: _buildEmptyState(context));
              }

              return SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final site = sites[index];
                    return _buildSiteCard(context, ref, site);
                  }, childCount: sites.length),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Text(
                  '${l10n.error}: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSiteDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.addSite),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSiteCard(BuildContext context, WidgetRef ref, Site site) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Theme.of(
              context,
            ).colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
            Theme.of(
              context,
            ).colorScheme.secondary.withOpacity(isDark ? 0.1 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: () {
          context.go('/site/${site.id}?name=${Uri.encodeComponent(site.name)}');
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.home_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      site.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Site ID: ${site.id}',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditSiteDialog(context, ref, site);
                  } else if (value == 'delete') {
                    _confirmDeleteSite(context, ref, site.id!);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_rounded, size: 20),
                        const SizedBox(width: 12),
                        Text(l10n.editSite),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.delete,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.home_work_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.noSites, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            l10n.noSites, // Fallback for description or similar
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSiteDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final mqttHostController = TextEditingController();
    final mqttPortController = TextEditingController(text: '1883');
    final mqttUserController = TextEditingController();
    final mqttPassController = TextEditingController();
    final mqttPrefixController = TextEditingController(text: 'tasmota');
    bool showMqtt = false;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.addSite),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: l10n.name,
                        hintText: 'ex: Maison, Bureau...',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: Text(l10n.configureMqtt),
                      value: showMqtt,
                      onChanged: (val) =>
                          setState(() => showMqtt = val ?? false),
                    ),
                    if (showMqtt) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      TextField(
                        controller: mqttHostController,
                        decoration: InputDecoration(
                          labelText: l10n.mqttHost,
                          hintText: 'ex: 192.168.1.50',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: mqttPortController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.mqttPort,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: mqttUserController,
                        decoration: InputDecoration(
                          labelText: l10n.mqttUser,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: mqttPassController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: l10n.mqttPass,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: mqttPrefixController,
                        decoration: InputDecoration(
                          labelText: l10n.mqttPrefix,
                          hintText: 'tasmota',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      final newSite = Site(
                        name: name,
                        createdAt: DateTime.now(),
                        mqttHost: showMqtt
                            ? mqttHostController.text.trim()
                            : null,
                        mqttPort: showMqtt
                            ? int.tryParse(mqttPortController.text.trim())
                            : null,
                        mqttUsername: showMqtt
                            ? mqttUserController.text.trim()
                            : null,
                        mqttPassword: showMqtt
                            ? mqttPassController.text.trim()
                            : null,
                        mqttTopicPrefix: showMqtt
                            ? mqttPrefixController.text.trim()
                            : null,
                      );
                      ref.read(sitesProvider.notifier).addSite(newSite);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(l10n.add),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteSite(
    BuildContext context,
    WidgetRef ref,
    int siteId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteSite),
          content: Text(l10n.deleteSiteConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                ref.read(sitesProvider.notifier).deleteSite(siteId);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditSiteDialog(
    BuildContext context,
    WidgetRef ref,
    Site site,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: site.name);
    final mqttHostController = TextEditingController(text: site.mqttHost ?? '');
    final mqttPortController = TextEditingController(
      text: (site.mqttPort ?? 1883).toString(),
    );
    final mqttUserController = TextEditingController(
      text: site.mqttUsername ?? '',
    );
    final mqttPassController = TextEditingController(
      text: site.mqttPassword ?? '',
    );
    final mqttPrefixController = TextEditingController(
      text: site.mqttTopicPrefix ?? 'tasmota',
    );
    bool showMqtt = site.mqttHost != null;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.editSite),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: l10n.name,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: Text(l10n.configureMqtt),
                      value: showMqtt,
                      onChanged: (val) =>
                          setState(() => showMqtt = val ?? false),
                    ),
                    if (showMqtt) ...[
                      const Divider(),
                      TextField(
                        controller: mqttHostController,
                        decoration: InputDecoration(
                          labelText: l10n.mqttHost,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: mqttPortController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.mqttPort,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: mqttUserController,
                        decoration: InputDecoration(
                          labelText: l10n.mqttUser,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: mqttPassController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: l10n.mqttPass,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: mqttPrefixController,
                        decoration: InputDecoration(
                          labelText: l10n.mqttPrefix,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    final newName = nameController.text.trim();
                    if (newName.isNotEmpty) {
                      final updatedSite = site.copyWith(
                        name: newName,
                        mqttHost: showMqtt
                            ? mqttHostController.text.trim()
                            : null,
                        mqttPort: showMqtt
                            ? int.tryParse(mqttPortController.text.trim())
                            : null,
                        mqttUsername: showMqtt
                            ? mqttUserController.text.trim()
                            : null,
                        mqttPassword: showMqtt
                            ? mqttPassController.text.trim()
                            : null,
                        mqttTopicPrefix: showMqtt
                            ? mqttPrefixController.text.trim()
                            : null,
                      );
                      ref.read(sitesProvider.notifier).updateSite(updatedSite);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
