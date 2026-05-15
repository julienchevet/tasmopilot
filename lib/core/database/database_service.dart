import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static const String _databaseName = "tasmopilot.db";
  static const int _databaseVersion = 6; // Added full Tasmota parameters

  // Singleton pattern
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create Sites table
    await db.execute('''
      CREATE TABLE sites(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        mqtt_host TEXT,
        mqtt_port INTEGER,
        mqtt_username TEXT,
        mqtt_password TEXT,
        mqtt_topic_prefix TEXT
      )
    ''');
    
    // Create Devices table
    await _createDevicesTable(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createDevicesTable(db);
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE sites ADD COLUMN mqtt_host TEXT');
      await db.execute('ALTER TABLE sites ADD COLUMN mqtt_port INTEGER');
      await db.execute('ALTER TABLE sites ADD COLUMN mqtt_username TEXT');
      await db.execute('ALTER TABLE sites ADD COLUMN mqtt_password TEXT');
      await db.execute('ALTER TABLE sites ADD COLUMN mqtt_topic_prefix TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('CREATE UNIQUE INDEX idx_devices_mac ON devices(mac_address)');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE devices ADD COLUMN module TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN version TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN topic TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN friendly_name1 TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN friendly_name2 TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN rssi INTEGER');
      await db.execute('ALTER TABLE devices ADD COLUMN uptime TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN power_state TEXT');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE devices ADD COLUMN full_topic TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN mqtt_host TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN mqtt_port INTEGER');
      await db.execute('ALTER TABLE devices ADD COLUMN mqtt_user TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN mqtt_password TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN mqtt_client_id TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN web_password TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN ssid1 TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN wifi_password1 TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN ssid2 TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN wifi_password2 TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN hostname TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN group_topic TEXT');
    }
  }

  Future _createDevicesTable(Database db) async {
    await db.execute('''
      CREATE TABLE devices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        site_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        ip_address TEXT NOT NULL,
        mac_address TEXT,
        created_at TEXT NOT NULL,
        module TEXT,
        version TEXT,
        topic TEXT,
        friendly_name1 TEXT,
        friendly_name2 TEXT,
        rssi INTEGER,
        uptime TEXT,
        power_state TEXT,
        full_topic TEXT,
        mqtt_host TEXT,
        mqtt_port INTEGER,
        mqtt_user TEXT,
        mqtt_password TEXT,
        mqtt_client_id TEXT,
        web_password TEXT,
        ssid1 TEXT,
        wifi_password1 TEXT,
        ssid2 TEXT,
        wifi_password2 TEXT,
        hostname TEXT,
        group_topic TEXT,
        UNIQUE(mac_address),
        FOREIGN KEY (site_id) REFERENCES sites (id) ON DELETE CASCADE
      )
    ''');
  }
}
