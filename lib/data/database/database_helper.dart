import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper_stub.dart' if (dart.library.html) 'database_helper_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static Future<void> initializePlatform() async {
    if (kIsWeb) {
      await initWebDatabase();
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('salary_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;
    if (kIsWeb) {
      path = inMemoryDatabasePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        monthly_salary REAL NOT NULL,
        notifications_enabled INTEGER DEFAULT 1,
        notify_days_before INTEGER DEFAULT 2
      )
    ''');

    await db.execute('''
      CREATE TABLE business_trips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        destination TEXT,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE day_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        type INTEGER NOT NULL,
        bonus REAL DEFAULT 0,
        business_trip_id INTEGER,
        FOREIGN KEY (business_trip_id) REFERENCES business_trips(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_day_records_date ON day_records(date)
    ''');

    await db.insert('settings', {
      'id': 1,
      'monthly_salary': 0,
      'notifications_enabled': 1,
      'notify_days_before': 2,
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
    _database = null;
  }
}
