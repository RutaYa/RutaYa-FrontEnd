import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_preferences.dart';


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
    //await deleteDatabase(join(path, 'rutaya.db'));
    print("Database path: $path");

    return await openDatabase(
      join(path, 'rutaya.db'),
      version: 1,
      onCreate: (db, version) async {
        print("Creating database tables...");

        await db.execute(''' 
          CREATE TABLE IF NOT EXISTS User(
            id TEXT PRIMARY KEY, 
            first_name TEXT,
            last_name TEXT,
            email TEXT,
            phone TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS Messages (
            id INTEGER PRIMARY KEY,
            message TEXT,
            isBot INTEGER,
            timestamp TEXT
          )
        ''');

        // Nueva tabla para UserPreferences
        await db.execute('''
        CREATE TABLE IF NOT EXISTS UserPreferences (
          user_id TEXT PRIMARY KEY,
          birth_date TEXT,
          gender TEXT,
          travel_interests TEXT,
          preferred_environment TEXT,
          travel_style TEXT,
          budget_range TEXT,
          adrenaline_level INTEGER,
          wants_hidden_places INTEGER
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

  Future saveUser(User user) async {
    final db = await database;

    // Limpiar la tabla antes de insertar un nuevo usuario
    await db.delete('User');

    // Insertar el nuevo usuario
    await db.insert(
      'User',
      {
        'id': user.id,
        'first_name': user.firstName,
        'last_name': user.lastName,
        'email': user.email,
        'phone': user.phone,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Reemplaza el registro si ya existe
    );
  }

  Future<User?> getCurrentUser() async {
    final db = await database;
    var results = await db.query('User', limit: 1);

    if (results.isNotEmpty) {
      return User(
        id: results.first['id'] as String,
        firstName: results.first['first_name'] as String,
        lastName: results.first['last_name'] as String,
        email: results.first['email'] as String,
        phone: results.first['phone'] as String,
      );
    }
    return null;
  }

  Future<int> getCurrentUserId() async {
    final db = await database;
    var results = await db.query('User', limit: 1);

    if (results.isNotEmpty) {
      var userId = results.first['id'];
      if (userId is int) {
        return userId;
      } else if (userId is String) {
        int parsedUserId = int.tryParse(userId) ?? 0;
        return parsedUserId;
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }


  Future<void> clearUser() async {
    final db = await database;
    await db.delete('User');
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

  // Método para guardar las preferencias del usuario
  Future saveUserPreferences(UserPreferences preferences) async {
    final db = await database;

    // Limpiar la tabla antes de insertar nuevas preferencias
    await db.delete('UserPreferences');

    // Insertar las nuevas preferencias
    await db.insert(
      'UserPreferences',
      preferences.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<UserPreferences?> getCurrentUserPreferences() async {
    print('🔍 Iniciando lectura de preferencias desde la base de datos local...');

    final db = await database;

    print('📥 Ejecutando query sobre tabla UserPreferences...');
    var results = await db.query('UserPreferences', limit: 1);

    print('📊 Resultados obtenidos: ${results.length}');
    if (results.isNotEmpty) {
      print('✅ Preferencias encontradas: ${results.first}');
      return UserPreferences.fromDatabase(results.first);
    }

    print('⚠️ No se encontraron preferencias guardadas.');
    return null;
  }

  Future deleteUserPreferences() async {
    final db = await database;
    await db.delete('UserPreferences');
  }
}