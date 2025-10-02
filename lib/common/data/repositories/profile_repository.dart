import 'package:sqflite/sqflite.dart';
import '../database/app_database_helper.dart';
import '../models/profile_models.dart';

class ProfileRepository {
  static final ProfileRepository _instance = ProfileRepository._internal();
  factory ProfileRepository() => _instance;
  ProfileRepository._internal();

  final AppDatabaseHelper _dbHelper = AppDatabaseHelper();

  /// Get current user ID (in a real app, this would come from authentication)
  String getCurrentUserId() {
    // For now, using a default user ID
    // In a real app, this would come from authentication service
    return 'current_user';
  }

  // ========================================
  // DATABASE MIGRATION OPERATIONS
  // ========================================

  /// Migrate existing tables to fix structure issues
  Future<void> _migrateExistingTables(Database db) async {
    try {
      print('ProfileRepository: 🔄 Checking for table migrations...');
      
      // Check if pribadi_data table exists and has correct structure
      final List<Map<String, dynamic>> tableInfo = await db.rawQuery(
        "PRAGMA table_info(pribadi_data)"
      );
      
      if (tableInfo.isNotEmpty) {
        print('ProfileRepository: 📋 Found existing pribadi_data table');
        
        // Check if status_perkawinan column exists
        bool hasStatusPerkawinan = tableInfo.any((column) => 
          column['name'] == 'status_perkawinan'
        );
        
        if (!hasStatusPerkawinan) {
          print('ProfileRepository: ⚠️ Missing status_perkawinan column, recreating table...');
          
          // Backup existing data
          final List<Map<String, dynamic>> existingData = await db.query('pribadi_data');
          print('ProfileRepository: 💾 Backing up ${existingData.length} existing records');
          
          // Drop existing table
          await db.execute('DROP TABLE IF EXISTS pribadi_data');
          print('ProfileRepository: 🗑️ Dropped old pribadi_data table');
          
          // Create new table with correct structure
          await _createPribadiDataTable(db);
          print('ProfileRepository: ✅ Created new pribadi_data table with correct structure');
          
          // Restore data if any existed
          for (final record in existingData) {
            try {
              await db.insert('pribadi_data', {
                'user_id': record['user_id'] ?? 'current_user',
                'tempat_lahir': record['tempat_lahir'] ?? '',
                'tanggal_lahir': record['tanggal_lahir'] ?? '',
                'jenis_kelamin': record['jenis_kelamin'] ?? '',
                'agama': record['agama'] ?? '',
                'status_perkawinan': 'Kawin', // Default value for migrated records
                'golongan_darah': record['golongan_darah'] ?? '',
                'status_domisili': record['status_domisili'] ?? '',
                'address': record['address'] ?? '',
                'propinsi': record['propinsi'] ?? '',
                'kota': record['kota'] ?? '',
                'kecamatan': record['kecamatan'] ?? '',
                'kelurahan': record['kelurahan'] ?? '',
                'rt': record['rt'] ?? '',
                'rw': record['rw'] ?? '',
                'kode_pos': record['kode_pos'] ?? '',
                'telepon_rumah': record['telepon_rumah'] ?? '',
                'telepon_kantor': record['telepon_kantor'] ?? '',
                'handphone': record['handphone'] ?? '',
                'email': record['email'] ?? '',
                'created_at': record['created_at'] ?? DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              });
              print('ProfileRepository: ♻️ Restored record for user: ${record['user_id']}');
            } catch (e) {
              print('ProfileRepository: ⚠️ Failed to restore record: $e');
            }
          }
        } else {
          print('ProfileRepository: ✅ pribadi_data table structure is correct');
        }
      } else {
        print('ProfileRepository: 📝 No existing pribadi_data table found, will create new');
      }
      
      print('ProfileRepository: ✅ Migration check completed');
    } catch (e) {
      print('ProfileRepository: ❌ Migration error: $e');
    }
  }

