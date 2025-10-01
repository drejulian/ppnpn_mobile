import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sihaki/feedback_komisi_model.dart';

class FeedbackKomisiDatabaseHelper {
  static final FeedbackKomisiDatabaseHelper _instance = FeedbackKomisiDatabaseHelper._internal();
  factory FeedbackKomisiDatabaseHelper() => _instance;
  FeedbackKomisiDatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    // Always check if database is open and valid
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    
    print('Database Helper DEBUG: 🔄 Reinitializing database connection');
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'feedback_komisi.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE feedback_komisi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topik TEXT NOT NULL,
        feedback TEXT NOT NULL,
        rating_kinerja TEXT NOT NULL,
        saran_perbaikan TEXT,
        user_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  // Insert new feedback komisi
  Future<int> insertFeedbackKomisi(FeedbackKomisiModel feedbackKomisi) async {
    final db = await database;
    final map = feedbackKomisi.toMap();
    
    print('Database Helper DEBUG: 💾 Inserting feedback with map:');
    print('  - Map content: $map');
    print('  - Rating in map: "${map['rating_kinerja']}"');
    
    final id = await db.insert('feedback_komisi', map);
    
    print('Database Helper DEBUG: ✅ Inserted with ID: $id');
    
    return id;
  }

  // Get all feedback komisi
  Future<List<FeedbackKomisiModel>> getAllFeedbackKomisi({
    String? orderBy = 'created_at DESC',
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'feedback_komisi',
      orderBy: orderBy,
    );

    return List.generate(maps.length, (i) {
      return FeedbackKomisiModel.fromMap(maps[i]);
    });
  }

  // Get feedback komisi by ID
  Future<FeedbackKomisiModel?> getFeedbackKomisiById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'feedback_komisi',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return FeedbackKomisiModel.fromMap(maps.first);
    }
    return null;
  }

  // Get feedback komisi by user ID
  Future<List<FeedbackKomisiModel>> getFeedbackKomisiByUserId(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'feedback_komisi',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    print('Database Helper DEBUG: 🔍 Retrieved ${maps.length} feedback(s) for user $userId');
    for (final map in maps) {
      print('  - ID ${map['id']}: rating_kinerja = "${map['rating_kinerja']}"');
    }

    final models = List.generate(maps.length, (i) {
      return FeedbackKomisiModel.fromMap(maps[i]);
    });

    print('Database Helper DEBUG: 📋 Converted to models:');
    for (final model in models) {
      print('  - ID ${model.id}: ratingKinerja = "${model.ratingKinerja}"');
    }

    return models;
  }

  // Update feedback komisi
  Future<int> updateFeedbackKomisi(FeedbackKomisiModel feedbackKomisi) async {
    final db = await database;
    final map = feedbackKomisi.toMap();
    
    print('Database Helper DEBUG: 🔄 Updating feedback ID ${feedbackKomisi.id} with map:');
    print('  - Map content: $map');
    print('  - Rating in map: "${map['rating_kinerja']}"');
    
    final result = await db.update(
      'feedback_komisi',
      map,
      where: 'id = ?',
      whereArgs: [feedbackKomisi.id],
    );
    
    print('Database Helper DEBUG: ✅ Update affected $result rows');
    
    return result;
  }

  // Delete feedback komisi
  Future<int> deleteFeedbackKomisi(int id) async {
    final db = await database;
    return await db.delete(
      'feedback_komisi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search feedback komisi by topik or feedback content
  Future<List<FeedbackKomisiModel>> searchFeedbackKomisi(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'feedback_komisi',
      where: 'topik LIKE ? OR feedback LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return FeedbackKomisiModel.fromMap(maps[i]);
    });
  }

  // Get feedback komisi count
  Future<int> getFeedbackKomisiCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM feedback_komisi');
    return result.first['count'] as int;
  }

  // Get feedback komisi by rating
  Future<List<FeedbackKomisiModel>> getFeedbackKomisiByRating(int rating) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'feedback_komisi',
      where: 'rating_kinerja LIKE ?',
      whereArgs: ['%($rating)%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return FeedbackKomisiModel.fromMap(maps[i]);
    });
  }

  // Get statistics
  Future<Map<String, dynamic>> getFeedbackStatistics() async {
    final db = await database;
    final total = await getFeedbackKomisiCount();
    
    final ratingCounts = <String, int>{};
    for (int i = 1; i <= 5; i++) {
      final count = await db.rawQuery(
        'SELECT COUNT(*) as count FROM feedback_komisi WHERE rating_kinerja LIKE ?',
        ['%($i)%']
      );
      ratingCounts['rating_$i'] = count.first['count'] as int;
    }

    return {
      'total': total,
      'rating_counts': ratingCounts,
    };
  }

  // Close database - dimodifikasi untuk mencegah premature closing
  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      print('Database Helper DEBUG: 🔒 Closing database connection');
      await db.close();
      _database = null;
    }
  }
  
  // Method untuk memastikan database tetap hidup
  Future<bool> isDatabaseOpen() async {
    return _database != null && _database!.isOpen;
  }
}