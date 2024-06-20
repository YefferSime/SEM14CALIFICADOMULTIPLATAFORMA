import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class EstudianteDatabase {
  static final EstudianteDatabase instance = EstudianteDatabase._internal();
  static Database? _database;

  EstudianteDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!; 

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'estudiantes.db'); 

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase, 
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE estudiantes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        carrera TEXT NOT NULL,
        fechaIngreso TEXT NOT NULL,
        edad INTEGER NOT NULL
      )
    ''');
  }


  Future<int> create(Map<String, dynamic> estudiante) async {
    final db = await instance.database;
    return await db.insert('estudiantes', estudiante);
  }

  Future<Map<String, dynamic>?> read(int id) async {
    final db = await instance.database;
    final maps = await db.query('estudiantes', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    final db = await instance.database;
    return await db.query('estudiantes');
  }

  Future<int> update(int id, Map<String, dynamic> estudiante) async {
    final db = await instance.database;
    return await db.update('estudiantes', estudiante, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('estudiantes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  static String dateTimeToString(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  static DateTime stringToDateTime(String date) {
    return DateTime.parse(date);
  }
}