import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'food_model.dart';
import 'package:path/path.dart';

class FoodDatabase {
  static final FoodDatabase _instance = FoodDatabase._internal();

  factory FoodDatabase() => _instance;

  FoodDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'food_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE food (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            calories REAL,
            imagePath TEXT,
            date TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertFood(FoodModel food) async {
    final db = await database;

    return await db.insert(
      'food',
      {
        'name': food.name,
        'calories': food.calories,
        'imagePath': food.imagePath,
        'date': food.date.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FoodModel>> getAllFoods() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query('food');

    return result.map((item) {
      return FoodModel(
        name: item['name'],
        calories: item['calories'],
        imagePath: item['imagePath'],
        date: DateTime.parse(item['date']),
      );
    }).toList();
  }

  Future<List<FoodModel>> getFoodOnDate(DateTime date) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db
        .query('food', where: 'date = ?', whereArgs: [date.toIso8601String()]);

    return result.map((item) {
      return FoodModel(
        name: item['name'],
        calories: item['calories'],
        imagePath: item['imagePath'],
        date: DateTime.parse(item['date']),
      );
    }).toList();
  }

  Future<void> updateFood(FoodModel food, int id) async {
    final db = await database;

    await db.update(
      'food',
      {
        'name': food.name,
        'calories': food.calories,
        'imagePath': food.imagePath,
        'date': food.date.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteFood(String name, DateTime date) async {
    final db = await database;
    String d = date.toIso8601String();

    var result = await db.query(
      'food',
      where: 'name = ? AND date = ?',
      whereArgs: [name, d],
      limit: 1,
    );

    if (result.isNotEmpty) {
      await db.delete(
        'food',
        where: 'name = ? AND date = ?',
        whereArgs: [name, d],
      );
    }
  }

  Future<void> deleteAllFoods() async {
    final db = await database;

    await db.delete('food');
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
