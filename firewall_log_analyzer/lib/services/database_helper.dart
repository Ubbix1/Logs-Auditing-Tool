import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/firewall_log.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'firewall_logs.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE logs(id INTEGER PRIMARY KEY, ipAddress TEXT, timestamp TEXT, method TEXT, requestMethod TEXT, status TEXT, bytes TEXT, userAgent TEXT, parameters TEXT, url TEXT, responseCode INTEGER, responseSize INTEGER)',
        );
      },
    );
  }

  Future<void> insertLog(FirewallLog log) async {
    final db = await database;
    await db.insert(
      'logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FirewallLog>> getLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('logs');
    return List.generate(maps.length, (i) {
      return FirewallLog.fromMap(maps[i]);
    });
  }

  Future<void> deleteLog(int id) async {
    final db = await database;
    await db.delete(
      'logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
