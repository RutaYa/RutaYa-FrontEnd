import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/message.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    print("Database path: $path");

    return await openDatabase(
      join(path, 'rutaya.db'),
      version: 1,
      onCreate: (db, version) async {
        print("Creating database tables...");

        await db.execute('''
          CREATE TABLE IF NOT EXISTS Messages (
            id INTEGER PRIMARY KEY,
            message TEXT,
            isBot INTEGER,
            timestamp TEXT
          )
        ''');

        print("Database tables created successfully.");
      },
      onOpen: (db) async {
        print("Database opened. Checking tables...");
        var tables = await db.query('sqlite_master', columns: ['name']);
        print("Existing tables: ${tables.map((t) => t['name']).toList()}");
      },
    );
  }

  Future<void> deleteDatabaseFile() async {
    final path = join(await getDatabasesPath(), 'rutaya.db');
    await deleteDatabase(path);
    print("");
  }

  Future<void> clearAllTables() async {
    final db = await database;

    // Lista de tablas a limpiar
    final List<String> tables = ['Messages'];

    for (final table in tables) {
      await db.delete(table);
      print("Tabla $table vaciada.");
    }

    print("Todas las tablas han sido vaciadas.");
  }

  // Inserta un solo mensaje
  Future<void> insertMessage(Message message) async {
    final db = await database;
    await db.insert(
      'Messages',
      message.toDbJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtiene todos los mensajes ordenados por timestamp ascendente
  Future<List<Message>> getAllMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Messages',
      orderBy: 'timestamp ASC',
    );
    return maps.map((json) => Message.fromDb(json)).toList();
  }
}