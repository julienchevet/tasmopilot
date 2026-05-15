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

final initialRedirectionProvider = NotifierProvider<InitialRedirectionNotifier, bool>(
  InitialRedirectionNotifier.new,
);


class SitesScreen extends ConsumerWidget {
  const SitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sitesAsyncValue = ref.watch(sitesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.appTitle} - ${l10n.sites}'),
      ),
      body: sitesAsyncValue.when(
        data: (sites) {
          if (sites.isEmpty) {
            return _buildEmptyState(context);
          }

          // If only one site, go directly to it on startup
          final hasRedirected = ref.watch(initialRedirectionProvider);
          if (sites.length == 1 && !hasRedirected) {
            final site = sites.first;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                ref.read(initialRedirectionProvider.notifier).setRedirected();
                context.go('/site/${site.id}?name=${Uri.encodeComponent(site.name)}');
              }
            });
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sites.length,
            itemBuilder: (context, index) {
              final site = sites[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.home),
                  ),
                  title: Text(
                    site.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Créé le ${site.createdAt.toLocal().toString().split('.')[0]}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                        onPressed: () => _showEditSiteDialog(context, ref, site),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                        onPressed: () => _confirmDeleteSite(context, ref, site.id!),
                      ),
                    ],
                  ),
                  onTap: () {
                    context.go('/site/${site.id}?name=${Uri.encodeComponent(site.name)}');
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('${l10n.error}: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSiteDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.addSite),
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
          Text(
            l10n.noSites,
            style: Theme.of(context).textTheme.titleLarge,
          ),
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
                      onChanged: (val) => setState(() => showMqtt = val ?? false),
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
                        mqttHost: showMqtt ? mqttHostController.text.trim() : null,
                        mqttPort: showMqtt ? int.tryParse(mqttPortController.text.trim()) : null,
                        mqttUsername: showMqtt ? mqttUserController.text.trim() : null,
                        mqttPassword: showMqtt ? mqttPassController.text.trim() : null,
                        mqttTopicPrefix: showMqtt ? mqttPrefixController.text.trim() : null,
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

  Future<void> _confirmDeleteSite(BuildContext context, WidgetRef ref, int siteId) async {
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
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditSiteDialog(BuildContext context, WidgetRef ref, Site site) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: site.name);
    final mqttHostController = TextEditingController(text: site.mqttHost ?? '');
    final mqttPortController = TextEditingController(text: (site.mqttPort ?? 1883).toString());
    final mqttUserController = TextEditingController(text: site.mqttUsername ?? '');
    final mqttPassController = TextEditingController(text: site.mqttPassword ?? '');
    final mqttPrefixController = TextEditingController(text: site.mqttTopicPrefix ?? 'tasmota');
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
                      onChanged: (val) => setState(() => showMqtt = val ?? false),
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
                        mqttHost: showMqtt ? mqttHostController.text.trim() : null,
                        mqttPort: showMqtt ? int.tryParse(mqttPortController.text.trim()) : null,
                        mqttUsername: showMqtt ? mqttUserController.text.trim() : null,
                        mqttPassword: showMqtt ? mqttPassController.text.trim() : null,
                        mqttTopicPrefix: showMqtt ? mqttPrefixController.text.trim() : null,
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
