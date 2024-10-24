import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'fishes.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE fishes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            color INTEGER,
            top REAL,
            left REAL,
            speed REAL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db
              .execute('ALTER TABLE fishes ADD COLUMN speed REAL DEFAULT 1.0');
        }
      },
    );
  }

  Future<void> insertFish(FishData fish) async {
    final db = await database;

    await db.insert('fishes', {
      'color': fish.color,
      'top': fish.top,
      'left': fish.left,
      'speed': fish.speed,
    });
  }

  Future<void> deleteAllFishes() async {
    final db = await database;
    await db.delete('fishes');
  }

  Future<List<FishData>> getAllFishes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('fishes');

    return List.generate(maps.length, (i) {
      return FishData(
        color: maps[i]['color'],
        top: maps[i]['top'],
        left: maps[i]['left'],
        speed: maps[i]['speed'],
      );
    });
  }
}

class FishData {
  final int color;
  final double top;
  final double left;
  final double speed;

  FishData({
    required this.color,
    required this.top,
    required this.left,
    required this.speed,
  });
}
