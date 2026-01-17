import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/utils/date_utils.dart';
import '../models/settings.dart';
import '../models/day_record.dart';
import '../models/business_trip.dart';
import 'storage_interface.dart';

class SqliteStorage implements StorageInterface {
  static final SqliteStorage instance = SqliteStorage._();
  SqliteStorage._();

  Database? _database;

  @override
  Future<void> initialize() async {
    if (_database != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'salary_tracker.db');

    _database = await openDatabase(
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

    await db.execute('CREATE INDEX idx_day_records_date ON day_records(date)');

    await db.insert('settings', {
      'id': 1,
      'monthly_salary': 0,
      'notifications_enabled': 1,
      'notify_days_before': 2,
    });
  }

  Database get _db {
    if (_database == null) throw Exception('Database not initialized');
    return _database!;
  }

  @override
  Future<Settings> getSettings() async {
    final maps = await _db.query('settings', where: 'id = ?', whereArgs: [1]);
    if (maps.isEmpty) return Settings.empty();
    return Settings.fromMap(maps.first);
  }

  @override
  Future<void> updateSettings(Settings settings) async {
    await _db.update('settings', settings.copyWith(id: 1).toMap(),
        where: 'id = ?', whereArgs: [1]);
  }

  @override
  Future<void> updateSalary(double salary) async {
    await _db.update('settings', {'monthly_salary': salary},
        where: 'id = ?', whereArgs: [1]);
  }

  @override
  Future<List<DayRecord>> getDayRecordsByMonth(int year, int month) async {
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 0).toIso8601String();

    final maps = await _db.query(
      'day_records',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC',
    );
    return maps.map((m) => DayRecord.fromMap(m)).toList();
  }

  @override
  Future<DayRecord?> getDayRecordByDate(DateTime date) async {
    final dateStr = AppDateUtils.dateOnly(date).toIso8601String();
    final maps = await _db.query('day_records',
        where: 'date = ?', whereArgs: [dateStr]);
    if (maps.isEmpty) return null;
    return DayRecord.fromMap(maps.first);
  }

  @override
  Future<void> upsertDayRecord(DayRecord record) async {
    final dateStr = AppDateUtils.dateOnly(record.date).toIso8601String();
    final existing = await _db.query('day_records',
        where: 'date = ?', whereArgs: [dateStr]);

    final data = record.toMap()..remove('id');
    if (existing.isEmpty) {
      await _db.insert('day_records', data);
    } else {
      await _db.update('day_records', data,
          where: 'date = ?', whereArgs: [dateStr]);
    }
  }

  @override
  Future<void> deleteDayRecord(DateTime date) async {
    final dateStr = AppDateUtils.dateOnly(date).toIso8601String();
    await _db.delete('day_records', where: 'date = ?', whereArgs: [dateStr]);
  }

  @override
  Future<void> deleteDayRecordsByTripId(int tripId) async {
    await _db.delete('day_records',
        where: 'business_trip_id = ?', whereArgs: [tripId]);
  }

  @override
  Future<List<BusinessTrip>> getBusinessTripsByMonth(int year, int month) async {
    final startOfMonth = DateTime(year, month, 1).toIso8601String();
    final endOfMonth = DateTime(year, month + 1, 0).toIso8601String();

    final maps = await _db.query(
      'business_trips',
      where: '(start_date <= ? AND end_date >= ?) OR '
          '(start_date >= ? AND start_date <= ?) OR '
          '(end_date >= ? AND end_date <= ?)',
      whereArgs: [
        endOfMonth, startOfMonth,
        startOfMonth, endOfMonth,
        startOfMonth, endOfMonth,
      ],
      orderBy: 'start_date ASC',
    );
    return maps.map((m) => BusinessTrip.fromMap(m)).toList();
  }

  @override
  Future<BusinessTrip?> getBusinessTripById(int id) async {
    final maps = await _db.query('business_trips',
        where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return BusinessTrip.fromMap(maps.first);
  }

  @override
  Future<int> insertBusinessTrip(BusinessTrip trip) async {
    return await _db.insert('business_trips', trip.toMap()..remove('id'));
  }

  @override
  Future<void> deleteBusinessTrip(int id) async {
    await _db.delete('business_trips', where: 'id = ?', whereArgs: [id]);
  }
}
