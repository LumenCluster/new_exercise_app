import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/profile/domain/entities/user_profile.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_profile.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');
    await _createCacheTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createCacheTable(db);
    }
  }

  Future<void> _createCacheTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cache (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  /// Generic string cache, used to remember AI-generated content (e.g. a
  /// day's meal/workout plan) so it isn't regenerated more than once per day.
  Future<void> setCacheValue(String key, String value) async {
    final db = await database;
    await db.insert(
      'cache',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getCacheValue(String key) async {
    final db = await database;
    final maps = await db.query('cache', where: 'key = ?', whereArgs: [key], limit: 1);
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  Future<void> saveProfile(UserProfile profile) async {
    print("DatabaseHelper: Attempting to save profile...");
    final db = await database;
    try {
      await db.insert(
        'profile',
        {'data': jsonEncode(profile.toJson())},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("DatabaseHelper: Profile saved successfully: ${profile.name}");
    } catch (e) {
      print("DatabaseHelper ERROR: $e");
      rethrow;
    }
  }

  Future<UserProfile?> getProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('profile', limit: 1, orderBy: 'id DESC');
    if (maps.isNotEmpty) {
      return UserProfile.fromJson(jsonDecode(maps.first['data']));
    }
    return null;
  }
}
