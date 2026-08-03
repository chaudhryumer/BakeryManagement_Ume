import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../BatchTracking/BatchModelClass.dart';

class DatabaseHelper {
  // 1. Private internal constructor for singleton pattern
  DatabaseHelper._init();

  // 2. The single static instance shared across the app
  static final DatabaseHelper instance = DatabaseHelper._init();

  // 3. Made nullable with '?' because it initializes lazily on first access
  static Database? _database;

  // ── OPTIONAL WEB MEMORY SIMULATION LAYER ──
  // This allows you to test adding and viewing products directly inside Edge/Chrome!
  static final List<BatchModelClass> _webMemoryStorage = [];

  // Getter to securely fetch or open the SQLite instance
  Future<Database?> get database async {
    // Web protection guard to prevent browser layout lockouts
    if (kIsWeb) {
      print("🌐 Running on Web: Bypassing native SQLite engine safely.");
      return null;
    }

    if (_database != null) return _database!;

    _database = await _initDB('bakery_inventory.db');
    return _database;
  }

  // Initializing the database location on disk
  // FIX: Explicitly made this method return a nullable Database? to align with getters
  Future<Database?> _initDB(String filePath) async {
    if (kIsWeb) return null;
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(path, version: 1, onCreate: _createDB);
    } catch (e) {
      print("⚠️ Local Device storage init error: $e");
      return null;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE batches (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        quantity TEXT NOT NULL,
        price REAL NOT NULL,
        manufactureDate TEXT NOT NULL,
        expiryDate TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  // --- DATABASE OPERATIONS ---

  Future<int> insertBatch(BatchModelClass batch) async {
    if (kIsWeb) {
      // Simulation: Save to temporary browser memory so UI stays alive on Web
      _webMemoryStorage.insert(0, batch);
      print(
        "🌐 [Web Storage Sim]: Intercepted and cached '${batch.name}' in browser runtime memory map.",
      );
      return 1;
    }

    final db = await instance.database;
    if (db == null) return 0;
    return await db.insert('batches', batch.toMap());
  }

  // Add this inside your DatabaseHelper class
  Future<int> deleteBatch(String id) async {
    final db = await instance
        .database; // Use whatever your local database getter is named (e.g., 'database' or 'getDb()')

    return await db!.delete(
      'batches', // 👈 Make sure this matches your exact SQLite table name
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<BatchModelClass>> fetchAllBatches() async {
    if (kIsWeb) {
      // Simulation: Load mock data on Web browser layout configurations
      print(
        "🌐 [Web Storage Sim]: Loading ${_webMemoryStorage.length} items from browser cache memory map.",
      );
      return List.from(_webMemoryStorage);
    }

    final db = await instance.database;
    if (db == null) return [];

    final result = await db.query('batches', orderBy: 'id DESC');
    return result.map((json) => BatchModelClass.fromMap(json)).toList();
  }

  Future<void> debugPrintAllBatches() async {
    if (kIsWeb) {
      print("═══ 🌐 WEB STORAGE SIMULATION DUMP ═══");
      print("Total Items Found: ${_webMemoryStorage.length}");
      for (var item in _webMemoryStorage) {
        print(
          "🆔 ID: ${item.id} | 📦 Name: ${item.name} | 💰 Price: ${item.price}",
        );
      }
      print("══════════════════════════════════════");
      return;
    }

    final db = await DatabaseHelper.instance.database;
    if (db == null) return;

    // Query all rows from the batches table
    final List<Map<String, dynamic>> maps = await db.query('batches');

    print("═══ SQLITE DATABASE DUMP ═══");
    print("Total Rows Found: ${maps.length}");

    for (var row in maps) {
      print(
        "🆔 ID: ${row['id']} | 📦 Name: ${row['name']} | 💰 Price: ${row['price']}",
      );
    }
    print("════════════════════════════");
  }
}
