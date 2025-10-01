import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sihaki/data_komisi_model.dart';

class DataKomisiDatabaseHelper {
  static final DataKomisiDatabaseHelper _instance = DataKomisiDatabaseHelper._internal();
  factory DataKomisiDatabaseHelper() => _instance;
  DataKomisiDatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'data_komisi.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE data_komisi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        module_name TEXT NOT NULL UNIQUE,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT,
        user_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        metadata TEXT
      )
    ''');

    // Insert default modules
    final now = DateTime.now().toIso8601String();
    final modules = [
      'data_keanggotaan',
      'data_kendaraan', 
      'data_pribadi',
      'data_penerbangan',
      'data_kesehatan',
      'data_kontak',
      'data_tata_naskah',
      'data_feedback_komisi',
    ];

    for (String module in modules) {
      await db.insert('data_komisi', {
        'module_name': module,
        'is_completed': 0,
        'completed_at': null,
        'user_id': 'current_user',
        'created_at': now,
        'updated_at': now,
        'metadata': null,
      });
    }

    print('Database Helper DEBUG: ✅ Created data_komisi table with ${modules.length} default modules');
  }

  // Insert new data komisi
  Future<int> insertDataKomisi(DataKomisiModel dataKomisi) async {
    final db = await database;
    final map = dataKomisi.toMap();
    
    print('Database Helper DEBUG: 💾 Inserting data komisi with map:');
    print('  - Map content: $map');
    
    final id = await db.insert('data_komisi', map);
    
    print('Database Helper DEBUG: ✅ Inserted with ID: $id');
    
    return id;
  }

  // Get all data komisi
  Future<List<DataKomisiModel>> getAllDataKomisi({
    String? orderBy = 'created_at ASC',
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'data_komisi',
      orderBy: orderBy,
    );

    return List.generate(maps.length, (i) {
      return DataKomisiModel.fromMap(maps[i]);
    });
  }

  // Get data komisi by ID
  Future<DataKomisiModel?> getDataKomisiById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'data_komisi',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DataKomisiModel.fromMap(maps.first);
    }
    return null;
  }

  // Get data komisi by module name
  Future<DataKomisiModel?> getDataKomisiByModuleName(String moduleName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'data_komisi',
      where: 'module_name = ?',
      whereArgs: [moduleName],
    );

    if (maps.isNotEmpty) {
      return DataKomisiModel.fromMap(maps.first);
    }
    return null;
  }

  // Get data komisi by user ID
  Future<List<DataKomisiModel>> getDataKomisiByUserId(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'data_komisi',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );

    return List.generate(maps.length, (i) {
      return DataKomisiModel.fromMap(maps[i]);
    });
  }

  // Update data komisi
  Future<int> updateDataKomisi(DataKomisiModel dataKomisi) async {
    final db = await database;
    final map = dataKomisi.toMap();
    
    print('Database Helper DEBUG: 📝 Updating data komisi with map:');
    print('  - Map content: $map');
    
    final result = await db.update(
      'data_komisi',
      map,
      where: 'id = ?',
      whereArgs: [dataKomisi.id],
    );
    
    print('Database Helper DEBUG: ✅ Updated ${result} row(s)');
    
    return result;
  }

  // Update module completion status
  Future<int> updateModuleCompletionStatus(String moduleName, bool isCompleted, {String? userId}) async {
    final db = await database;
    
    final updateData = {
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    if (userId != null) {
      updateData['user_id'] = userId;
    }
    
    print('Database Helper DEBUG: 🔄 Updating module $moduleName completion to $isCompleted');
    
    final result = await db.update(
      'data_komisi',
      updateData,
      where: 'module_name = ?',
      whereArgs: [moduleName],
    );
    
    print('Database Helper DEBUG: ✅ Updated ${result} row(s) for module $moduleName');
    
    return result;
  }

  // Delete data komisi
  Future<int> deleteDataKomisi(int id) async {
    final db = await database;
    return await db.delete(
      'data_komisi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get completion statistics
  Future<Map<String, dynamic>> getCompletionStatistics({String? userId}) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (userId != null) {
      whereClause = 'WHERE user_id = ?';
      whereArgs = [userId];
    }
    
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM data_komisi $whereClause', whereArgs);
    final total = totalResult.first['count'] as int;
    
    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM data_komisi $whereClause${whereClause.isNotEmpty ? ' AND' : 'WHERE'} is_completed = 1',
      whereArgs
    );
    final completed = completedResult.first['count'] as int;

    return {
      'total': total,
      'completed': completed,
      'remaining': total - completed,
      'completion_percentage': total > 0 ? (completed / total * 100).round() : 0,
    };
  }

  // Reset all modules for a user
  Future<int> resetAllModules({String? userId}) async {
    final db = await database;
    
    final updateData = {
      'is_completed': 0,
      'completed_at': null,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (userId != null) {
      whereClause = 'user_id = ?';
      whereArgs = [userId];
    }
    
    final result = await db.update(
      'data_komisi',
      updateData,
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );
    
    print('Database Helper DEBUG: 🔄 Reset ${result} modules');
    
    return result;
  }

  // Get modules by completion status
  Future<List<DataKomisiModel>> getModulesByStatus(bool isCompleted, {String? userId}) async {
    final db = await database;
    
    String whereClause = 'is_completed = ?';
    List<dynamic> whereArgs = [isCompleted ? 1 : 0];
    
    if (userId != null) {
      whereClause += ' AND user_id = ?';
      whereArgs.add(userId);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'data_komisi',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at ASC',
    );

    return List.generate(maps.length, (i) {
      return DataKomisiModel.fromMap(maps[i]);
    });
  }

  // Close database
  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}
