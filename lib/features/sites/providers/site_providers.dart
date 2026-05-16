import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/site.dart';
import '../repositories/site_repository.dart';

// Provider for the repository
final siteRepositoryProvider = Provider<SiteRepository>((ref) {
  return SiteRepository();
});

// AsyncNotifier for the list of sites
class SitesNotifier extends AsyncNotifier<List<Site>> {
  @override
  Future<List<Site>> build() async {
    return _fetchSites();
  }

  Future<List<Site>> _fetchSites() async {
    final repository = ref.read(siteRepositoryProvider);
    return repository.getSites();
  }

  Future<void> addSite(Site site) async {
    // Set state to loading while we add
    state = const AsyncValue.loading();
    
    // Add to DB
    final repository = ref.read(siteRepositoryProvider);
    await repository.createSite(site);
    
    // Refresh the list
    state = await AsyncValue.guard(_fetchSites);
  }

  Future<void> updateSite(Site site) async {
    state = const AsyncValue.loading();
    final repository = ref.read(siteRepositoryProvider);
    await repository.updateSite(site);
    state = await AsyncValue.guard(_fetchSites);
  }

  Future<void> deleteSite(int id) async {
    state = const AsyncValue.loading();
    final repository = ref.read(siteRepositoryProvider);
    await repository.deleteSite(id);
    state = await AsyncValue.guard(_fetchSites);
  }
}

// Provider for the sites list
final sitesProvider = AsyncNotifierProvider<SitesNotifier, List<Site>>(() {
  return SitesNotifier();
});

// Provider for the currently selected site ID (null = no site selected yet)
final selectedSiteIdProvider = StateProvider<int?>((ref) => null);
