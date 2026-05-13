import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_service.dart';
import '../models/device.dart';

class DeviceRepository {
  final DatabaseService _dbService;

  DeviceRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<Device> createDevice(Device device) async {
    final db = await _dbService.database;
    final id = await db.insert(
      'devices',
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return device.copyWith(id: id);
  }

  Future<List<Device>> getDevicesForSite(int siteId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'devices',
      where: 'site_id = ?',
      whereArgs: [siteId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) {
      return Device.fromMap(maps[i]);
    });
  }

  Future<void> updateDevice(Device device) async {
    final db = await _dbService.database;
    await db.update(
      'devices',
      device.toMap(),
      where: 'id = ?',
      whereArgs: [device.id],
    );
  }

  Future<void> deleteDevice(int id) async {
    final db = await _dbService.database;
    await db.delete(
      'devices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
