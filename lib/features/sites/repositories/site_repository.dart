import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_service.dart';
import '../models/site.dart';

class SiteRepository {
  final DatabaseService _dbService;

  SiteRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<Site> createSite(Site site) async {
    final db = await _dbService.database;
    final id = await db.insert(
      'sites',
      site.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return site.copyWith(id: id);
  }

  Future<List<Site>> getSites() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sites',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) {
      return Site.fromMap(maps[i]);
    });
  }

  Future<void> updateSite(Site site) async {
    final db = await _dbService.database;
    await db.update(
      'sites',
      site.toMap(),
      where: 'id = ?',
      whereArgs: [site.id],
    );
  }

  Future<void> deleteSite(int id) async {
    final db = await _dbService.database;
    await db.delete(
      'sites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
