import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/site_providers.dart';

class SitesScreen extends ConsumerWidget {
  const SitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sitesAsyncValue = ref.watch(sitesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasmopilot - Sites'),
      ),
      body: sitesAsyncValue.when(
        data: (sites) {
          if (sites.isEmpty) {
            return _buildEmptyState(context);
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
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _showEditSiteDialog(context, ref, site),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
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
          child: Text('Erreur: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSiteDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un site'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.home_work_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Aucun site configuré',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajoutez un site pour commencer à gérer vos appareils Tasmota.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSiteDialog(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un site'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nom du site',
              hintText: 'ex: Maison, Bureau...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  ref.read(sitesProvider.notifier).addSite(name);
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

  Future<void> _confirmDeleteSite(BuildContext context, WidgetRef ref, int siteId) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le site ?'),
          content: const Text('Cette action est irréversible et supprimera tous les appareils associés (bientôt).'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                ref.read(sitesProvider.notifier).deleteSite(siteId);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
  }

  Future<void> _showEditSiteDialog(BuildContext context, WidgetRef ref, site) async {
    final TextEditingController controller = TextEditingController(text: site.name);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier le site'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nouveau nom',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty && newName != site.name) {
                  final updatedSite = site.copyWith(name: newName);
                  ref.read(sitesProvider.notifier).updateSite(updatedSite);
                  Navigator.of(context).pop();
                } else if (newName == site.name) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }
}
