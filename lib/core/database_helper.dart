import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reading_progress.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE progress (
        id TEXT PRIMARY KEY,
        scroll_percentage REAL NOT NULL,
        last_read_timestamp INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id TEXT NOT NULL,
        quote TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        color_hex TEXT DEFAULT '#C49A53'
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          item_id TEXT NOT NULL,
          quote TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          color_hex TEXT DEFAULT '#C49A53'
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE notes ADD COLUMN color_hex TEXT DEFAULT "#C49A53"');
    }
  }

  Future<void> saveProgress(String id, double percentage) async {
    final db = await instance.database;
    await db.insert(
      'progress',
      {
        'id': id,
        'scroll_percentage': percentage,
        'last_read_timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<double?> getProgress(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'progress',
      columns: ['scroll_percentage'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first['scroll_percentage'] as double;
    }
    return 0.0;
  }

  Future<Map<String, dynamic>?> getMostRecentProgress() async {
    final db = await instance.database;
    final maps = await db.query(
      'progress',
      columns: ['id', 'scroll_percentage', 'last_read_timestamp'],
      orderBy: 'last_read_timestamp DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return maps.first;
  }

  // --- Notes Methods ---

  Future<int> insertNote(String itemId, String quote, String colorHex) async {
    final db = await instance.database;
    return await db.insert(
      'notes',
      {
        'item_id': itemId,
        'quote': quote,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'color_hex': colorHex,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getNotesForItem(String itemId) async {
    final db = await instance.database;
    return await db.query(
      'notes',
      where: 'item_id = ?',
      whereArgs: [itemId],
      orderBy: 'timestamp DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    final db = await instance.database;
    return await db.query(
      'notes',
      orderBy: 'timestamp DESC',
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
