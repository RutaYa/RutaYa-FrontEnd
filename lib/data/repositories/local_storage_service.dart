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
    String dbPath = join(path, 'rutaya.db');

    print("Database path: $path");

    // 🔥 Usamos una versión alta para forzar siempre onUpgrade
    return await openDatabase(
      dbPath,
      version: 100, // Versión alta para forzar upgrade
      onCreate: (db, version) async {
        print("Creating database tables...");
        await _createAllTables(db);
        print("Database tables created successfully.");
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print("Upgrading database from version $oldVersion to $newVersion");
        print("Auto-detecting and creating missing tables...");

        // 🔥 Siempre verificar y crear tablas faltantes
        await _ensureAllTablesExist(db);

        print("Database upgrade completed.");
      },
      onOpen: (db) async {
        print("Database opened. Checking tables...");
        var tables = await db.query('sqlite_master', columns: ['name']);
        print("Existing tables: ${tables.map((t) => t['name']).toList()}");

        // 🔥 Verificación adicional: crear tablas faltantes si no existen
        await _ensureAllTablesExist(db);
      },
    );
  }

  // 🔥 Método para crear todas las tablas (usado en onCreate)
  Future<void> _createAllTables(Database db) async {
    await db.execute('''        
      CREATE TABLE IF NOT EXISTS UserCredentials(
        id INTEGER PRIMARY KEY,
        email TEXT,
        password TEXT,
        rememberMe INTEGER
      )
    ''');

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

    // 🔥 Agregar índices para mejor rendimiento
    await _createIndexes(db);
  }

  // 🔥 Crear índices para optimizar consultas
  Future<void> _createIndexes(Database db) async {
    try {
      await db.execute('CREATE INDEX IF NOT EXISTS idx_user_email ON User(email)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON Messages(timestamp)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id ON UserPreferences(user_id)');
      print("✅ Database indexes created successfully");
    } catch (e) {
      print("⚠️ Error creating indexes: $e");
    }
  }

  // 🔥 Método para asegurar que todas las tablas y columnas existan
  Future<void> _ensureAllTablesExist(Database db) async {
    // Obtener lista de tablas existentes
    var tables = await db.query('sqlite_master',
        columns: ['name'],
        where: 'type = ?',
        whereArgs: ['table']);

    List<String> existingTables = tables.map((t) => t['name'] as String).toList();
    print("Existing tables: $existingTables");

    // 🔥 Definir TODAS las tablas que debe tener la app
    Map<String, String> requiredTables = {
      'UserCredentials': '''        
        CREATE TABLE IF NOT EXISTS UserCredentials(
          id INTEGER PRIMARY KEY,
          email TEXT,
          password TEXT,
          rememberMe INTEGER
        )
      ''',
      'User': ''' 
        CREATE TABLE IF NOT EXISTS User(
          id TEXT PRIMARY KEY, 
          first_name TEXT,
          last_name TEXT,
          email TEXT,
          phone TEXT
        )
      ''',
      'Messages': '''
        CREATE TABLE IF NOT EXISTS Messages (
          id INTEGER PRIMARY KEY,
          message TEXT,
          isBot INTEGER,
          timestamp TEXT
        )
      ''',
      'UserPreferences': '''
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
      '''
      // 🔥 Agregar aquí cualquier nueva tabla que necesites en el futuro
      // 'TravelPlans': '''CREATE TABLE IF NOT EXISTS TravelPlans(...)'''
      // 'Favorites': '''CREATE TABLE IF NOT EXISTS Favorites(...)'''
    };

    // 🔥 Crear todas las tablas que falten
    int tablesCreated = 0;
    for (String tableName in requiredTables.keys) {
      if (!existingTables.contains(tableName)) {
        print("🔥 Creating missing table: $tableName");
        await db.execute(requiredTables[tableName]!);
        tablesCreated++;
      } else {
        print("✅ Table $tableName already exists");
      }
    }

    if (tablesCreated > 0) {
      print("✅ Created $tablesCreated missing tables successfully");
    } else {
      print("✅ All required tables already exist");
    }

    // 🔥 Verificar y agregar columnas faltantes en tablas existentes
    await _ensureAllColumnsExist(db);

    // 🔥 Crear índices si no existen
    await _createIndexes(db);
  }

  // 🔥 Método para verificar y agregar columnas faltantes
  Future<void> _ensureAllColumnsExist(Database db) async {
    print("Checking for missing columns...");

    // 🔥 Definir estructura completa de cada tabla con sus columnas
    Map<String, Map<String, String>> tableColumns = {
      'User': {
        'phone': 'TEXT',
        // Agregar aquí futuras columnas para User
        // 'avatar_url': 'TEXT',
        // 'country': 'TEXT',
        // 'city': 'TEXT',
      },
      'Messages': {
        // Agregar aquí futuras columnas para Messages
        // 'message_type': 'TEXT DEFAULT "text"',
        // 'attachment_url': 'TEXT',
        // 'is_read': 'INTEGER DEFAULT 0',
      },
      'UserPreferences': {
        // Agregar aquí futuras columnas para UserPreferences
        // 'language': 'TEXT DEFAULT "es"',
        // 'currency': 'TEXT DEFAULT "USD"',
        // 'notification_preferences': 'TEXT',
      }
    };

    // 🔥 Verificar columnas para cada tabla
    for (String tableName in tableColumns.keys) {
      if (await _tableExists(db, tableName)) {
        for (String columnName in tableColumns[tableName]!.keys) {
          await _ensureColumnExists(
              db,
              tableName,
              columnName,
              tableColumns[tableName]![columnName]!
          );
        }
      }
    }

    print("Column verification completed");
  }

  // 🔥 Método para verificar si una columna existe y crearla si no existe
  Future<void> _ensureColumnExists(Database db, String tableName, String columnName, String columnDefinition) async {
    try {
      // Intentar hacer una consulta que use la columna
      await db.query(tableName, columns: [columnName], limit: 1);
      print("✅ Column $tableName.$columnName already exists");
    } catch (e) {
      // Si falla, la columna no existe, la creamos
      if (e.toString().contains('no such column') || e.toString().contains('no column named')) {
        print("🔥 Adding missing column: $tableName.$columnName");
        try {
          await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnDefinition');
          print("✅ Column $tableName.$columnName added successfully");
        } catch (alterError) {
          print("❌ Error adding column $tableName.$columnName: $alterError");
        }
      } else {
        print("❌ Unexpected error checking column $tableName.$columnName: $e");
      }
    }
  }

  // 🔥 Método para verificar si una tabla existe
  Future<bool> _tableExists(Database db, String tableName) async {
    var result = await db.query(
      'sqlite_master',
      where: 'type = ? AND name = ?',
      whereArgs: ['table', tableName],
    );
    return result.isNotEmpty;
  }

  // 🔥 Método para obtener información de esquema de una tabla
  Future<List<Map<String, dynamic>>> getTableSchema(String tableName) async {
    final db = await database;
    try {
      return await db.rawQuery('PRAGMA table_info($tableName)');
    } catch (e) {
      print("Error getting schema for table $tableName: $e");
      return [];
    }
  }

  // 🔥 Método para verificar integridad de la base de datos
  Future<bool> checkDatabaseIntegrity() async {
    final db = await database;
    try {
      var result = await db.rawQuery('PRAGMA integrity_check');
      bool isIntegrityOk = result.first['integrity_check'] == 'ok';
      print("Database integrity check: ${isIntegrityOk ? 'OK' : 'FAILED'}");
      return isIntegrityOk;
    } catch (e) {
      print("Error checking database integrity: $e");
      return false;
    }
  }

  // 🔥 Método para forzar recreación de la base de datos (solo para desarrollo)
  Future<void> recreateDatabase() async {
    await deleteDatabaseFile();
    _database = null;
    await database; // Esto iniciará la recreación
  }

  Future<void> deleteDatabaseFile() async {
    final path = join(await getDatabasesPath(), 'rutaya.db');
    await deleteDatabase(path);
    print("Database deleted");
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

  // === MÉTODOS EXISTENTES (conservados) ===

  Future<void> saveCredentials(String email, String password, bool rememberMe) async {
    final db = await database;
    await db.delete('UserCredentials');
    await db.insert('UserCredentials', {
      'email': email,
      'password': password,
      'rememberMe': rememberMe ? 1 : 0,
    });
  }

  Future<void> clearCredentials() async {
    final db = await database;
    await db.delete('UserCredentials');
  }

  Future<Map<String, dynamic>?> getCredentials() async {
    final db = await database;
    var results = await db.query('UserCredentials',
        where: 'rememberMe = ?', whereArgs: [1], limit: 1);
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
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
      conflictAlgorithm: ConflictAlgorithm.replace,
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