  /// Create pribadi_data table with correct structure
  Future<void> _createPribadiDataTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pribadi_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        tempat_lahir TEXT DEFAULT '',
        tanggal_lahir TEXT DEFAULT '',
        jenis_kelamin TEXT DEFAULT '',
        agama TEXT DEFAULT '',
        status_perkawinan TEXT DEFAULT '',
        golongan_darah TEXT DEFAULT '',
        status_domisili TEXT DEFAULT '',
        address TEXT DEFAULT '',
        propinsi TEXT DEFAULT '',
        kota TEXT DEFAULT '',
        kecamatan TEXT DEFAULT '',
        kelurahan TEXT DEFAULT '',
        rt TEXT DEFAULT '',
        rw TEXT DEFAULT '',
        kode_pos TEXT DEFAULT '',
        telepon_rumah TEXT DEFAULT '',
        telepon_kantor TEXT DEFAULT '',
        handphone TEXT DEFAULT '',
        email TEXT DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id)
      )
    ''');
  }

  // ========================================
  // EDIT PROFILE OPERATIONS
  // ========================================

  /// Initialize database tables if needed
  Future<void> initializeProfileTables() async {
    final db = await _dbHelper.database;
    
    // Check if we need to migrate existing tables
    await _migrateExistingTables(db);
    
    // Create edit_profile table if not exists
    await db.execute('''
      CREATE TABLE IF NOT EXISTS edit_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        nik TEXT NOT NULL,
        nama TEXT NOT NULL,
        pendidikan TEXT NOT NULL,
        bidang_keahlian TEXT NOT NULL,
        toefl TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id)
      )
    ''');

    // Create pribadi_data table if not exists (migration handles structure fixes)
    await _createPribadiDataTable(db);

    // Create honorarium_data table if not exists
    await db.execute('''
      CREATE TABLE IF NOT EXISTS honorarium_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        kartu_keluarga TEXT DEFAULT '',
        ktp TEXT DEFAULT '',
        nama_ktp TEXT DEFAULT '',
        bpjs_kesehatan TEXT DEFAULT '',
        npwp TEXT DEFAULT '',
        nama_ibu TEXT DEFAULT '',
        rekening TEXT DEFAULT '',
        nama_pemilik_rek TEXT DEFAULT '',
        status_ptkp TEXT DEFAULT '',
        jumlah_anak TEXT DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id)
      )
    ''');

    // Create idcard_data table if not exists
    await db.execute('''
      CREATE TABLE IF NOT EXISTS idcard_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        foto_path TEXT DEFAULT '',
        is_uploaded INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id)
      )
    ''');

    // Create keluarga_data table if not exists
    await db.execute('''
      CREATE TABLE IF NOT EXISTS keluarga_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        nama_ayah TEXT DEFAULT '',
        nama_ibu TEXT DEFAULT '',
        nama_pasangan TEXT DEFAULT '',
        nama_anak TEXT DEFAULT '',
        pekerjaan_ayah TEXT DEFAULT '',
        pekerjaan_ibu TEXT DEFAULT '',
        pekerjaan_pasangan TEXT DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id)
      )
    ''');

    // Create pendidikan_data table with migration support
    print('ProfileRepository: 📅 About to call _createPendidikanDataTable...');
    await _createPendidikanDataTable(db);
    print('ProfileRepository: ✅ _createPendidikanDataTable completed');    

    print('ProfileRepository: Profile tables initialized');
  }

  /// Create and migrate pendidikan_data table
  Future<void> _createPendidikanDataTable(Database db) async {
    try {
      print('ProfileRepository: 🔄 Checking pendidikan_data table...');
      
      // Check if table exists
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'pendidikan_data'],
      );

      if (tables.isEmpty) {
        // Table doesn't exist, create it
        print('ProfileRepository: 🆕 Creating new pendidikan_data table...');
        await db.execute('''
          CREATE TABLE pendidikan_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            jenjang TEXT DEFAULT '',
            jurusan TEXT DEFAULT '',
            institusi TEXT DEFAULT '',
            kota TEXT DEFAULT '',
            tahun_mulai TEXT DEFAULT '',
            tahun_selesai TEXT DEFAULT '',
            ipk TEXT DEFAULT '',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        print('ProfileRepository: ✅ New pendidikan_data table created');
      } else {
        // Table exists, check if migration is needed
        print('ProfileRepository: 📋 Found existing pendidikan_data table');
        
        // Get current table structure
        final columns = await db.rawQuery('PRAGMA table_info(pendidikan_data)');
        final columnNames = columns.map((col) => col['name'] as String).toList();
        
        print('ProfileRepository: 📝 Current columns: $columnNames');
        
        // Check required columns
        final requiredColumns = [
          'jenjang', 'jurusan', 'institusi', 'kota', 
          'tahun_mulai', 'tahun_selesai', 'ipk'
        ];
        
        final missingColumns = requiredColumns.where((col) => !columnNames.contains(col)).toList();
        
        if (missingColumns.isNotEmpty) {
          print('ProfileRepository: 🔧 Adding missing columns: $missingColumns');
          
          for (final column in missingColumns) {
            await db.execute('ALTER TABLE pendidikan_data ADD COLUMN $column TEXT DEFAULT ""');
            print('ProfileRepository: ✅ Added column: $column');
          }
        } else {
          print('ProfileRepository: ✅ pendidikan_data table structure is correct');
        }
      }
    } catch (e) {
      print('ProfileRepository: ❌ Error in pendidikan_data table migration: $e');
      rethrow;
    }
  }

  /// Get edit profile data by user ID
  Future<EditProfileModel?> getEditProfile(String userId) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.query(
        'edit_profile',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return EditProfileModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('ProfileRepository: Error getting edit profile: $e');
      return null;
    }
  }

  /// Save or update edit profile data
  Future<bool> saveEditProfile(EditProfileModel profile) async {
    try {
      final db = await _dbHelper.database;
      await initializeProfileTables();
      
      final profileMap = profile.toMap();
      profileMap.remove('id'); // Remove id for upsert
      
      // Use INSERT OR REPLACE for upsert functionality
      final result = await db.insert(
        'edit_profile',
        profileMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('ProfileRepository: Edit profile saved with ID: $result');
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error saving edit profile: $e');
      return false;
    }
  }

  /// Check if edit profile data exists
  Future<bool> hasEditProfileData(String userId) async {
    try {
      final profile = await getEditProfile(userId);
      return profile != null &&
             profile.nama.isNotEmpty &&
             profile.bidangKeahlian.isNotEmpty &&
             profile.toefl.isNotEmpty;
    } catch (e) {
      print('ProfileRepository: Error checking edit profile data: $e');
      return false;
    }
  }

  /// Delete edit profile data
  Future<bool> deleteEditProfile(String userId) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.delete(
        'edit_profile',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error deleting edit profile: $e');
      return false;
    }
  }

  // ========================================
  // PRIBADI DATA OPERATIONS
  // ========================================

  /// Get pribadi data by user ID
  Future<PribadiModel?> getPribadiData(String userId) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.query(
        'pribadi_data',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return PribadiModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('ProfileRepository: Error getting pribadi data: $e');
      return null;
    }
  }

  /// Save or update pribadi data
  Future<bool> savePribadiData(PribadiModel pribadi) async {
    try {
      final db = await _dbHelper.database;
      await initializeProfileTables();
      
      final pribadiMap = pribadi.toMap();
      pribadiMap.remove('id'); // Remove id for upsert
      
      // Use INSERT OR REPLACE for upsert functionality
      final result = await db.insert(
        'pribadi_data',
        pribadiMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('ProfileRepository: Pribadi data saved with ID: $result');
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error saving pribadi data: $e');
      return false;
    }
  }

  /// Check if pribadi data exists
  Future<bool> hasPribadiData(String userId) async {
    try {
      final pribadi = await getPribadiData(userId);
      return pribadi != null &&
             (pribadi.tempatLahir.isNotEmpty ||
              pribadi.email.isNotEmpty ||
              pribadi.handphone.isNotEmpty ||
              pribadi.address.isNotEmpty);
    } catch (e) {
      print('ProfileRepository: Error checking pribadi data: $e');
      return false;
    }
  }

  /// Delete pribadi data
  Future<bool> deletePribadiData(String userId) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.delete(
        'pribadi_data',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error deleting pribadi data: $e');
      return false;
    }
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  /// Get all profile data summary
  Future<Map<String, bool>> getProfileCompletionStatus(String userId) async {
    try {
      final hasEdit = await hasEditProfileData(userId);
      final hasPribadi = await hasPribadiData(userId);
      
      return {
        'editProfile': hasEdit,
        'pribadiData': hasPribadi,
      };
    } catch (e) {
      print('ProfileRepository: Error getting completion status: $e');
      return {
        'editProfile': false,
        'pribadiData': false,
      };
    }
  }

  /// Clear all profile data for user
  Future<bool> clearAllProfileData(String userId) async {
    try {
      final editResult = await deleteEditProfile(userId);
      final pribadiResult = await deletePribadiData(userId);
      
      return editResult || pribadiResult;
    } catch (e) {
      print('ProfileRepository: Error clearing profile data: $e');
      return false;
    }
  }

  /// Search profiles (for admin purposes)
  Future<List<EditProfileModel>> searchProfiles(String keyword) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.query(
        'edit_profile',
        where: 'nama LIKE ? OR nik LIKE ? OR bidang_keahlian LIKE ?',
        whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
        orderBy: 'nama ASC',
      );
      
      return result.map((map) => EditProfileModel.fromMap(map)).toList();
    } catch (e) {
      print('ProfileRepository: Error searching profiles: $e');
      return [];
    }
  }

  /// Get all profiles (for admin purposes)
  Future<List<EditProfileModel>> getAllProfiles() async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.query(
        'edit_profile',
        orderBy: 'created_at DESC',
      );
      
      return result.map((map) => EditProfileModel.fromMap(map)).toList();
    } catch (e) {
      print('ProfileRepository: Error getting all profiles: $e');
      return [];
    }
  }

  // ========================================
  // HONORARIUM DATA OPERATIONS
  // ========================================

  /// Get honorarium data by user ID
  Future<HonorariumModel?> getHonorariumData(String userId) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.query(
        'honorarium_data',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      if (result.isNotEmpty) {
        return HonorariumModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('ProfileRepository: Error getting honorarium data: $e');
      return null;
    }
  }

  /// Save or update honorarium data
  Future<bool> saveHonorariumData(HonorariumModel honorarium) async {
    try {
      final db = await _dbHelper.database;
      
      print('ProfileRepository: Saving honorarium data for user: ${honorarium.userId}');
      
      // Use insert with conflict resolution instead of insertOrReplace
      final result = await db.insert(
        'honorarium_data',
        honorarium.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('ProfileRepository: Honorarium data save result: $result');
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error saving honorarium data: $e');
      return false;
    }
  }

  /// Update existing honorarium data
  Future<bool> updateHonorariumData(HonorariumModel honorarium) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.update(
        'honorarium_data',
        honorarium.toMap(),
        where: 'user_id = ?',
        whereArgs: [honorarium.userId],
      );
      
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error updating honorarium data: $e');
      return false;
    }
  }

  /// Check if user has honorarium data
  Future<bool> hasHonorariumData(String userId) async {
    try {
      final data = await getHonorariumData(userId);
      return data != null;
    } catch (e) {
      print('ProfileRepository: Error checking honorarium data: $e');
      return false;
    }
  }

  /// Delete honorarium data
  Future<bool> deleteHonorariumData(String userId) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.delete(
        'honorarium_data',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error deleting honorarium data: $e');
      return false;
    }
  }

  // ========================================
  // ID CARD DATA OPERATIONS
  // ========================================

  /// Get ID card data by user ID
  Future<IdCardModel?> getIdCardData(String userId) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.query(
        'idcard_data',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      if (result.isNotEmpty) {
        return IdCardModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('ProfileRepository: Error getting ID card data: $e');
      return null;
    }
  }

  /// Save or update ID card data
  Future<bool> saveIdCardData(IdCardModel idCard) async {
    try {
      final db = await _dbHelper.database;
      
      print('ProfileRepository: Saving ID card data for user: ${idCard.userId}');
      print('ProfileRepository: Photo path: ${idCard.fotoPath}');
      print('ProfileRepository: Is uploaded: ${idCard.isUploaded}');
      
      // Use insert with conflict resolution instead of insertOrReplace
      final result = await db.insert(
        'idcard_data',
        idCard.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('ProfileRepository: ID card data save result: $result');
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error saving ID card data: $e');
      return false;
    }
  }

  /// Update existing ID card data
  Future<bool> updateIdCardData(IdCardModel idCard) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.update(
        'idcard_data',
        idCard.toMap(),
        where: 'user_id = ?',
        whereArgs: [idCard.userId],
      );
      
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error updating ID card data: $e');
      return false;
    }
  }

  /// Check if user has ID card data
  Future<bool> hasIdCardData(String userId) async {
    try {
      final data = await getIdCardData(userId);
      return data != null;
    } catch (e) {
      print('ProfileRepository: Error checking ID card data: $e');
      return false;
    }
  }

  /// Delete ID card data
  Future<bool> deleteIdCardData(String userId) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.delete(
        'idcard_data',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error deleting ID card data: $e');
      return false;
    }
  }

  // ========================================
  // KELUARGA OPERATIONS
  // ========================================

  /// Get keluarga data by user ID
  Future<KeluargaModel?> getKeluargaData(String userId) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.query(
        'keluarga_data',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return KeluargaModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('ProfileRepository: Error getting keluarga data: $e');
      return null;
    }
  }

  /// Save keluarga data (insert or update)
  Future<bool> saveKeluargaData(KeluargaModel keluarga) async {
    try {
      final db = await _dbHelper.database;
      
      print('ProfileRepository: Saving keluarga data for user: ${keluarga.userId}');
      print('ProfileRepository: Nama Ayah: ${keluarga.namaAyah}');
      print('ProfileRepository: Nama Ibu: ${keluarga.namaIbu}');
      print('ProfileRepository: Nama Pasangan: ${keluarga.namaPasangan}');
      print('ProfileRepository: Nama Anak: ${keluarga.namaAnak}');
      
      final result = await db.insert(
        'keluarga_data',
        keluarga.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('ProfileRepository: Keluarga data save result: $result');
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error saving keluarga data: $e');
      return false;
    }
  }

  /// Update existing keluarga data
  Future<bool> updateKeluargaData(KeluargaModel keluarga) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.update(
        'keluarga_data',
        keluarga.toMap(),
        where: 'user_id = ?',
        whereArgs: [keluarga.userId],
      );
      
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error updating keluarga data: $e');
      return false;
    }
  }

  /// Check if user has keluarga data
  Future<bool> hasKeluargaData(String userId) async {
    try {
      final data = await getKeluargaData(userId);
      return data != null;
    } catch (e) {
      print('ProfileRepository: Error checking keluarga data: $e');
      return false;
    }
  }

  /// Delete keluarga data
  Future<bool> deleteKeluargaData(String userId) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.delete(
        'keluarga_data',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error deleting keluarga data: $e');
      return false;
    }
  }

  // ========================================
  // PENDIDIKAN OPERATIONS
  // ========================================

  /// Get all pendidikan data by user ID
  Future<List<PendidikanModel>> getPendidikanData(String userId) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.query(
        'pendidikan_data',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'tahun_selesai DESC', // Terbaru di atas
      );

      return result.map((map) => PendidikanModel.fromMap(map)).toList();
    } catch (e) {
      print('ProfileRepository: Error getting pendidikan data: $e');
      return [];
    }
  }

  /// Save pendidikan data (can add multiple records)
  Future<bool> savePendidikanData(PendidikanModel pendidikan) async {
    try {
      final db = await _dbHelper.database;
      await initializeProfileTables();
      
      print('ProfileRepository: Saving pendidikan data...');
      print('ProfileRepository: Jenjang: ${pendidikan.jenjang}');
      print('ProfileRepository: Jurusan: ${pendidikan.jurusan}');
      print('ProfileRepository: Institusi: ${pendidikan.institusi}');
      print('ProfileRepository: Kota: ${pendidikan.kota}');
      
      final result = await db.insert(
        'pendidikan_data',
        pendidikan.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('ProfileRepository: Pendidikan data save result: $result');
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error saving pendidikan data: $e');
      return false;
    }
  }

  /// Update existing pendidikan data by ID
  Future<bool> updatePendidikanData(PendidikanModel pendidikan) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.update(
        'pendidikan_data',
        pendidikan.toMap(),
        where: 'id = ?',
        whereArgs: [pendidikan.id],
      );
      
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error updating pendidikan data: $e');
      return false;
    }
  }

  /// Delete pendidikan data by ID
  Future<bool> deletePendidikanData(int id) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.delete(
        'pendidikan_data',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error deleting pendidikan data: $e');
      return false;
    }
  }

  /// Delete all pendidikan data by user ID
  Future<bool> deleteAllPendidikanData(String userId) async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.delete(
        'pendidikan_data',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      return result > 0;
    } catch (e) {
      print('ProfileRepository: Error deleting all pendidikan data: $e');
      return false;
    }
  }

  /// Check if user has pendidikan data
  Future<bool> hasPendidikanData(String userId) async {
    try {
      final data = await getPendidikanData(userId);
      return data.isNotEmpty;
    } catch (e) {
      print('ProfileRepository: Error checking pendidikan data: $e');
      return false;
    }
  }

  /// Get latest/highest education for profile display
  Future<PendidikanModel?> getLatestPendidikanData(String userId) async {
    try {
      final allData = await getPendidikanData(userId);
      if (allData.isEmpty) return null;
      
      // Return the latest education (highest level or most recent)
      return allData.first; // Already sorted by tahun_selesai DESC
    } catch (e) {
      print('ProfileRepository: Error getting latest pendidikan data: $e');
      return null;
    }
  }
}
