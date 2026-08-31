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
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');
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
