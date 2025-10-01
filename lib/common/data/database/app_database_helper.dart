import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabaseHelper {
  static final AppDatabaseHelper _instance = AppDatabaseHelper._internal();
  static Database? _database;

  AppDatabaseHelper._internal();

  factory AppDatabaseHelper() => _instance;
  
  // Singleton getter
  static AppDatabaseHelper get instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    
    // Pastikan default user ada
    await _ensureDefaultUser();
    
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Use consistent database name for persistence
    String path = join(await getDatabasesPath(), 'ppnpn_app.db');
    
    return await openDatabase(   
      path,
      version: 19, // Updated to version 19 for notification table
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        // Enable foreign key constraints
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create all tables dengan urutan yang benar (users dulu, kemudian yang lain)
    await _createUserTable(db);
    await _createTaskTable(db);
    await _createMeetingTable(db);
    await _createCutiTable(db);
    await _createAbsensiTable(db);
    await _createReimburseTable(db);
    await _createIzinTable(db);
    await _createLemburTable(db);
    
    // Create SIHAKI tables
    await _createSihakiTables(db);
    
    // Create notification table
    await _createNotificationTable(db);
    
    // Insert default user untuk foreign key constraints
    await _createDefaultUser(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    
    // For BPJS fix, drop all tables and recreate
    if (oldVersion < newVersion) {
      // Drop SIHAKI tables first (reverse order to avoid foreign key constraints)
      try {
        await db.execute('DROP TABLE IF EXISTS kesehatan');
        await db.execute('DROP TABLE IF EXISTS kontak');
        await db.execute('DROP TABLE IF EXISTS penerbangan');
        await db.execute('DROP TABLE IF EXISTS data_pribadi');
        await db.execute('DROP TABLE IF EXISTS tata_naskah');
        await db.execute('DROP TABLE IF EXISTS dokumen_anggota');
        await db.execute('DROP TABLE IF EXISTS kunker_perorangan');
        await db.execute('DROP TABLE IF EXISTS kegiatan_rumah_aspirasi');
        await db.execute('DROP TABLE IF EXISTS data_pajak_ppnpn');
        await db.execute('DROP TABLE IF EXISTS data_pajak_anggota');
        await db.execute('DROP TABLE IF EXISTS data_bpjs');
        await db.execute('DROP TABLE IF EXISTS media_sosial_anggota');
        await db.execute('DROP TABLE IF EXISTS agenda_pribadi_anggota');
        await db.execute('DROP TABLE IF EXISTS anggota_dpr');
        
        // Drop other tables
        await db.execute('DROP TABLE IF EXISTS lembur');
        await db.execute('DROP TABLE IF EXISTS izin');
        await db.execute('DROP TABLE IF EXISTS reimburse');
        await db.execute('DROP TABLE IF EXISTS absensi');
        await db.execute('DROP TABLE IF EXISTS cuti');
        await db.execute('DROP TABLE IF EXISTS meetings');
        await db.execute('DROP TABLE IF EXISTS tasks');
        await db.execute('DROP TABLE IF EXISTS users');
        
        // Recreate all tables
        await _createUserTable(db);
        await _createTaskTable(db);
        await _createMeetingTable(db);
        await _createCutiTable(db);
        await _createAbsensiTable(db);
        await _createReimburseTable(db);
        await _createIzinTable(db);
        await _createLemburTable(db);
        await _createSihakiTables(db);
        
        // Create notification table
        await _createNotificationTable(db);
        
        // Insert default user untuk foreign key constraints
        await _createDefaultUser(db);
        
      } catch (e) {
        rethrow;
      }
    }
  }

  // User Table - Base table untuk foreign keys
  Future<void> _createUserTable(Database db) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        nama TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        role TEXT NOT NULL CHECK (role IN ('admin', 'pegawai', 'magang')),
        no_telepon TEXT,
        alamat TEXT,
        last_login TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_users_username ON users(username)');
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_users_role ON users(role)');
  }

  // Task Table - Updated untuk compatibility dengan TaskModel baru
  Future<void> _createTaskTable(Database db) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        assigned_to_id INTEGER,
        created_by_id INTEGER,
        status TEXT NOT NULL CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
        priority TEXT NOT NULL CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
        progress INTEGER DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
        due_date TEXT,
        completed_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (assigned_to_id) REFERENCES users (id),
        FOREIGN KEY (created_by_id) REFERENCES users (id)
      )
    ''');

    // Create indexes untuk performa
    await db.execute('CREATE INDEX idx_tasks_status ON tasks(status)');
    await db.execute('CREATE INDEX idx_tasks_priority ON tasks(priority)');
    await db.execute('CREATE INDEX idx_tasks_due_date ON tasks(due_date)');
    await db.execute('CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to_id)');
  }

  // Meeting Table - Updated untuk compatibility dengan MeetingModel baru
  Future<void> _createMeetingTable(Database db) async {
    await db.execute('''
      CREATE TABLE meetings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        judul TEXT NOT NULL,
        deskripsi TEXT,
        tanggal TEXT NOT NULL,
        waktu_mulai TEXT NOT NULL,
        waktu_selesai TEXT NOT NULL,
        lokasi TEXT,
        organizer INTEGER,
        status TEXT NOT NULL CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (organizer) REFERENCES users (id)
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_meetings_tanggal ON meetings(tanggal)');
    await db.execute('CREATE INDEX idx_meetings_status ON meetings(status)');
    await db.execute('CREATE INDEX idx_meetings_organizer ON meetings(organizer)');
  }

  // Cuti Table - Keep compatibility dengan CutiModel yang ada
  Future<void> _createCutiTable(Database db) async {
    await db.execute('''
      CREATE TABLE cuti(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        jenisCuti TEXT NOT NULL,
        tanggalMulai TEXT NOT NULL,
        tanggalSelesai TEXT NOT NULL,
        alasan TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'menunggu_persetujuan',
        fileName TEXT,
        filePath TEXT,
        tanggalPengajuan TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_cuti_user ON cuti(userId)');
    await db.execute('CREATE INDEX idx_cuti_status ON cuti(status)');
    await db.execute('CREATE INDEX idx_cuti_dates ON cuti(tanggalMulai, tanggalSelesai)');
  }

  // Absensi Table
  Future<void> _createAbsensiTable(Database db) async {
    await db.execute('''
      CREATE TABLE absensi(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        tanggal TEXT NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('checkin', 'checkout')),
        jam TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        image_path TEXT,
        image_bytes BLOB,
        status TEXT NOT NULL,
        keterangan TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_absensi_user_date ON absensi(user_id, tanggal)');
    await db.execute('CREATE INDEX idx_absensi_date ON absensi(tanggal)');
  }

  // Reimburse Table
  Future<void> _createReimburseTable(Database db) async {
    await db.execute('''
      CREATE TABLE reimburse(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL CHECK (amount > 0),
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'menunggu_persetujuan' CHECK (status IN ('menunggu_persetujuan', 'disetujui', 'ditolak')),
        file_name TEXT,
        user_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_reimburse_user_id ON reimburse(user_id)');
    await db.execute('CREATE INDEX idx_reimburse_status ON reimburse(status)');
    await db.execute('CREATE INDEX idx_reimburse_date ON reimburse(date)');
  }

  // Izin Table
  Future<void> _createIzinTable(Database db) async {
    await db.execute('''
      CREATE TABLE izin(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        duration TEXT NOT NULL,
        reason TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'menunggu_persetujuan' CHECK (status IN ('menunggu_persetujuan', 'disetujui', 'ditolak')),
        file_name TEXT,
        user_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_izin_user_id ON izin(user_id)');
    await db.execute('CREATE INDEX idx_izin_status ON izin(status)');
    await db.execute('CREATE INDEX idx_izin_date ON izin(date)');
  }

  // Lembur Table
  Future<void> _createLemburTable(Database db) async {
    await db.execute('''
      CREATE TABLE lembur(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        duration TEXT NOT NULL,
        reason TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'menunggu_persetujuan' CHECK (status IN ('menunggu_persetujuan', 'disetujui', 'ditolak')),
        file_name TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        user_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_lembur_user_id ON lembur(user_id)');
    await db.execute('CREATE INDEX idx_lembur_status ON lembur(status)');
    await db.execute('CREATE INDEX idx_lembur_date ON lembur(date)');
  }

  // SIHAKI Tables Creation
  Future<void> _createSihakiTables(Database db) async {
    // 1. Agenda Pribadi Anggota
    await db.execute('''
      CREATE TABLE agenda_pribadi_anggota(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT NOT NULL,
        waktu TEXT NOT NULL,
        agenda TEXT NOT NULL,
        tempat TEXT NOT NULL,
        keterangan TEXT,
        user_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 2. Media Sosial Anggota
    await db.execute('''
      CREATE TABLE media_sosial_anggota(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        platform TEXT NOT NULL,
        username TEXT NOT NULL,
        url TEXT NOT NULL,
        followers INTEGER DEFAULT 0,
        is_verified INTEGER DEFAULT 0,
        status TEXT DEFAULT 'aktif' CHECK (status IN ('aktif', 'tidak_aktif')),
        user_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 3. Data BPJS
    await db.execute('''
      CREATE TABLE data_bpjs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        no_bpjs TEXT NOT NULL,
        nik TEXT NOT NULL,
        hubungan_keluarga TEXT NOT NULL,
        tanggal_lahir TEXT NOT NULL,
        nama_faskes_tingkat1 TEXT NOT NULL,
        status TEXT DEFAULT 'aktif' CHECK (status IN ('aktif', 'non-aktif', 'pending')),
        user_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 4. Data Pajak Anggota
    await db.execute('''
      CREATE TABLE data_pajak_anggota(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        npwp TEXT NOT NULL,
        nama_wajib_pajak TEXT NOT NULL,
        alamat_wp TEXT NOT NULL,
        jenis_pajak TEXT NOT NULL,
        tahun_pajak INTEGER NOT NULL,
        jumlah_pajak REAL NOT NULL,
        status_bayar TEXT DEFAULT 'belum_bayar' CHECK (status_bayar IN ('sudah_bayar', 'belum_bayar', 'terlambat')),
        tanggal_jatuh_tempo TEXT NOT NULL,
        user_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 5. Data Pajak PPNPN
    await db.execute('''
      CREATE TABLE data_pajak_ppnpn(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nip TEXT NOT NULL,
        nama_ppnpn TEXT NOT NULL,
        jabatan TEXT NOT NULL,
        unit_kerja TEXT NOT NULL,
        gaji_pokok REAL NOT NULL,
        tunjangan REAL DEFAULT 0,
        potongan_pajak REAL NOT NULL,
        bulan_pajak INTEGER NOT NULL,
        tahun_pajak INTEGER NOT NULL,
        user_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 6. Kegiatan Rumah Aspirasi
    await db.execute('''
      CREATE TABLE kegiatan_rumah_aspirasi(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_kegiatan TEXT NOT NULL,
        tanggal_kegiatan TEXT NOT NULL,
        waktu_mulai TEXT NOT NULL,
        waktu_selesai TEXT NOT NULL,
        tempat TEXT NOT NULL,
        deskripsi TEXT,
        jumlah_peserta INTEGER DEFAULT 0,
        pic TEXT NOT NULL,
        kontak_pic TEXT,
        status TEXT DEFAULT 'direncanakan' CHECK (status IN ('direncanakan', 'berlangsung', 'selesai', 'dibatalkan')),
        user_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 7. Kunker Perorangan
    await db.execute('''
      CREATE TABLE kunker_perorangan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        no_surat TEXT UNIQUE NOT NULL,
        jenis_perjadin TEXT NOT NULL,
        tanggal_surat TEXT NOT NULL,
        tanggal_awal TEXT NOT NULL,
        tanggal_akhir TEXT NOT NULL,
        masa_persidangan TEXT NOT NULL,
        tahun_sidang TEXT NOT NULL,
        anggota TEXT NOT NULL,
        no_anggota TEXT NOT NULL,
        nik_anggota TEXT NOT NULL,
        fraksi TEXT NOT NULL,
        dapil TEXT NOT NULL,
        rek_anggota TEXT NOT NULL,
        nama_rek_anggota TEXT NOT NULL,
        kode_bank_anggota TEXT NOT NULL,
        nama_bank_anggota TEXT NOT NULL,
        ta TEXT NOT NULL,
        no_ta TEXT NOT NULL,
        nik_ta TEXT NOT NULL,
        hp_ta TEXT NOT NULL,
        email_ta TEXT NOT NULL,
        rek_ta TEXT NOT NULL,
        nama_rek_ta TEXT NOT NULL,
        kode_bank_ta TEXT NOT NULL,
        nama_bank_ta TEXT NOT NULL,
        moda TEXT NOT NULL,
        negara TEXT NOT NULL,
        provinsi TEXT NOT NULL,
        kota TEXT NOT NULL,
        status_pengajuan TEXT NOT NULL,
        status_pencairan TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // 8. Database Anggota DPR RI
    await db.execute('''
      CREATE TABLE anggota_dpr(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nip TEXT NOT NULL UNIQUE,
        nama_lengkap TEXT NOT NULL,
        gelar_depan TEXT,
        gelar_belakang TEXT,
        partai TEXT NOT NULL,
        dapil TEXT NOT NULL,
        provinsi TEXT NOT NULL,
        jenis_kelamin TEXT NOT NULL CHECK (jenis_kelamin IN ('L', 'P')),
        tempat_lahir TEXT NOT NULL,
        tanggal_lahir TEXT NOT NULL,
        agama TEXT NOT NULL,
        alamat TEXT NOT NULL,
        telepon TEXT,
        email TEXT,
        pendidikan_terakhir TEXT,
        pekerjaan_sebelumnya TEXT,
        periode_mulai TEXT NOT NULL,
        periode_selesai TEXT,
        status TEXT DEFAULT 'aktif' CHECK (status IN ('aktif', 'tidak_aktif', 'pengganti')),
        foto_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_agenda_pribadi_user_id ON agenda_pribadi_anggota(user_id)');
    await db.execute('CREATE INDEX idx_agenda_pribadi_tanggal ON agenda_pribadi_anggota(tanggal)');
    
    await db.execute('CREATE INDEX idx_media_sosial_user_id ON media_sosial_anggota(user_id)');
    await db.execute('CREATE INDEX idx_media_sosial_platform ON media_sosial_anggota(platform)');
    
    await db.execute('CREATE INDEX idx_bpjs_user_id ON data_bpjs(user_id)');
    await db.execute('CREATE INDEX idx_bpjs_nomor ON data_bpjs(no_bpjs)');
    
    await db.execute('CREATE INDEX idx_pajak_anggota_user_id ON data_pajak_anggota(user_id)');
    await db.execute('CREATE INDEX idx_pajak_anggota_npwp ON data_pajak_anggota(npwp)');
    
    await db.execute('CREATE INDEX idx_pajak_ppnpn_nip ON data_pajak_ppnpn(nip)');
    await db.execute('CREATE INDEX idx_pajak_ppnpn_tahun ON data_pajak_ppnpn(tahun_pajak)');
    
    await db.execute('CREATE INDEX idx_rumah_aspirasi_user_id ON kegiatan_rumah_aspirasi(user_id)');
    await db.execute('CREATE INDEX idx_rumah_aspirasi_tanggal ON kegiatan_rumah_aspirasi(tanggal_kegiatan)');
    
    await db.execute('CREATE INDEX idx_kunker_no_surat ON kunker_perorangan(no_surat)');
    await db.execute('CREATE INDEX idx_kunker_status_pengajuan ON kunker_perorangan(status_pengajuan)');
    
    await db.execute('CREATE INDEX idx_anggota_dpr_nip ON anggota_dpr(nip)');
    await db.execute('CREATE INDEX idx_anggota_dpr_partai ON anggota_dpr(partai)');
    await db.execute('CREATE INDEX idx_anggota_dpr_dapil ON anggota_dpr(dapil)');

    // 8. Dokumen Anggota
    await db.execute('''
      CREATE TABLE dokumen_anggota(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_anggota TEXT NOT NULL,
        document_id TEXT NOT NULL,
        document_title TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_type TEXT NOT NULL,
        file_size TEXT NOT NULL,
        is_required INTEGER DEFAULT 1,
        uploaded_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for dokumen_anggota
    await db.execute('CREATE INDEX idx_dokumen_anggota_nama ON dokumen_anggota(nama_anggota)');
    await db.execute('CREATE INDEX idx_dokumen_anggota_document_id ON dokumen_anggota(document_id)');
    await db.execute('CREATE INDEX idx_dokumen_anggota_uploaded_at ON dokumen_anggota(uploaded_at)');

    // 9. Data Kesehatan
    await db.execute('''
      CREATE TABLE kesehatan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_anggota TEXT NOT NULL UNIQUE,
        berat_badan TEXT NOT NULL,
        tinggi_badan TEXT NOT NULL,
        golongan_darah TEXT NOT NULL,
        riwayat_penyakit TEXT DEFAULT '',
        alergi TEXT DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create index for kesehatan
    await db.execute('CREATE INDEX idx_kesehatan_nama ON kesehatan(nama_anggota)');

    // 10. Data Kontak
    await db.execute('''
      CREATE TABLE kontak(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_anggota TEXT NOT NULL UNIQUE,
        no_kontak TEXT NOT NULL,
        nama_kontak TEXT NOT NULL,
        hubungan_kontak TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create index for kontak
    await db.execute('CREATE INDEX idx_kontak_nama ON kontak(nama_anggota)');

    // 11. Data Penerbangan
    await db.execute('''
      CREATE TABLE penerbangan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_anggota TEXT NOT NULL UNIQUE,
        nomor_passport TEXT NOT NULL,
        bandara_preferensi TEXT NOT NULL,
        maskapai_preferensi TEXT NOT NULL,
        kelas_penerbangan TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create index for penerbangan
    await db.execute('CREATE INDEX idx_penerbangan_nama ON penerbangan(nama_anggota)');

    // 12. Data Pribadi
    await db.execute('''
      CREATE TABLE data_pribadi(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_anggota TEXT NOT NULL UNIQUE,
        handphone TEXT NOT NULL,
        email TEXT NOT NULL,
        telpon_ruangan TEXT NOT NULL,
        ruang_kerja TEXT NOT NULL,
        bahasa_asing TEXT NOT NULL,
        alamat_rumah TEXT NOT NULL,
        keterangan_domisili TEXT NOT NULL,
        nama_ayah_kandung TEXT NOT NULL,
        nama_ibu_kandung TEXT NOT NULL,
        no_rekening_mitra TEXT NOT NULL,
        nama_rekening_mitra TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create index for data_pribadi
    await db.execute('CREATE INDEX idx_data_pribadi_nama ON data_pribadi(nama_anggota)');

    // 13. Tata Naskah Documents
    await db.execute('''
      CREATE TABLE tata_naskah(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_anggota TEXT NOT NULL,
        document_id TEXT NOT NULL,
        document_title TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        file_size TEXT NOT NULL,
        is_required INTEGER NOT NULL,
        is_uploaded INTEGER NOT NULL,
        uploaded_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(nama_anggota, document_id)
      )
    ''');

    // Create index for tata_naskah
    await db.execute('CREATE INDEX idx_tata_naskah_nama ON tata_naskah(nama_anggota)');
    await db.execute('CREATE INDEX idx_tata_naskah_doc ON tata_naskah(document_id)');
  }

  // Create notification table
  Future<void> _createNotificationTable(Database db) async {
    await db.execute('''
      CREATE TABLE notifications(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        time TEXT NOT NULL,
        has_red_dot INTEGER NOT NULL DEFAULT 1,
        is_read INTEGER NOT NULL DEFAULT 0,
        icon_name TEXT NOT NULL,
        avatar_color TEXT NOT NULL,
        category TEXT NOT NULL,
        created_at TEXT NOT NULL,
        read_at TEXT,
        user_id INTEGER DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_notifications_is_read ON notifications(is_read)');
    await db.execute('CREATE INDEX idx_notifications_category ON notifications(category)');
    await db.execute('CREATE INDEX idx_notifications_created_at ON notifications(created_at)');
    await db.execute('CREATE INDEX idx_notifications_user_id ON notifications(user_id)');

    print('DEBUG: Notifications table created successfully');
  }

  // Create default user untuk foreign key constraints
  Future<void> _createDefaultUser(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    // Insert default user jika belum ada
    await db.insert('users', {
      'id': 1,
      'username': 'default_user',
      'password': 'password',
      'nama': 'Default User',
      'email': 'default@ppnpn.go.id',
      'role': 'pegawai',
      'no_telepon': '081234567890',
      'alamat': 'Jakarta',
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    
    print('DEBUG: Default user created/verified');
  }

  // Ensure default user exists
  Future<void> _ensureDefaultUser() async {
    final db = _database;
    if (db != null) {
      await _createDefaultUser(db);
    }
  }

  // Utility methods
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('reimburse');
      await txn.delete('absensi');
      await txn.delete('cuti');
      await txn.delete('meetings');
      await txn.delete('tasks');
      await txn.delete('users');
    });
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<bool> isDatabaseEmpty() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return (result.first['count'] as int) == 0;
  }

  // Get database info
  // Reimburse methods
  Future<List<Map<String, dynamic>>> getAllReimburse() async {
    final db = await database;
    return await db.query('reimburse', orderBy: 'date DESC');
  }
  
  Future<Map<String, dynamic>?> getReimburseById(int id) async {
    final db = await database;
    final result = await db.query(
      'reimburse',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }
  
  Future<int> insertReimburse(Map<String, dynamic> reimburse) async {
    final db = await database;
    return await db.insert('reimburse', reimburse);
  }
  
  Future<int> updateReimburse(int id, Map<String, dynamic> reimburse) async {
    final db = await database;
    return await db.update(
      'reimburse',
      reimburse,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<int> deleteReimburse(int id) async {
    final db = await database;
    return await db.delete(
      'reimburse',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<List<Map<String, dynamic>>> getReimburseByStatus(String status) async {
    final db = await database;
    return await db.query(
      'reimburse',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'date DESC',
    );
  }
  
  Future<List<Map<String, dynamic>>> getReimburseByUser(int userId) async {
    final db = await database;
    return await db.query(
      'reimburse',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;
    final userCount = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    final taskCount = await db.rawQuery('SELECT COUNT(*) as count FROM tasks');
    final meetingCount = await db.rawQuery('SELECT COUNT(*) as count FROM meetings');
    final cutiCount = await db.rawQuery('SELECT COUNT(*) as count FROM cuti');
    final absensiCount = await db.rawQuery('SELECT COUNT(*) as count FROM absensi');
    final reimburseCount = await db.rawQuery('SELECT COUNT(*) as count FROM reimburse');
    
    return {
      'users': userCount.first['count'],
      'tasks': taskCount.first['count'],
      'meetings': meetingCount.first['count'],
      'cuti': cutiCount.first['count'],
      'absensi': absensiCount.first['count'],
      'reimburse': reimburseCount.first['count'],
      'databasePath': join(await getDatabasesPath(), 'ppnpn_app.db'),
    };
  }



  // Method to reset database (for development purposes)
  Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), 'ppnpn_app.db');
    await deleteDatabase(path);
    _database = null;
    // This will trigger recreation of database
    await database;
  }

  // Method to check if table exists
  Future<bool> tableExists(String tableName) async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  // ========================================
  // IZIN CRUD OPERATIONS
  // ========================================

  Future<List<Map<String, dynamic>>> getAllIzin() async {
    final db = await database;
    final result = await db.query('izin', orderBy: 'created_at DESC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getIzinByUserId(int userId) async {
    final db = await database;
    return await db.query(
      'izin', 
      where: 'user_id = ?', 
      whereArgs: [userId],
      orderBy: 'created_at DESC'
    );
  }

  Future<List<Map<String, dynamic>>> getIzinByStatus(String status) async {
    final db = await database;
    return await db.query(
      'izin', 
      where: 'status = ?', 
      whereArgs: [status],
      orderBy: 'created_at DESC'
    );
  }

  Future<Map<String, dynamic>?> getIzinById(int id) async {
    final db = await database;
    final results = await db.query(
      'izin', 
      where: 'id = ?', 
      whereArgs: [id],
      limit: 1
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertIzin({
    required String type,
    required DateTime date,
    required String duration,
    required String reason,
    String status = 'menunggu_persetujuan',
    String? fileName,
    int? userId,
  }) async {
    try {
      final db = await database;
      final now = DateTime.now();
      
      // Pastikan user_id valid
      final targetUserId = userId ?? 1;
      
      // Check if user exists
      final userCheck = await db.query('users', where: 'id = ?', whereArgs: [targetUserId]);
      print('DEBUG: User check for ID $targetUserId: ${userCheck.length} records found');
      
      final izinData = {
        'type': type,
        'date': date.toIso8601String().split('T')[0], // Store as YYYY-MM-DD
        'duration': duration,
        'reason': reason,
        'status': status,
        'file_name': fileName,
        'user_id': targetUserId,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      
      print('DEBUG: Inserting izin data: $izinData');
      final result = await db.insert('izin', izinData);
      print('DEBUG: Insert result: $result');
      return result;
    } catch (e) {
      print('DEBUG: Insert izin error: $e');
      rethrow;
    }
  }

  Future<int> updateIzin({
    required int id,
    required String type,
    required DateTime date,
    required String duration,
    required String reason,
    String? status,
    String? fileName,
    int? userId,
  }) async {
    final db = await database;
    final now = DateTime.now();
    
    final izinData = <String, dynamic>{
      'type': type,
      'date': date.toIso8601String().split('T')[0],
      'duration': duration,
      'reason': reason,
      'file_name': fileName,
      'updated_at': now.toIso8601String(),
    };
    
    if (status != null) {
      izinData['status'] = status;
    }
    if (userId != null) {
      izinData['user_id'] = userId;
    }
    
    return await db.update(
      'izin', 
      izinData, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  Future<int> updateIzinStatus(int id, String status) async {
    final db = await database;
    final now = DateTime.now();
    
    final statusData = {
      'status': status,
      'updated_at': now.toIso8601String(),
    };
    
    return await db.update(
      'izin', 
      statusData, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  Future<int> deleteIzin(int id) async {
    final db = await database;
    return await db.delete('izin', where: 'id = ?', whereArgs: [id]);
  }

  // ========================================
  // LEMBUR CRUD OPERATIONS  
  // ========================================

  Future<List<Map<String, dynamic>>> getAllLembur() async {
    final db = await database;
    return await db.query('lembur', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getLemburByUserId(int userId) async {
    final db = await database;
    return await db.query(
      'lembur', 
      where: 'user_id = ?', 
      whereArgs: [userId],
      orderBy: 'created_at DESC'
    );
  }

  Future<List<Map<String, dynamic>>> getLemburByStatus(String status) async {
    final db = await database;
    return await db.query(
      'lembur', 
      where: 'status = ?', 
      whereArgs: [status],
      orderBy: 'created_at DESC'
    );
  }

  Future<List<Map<String, dynamic>>> getLemburByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    return await db.query(
      'lembur', 
      where: 'date BETWEEN ? AND ?', 
      whereArgs: [startDate.toIso8601String().split('T')[0], endDate.toIso8601String().split('T')[0]],
      orderBy: 'date DESC'
    );
  }

  Future<Map<String, dynamic>?> getLemburById(int id) async {
    final db = await database;
    final results = await db.query(
      'lembur', 
      where: 'id = ?', 
      whereArgs: [id],
      limit: 1
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertLembur({
    required String type,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String duration,
    required String reason,
    String status = 'menunggu_persetujuan',
    String? fileName,
    int? userId,
  }) async {
    final db = await database;
    final now = DateTime.now();
    
    final lemburData = {
      'type': type,
      'date': date.toIso8601String().split('T')[0], // Store as YYYY-MM-DD
      'start_time': startTime,
      'end_time': endTime,
      'duration': duration,
      'reason': reason,
      'status': status,
      'file_name': fileName,
      'user_id': userId ?? 1, // Default user ID
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
    
    final result = await db.insert('lembur', lemburData);
  
    return result;
  }

  Future<int> updateLembur({
    required int id,
    required String type,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String duration,
    required String reason,
    String? status,
    String? fileName,
    int? userId,
  }) async {
    final db = await database;
    final now = DateTime.now();
    
    final lemburData = <String, dynamic>{
      'type': type,
      'date': date.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'duration': duration,
      'reason': reason,
      'file_name': fileName,
      'updated_at': now.toIso8601String(),
    };
    
    // Only update status if provided
    if (status != null) {
      lemburData['status'] = status;
    }
    
    // Only update user_id if provided
    if (userId != null) {
      lemburData['user_id'] = userId;
    }
    
    final result = await db.update(
      'lembur', 
      lemburData, 
      where: 'id = ?', 
      whereArgs: [id]
    );
    
    return result;
  }

  Future<int> updateLemburStatus(int id, String status) async {
    final db = await database;
    final now = DateTime.now();
    
    final statusData = {
      'status': status,
      'updated_at': now.toIso8601String(),
    };
    
    return await db.update(
      'lembur', 
      statusData, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  Future<int> deleteLembur(int id) async {
    final db = await database;
    return await db.delete('lembur', where: 'id = ?', whereArgs: [id]);
  }

  // ========================================
  // MEETING CRUD OPERATIONS  
  // ========================================

  Future<List<Map<String, dynamic>>> getAllMeetings() async {
    final db = await database;
   
    final result = await db.query('meetings', orderBy: 'created_at DESC');
    
    // Transform database format to model format
    final transformedResult = result.map((meeting) {
      return {
        'id': meeting['id'],
        'meetingId': 'MTG${meeting['id']}',
        'title': meeting['judul'] ?? '',
        'description': meeting['deskripsi'],
        'room': meeting['lokasi'] ?? '',
        'date': meeting['tanggal'] ?? DateTime.now().toIso8601String(),
        'startTime': meeting['waktu_mulai'] ?? '',
        'endTime': meeting['waktu_selesai'] ?? '',
        'organizer': 'Admin', // Default organizer name
        'attendees': '', // Empty attendees
        'isOnline': 0, // Default to offline
        'meetingLink': null,
        'status': meeting['status'] ?? 'scheduled',
        'createdAt': meeting['created_at'] ?? DateTime.now().toIso8601String(),
        'updatedAt': meeting['updated_at'] ?? DateTime.now().toIso8601String(),
      };
    }).toList();
    
    return transformedResult;
  }

  Future<List<Map<String, dynamic>>> getMeetingsByDate(DateTime date) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];
    
    final result = await db.query(
      'meetings', 
      where: 'date(tanggal) = ?', 
      whereArgs: [dateString],
      orderBy: 'waktu_mulai ASC'
    );
    
    // Transform database format to model format
    return result.map((meeting) {
      return {
        'id': meeting['id'],
        'meetingId': 'MTG${meeting['id']}',
        'title': meeting['judul'] ?? '',
        'description': meeting['deskripsi'],
        'room': meeting['lokasi'] ?? '',
        'date': meeting['tanggal'] ?? DateTime.now().toIso8601String(),
        'startTime': meeting['waktu_mulai'] ?? '',
        'endTime': meeting['waktu_selesai'] ?? '',
        'organizer': 'Admin',
        'attendees': '',
        'isOnline': 0,
        'meetingLink': null,
        'status': meeting['status'] ?? 'scheduled',
        'createdAt': meeting['created_at'] ?? DateTime.now().toIso8601String(),
        'updatedAt': meeting['updated_at'] ?? DateTime.now().toIso8601String(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getUpcomingMeetings() async {
    final db = await database;
    final now = DateTime.now();
    final dateString = now.toIso8601String().split('T')[0];
    
    final result = await db.query(
      'meetings', 
      where: 'tanggal >= ? AND status = ?', 
      whereArgs: [dateString, 'scheduled'],
      orderBy: 'tanggal ASC, waktu_mulai ASC'
    );
    
    // Transform database format to model format
    return result.map((meeting) {
      return {
        'id': meeting['id'],
        'meetingId': 'MTG${meeting['id']}',
        'title': meeting['judul'] ?? '',
        'description': meeting['deskripsi'],
        'room': meeting['lokasi'] ?? '',
        'date': meeting['tanggal'] ?? DateTime.now().toIso8601String(),
        'startTime': meeting['waktu_mulai'] ?? '',
        'endTime': meeting['waktu_selesai'] ?? '',
        'organizer': 'Admin',
        'attendees': '',
        'isOnline': 0,
        'meetingLink': null,
        'status': meeting['status'] ?? 'scheduled',
        'createdAt': meeting['created_at'] ?? DateTime.now().toIso8601String(),
        'updatedAt': meeting['updated_at'] ?? DateTime.now().toIso8601String(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getTodaysMeetings() async {
    final now = DateTime.now();
    return await getMeetingsByDate(now);
  }

  Future<List<Map<String, dynamic>>> searchMeetings(String query) async {
    final db = await database;
    final searchQuery = '%$query%';
    
    final result = await db.query(
      'meetings', 
      where: 'judul LIKE ? OR deskripsi LIKE ? OR lokasi LIKE ?', 
      whereArgs: [searchQuery, searchQuery, searchQuery],
      orderBy: 'created_at DESC'
    );
    
    // Transform database format to model format
    return result.map((meeting) {
      return {
        'id': meeting['id'],
        'meetingId': 'MTG${meeting['id']}',
        'title': meeting['judul'] ?? '',
        'description': meeting['deskripsi'],
        'room': meeting['lokasi'] ?? '',
        'date': meeting['tanggal'] ?? DateTime.now().toIso8601String(),
        'startTime': meeting['waktu_mulai'] ?? '',
        'endTime': meeting['waktu_selesai'] ?? '',
        'organizer': 'Admin',
        'attendees': '',
        'isOnline': 0,
        'meetingLink': null,
        'status': meeting['status'] ?? 'scheduled',
        'createdAt': meeting['created_at'] ?? DateTime.now().toIso8601String(),
        'updatedAt': meeting['updated_at'] ?? DateTime.now().toIso8601String(),
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> getMeetingById(int id) async {
    final db = await database;
    final results = await db.query(
      'meetings', 
      where: 'id = ?', 
      whereArgs: [id],
      limit: 1
    );
    
    if (results.isEmpty) return null;
    
    final meeting = results.first;
    return {
      'id': meeting['id'],
      'meetingId': 'MTG${meeting['id']}',
      'title': meeting['judul'] ?? '',
      'description': meeting['deskripsi'],
      'room': meeting['lokasi'] ?? '',
      'date': meeting['tanggal'] ?? DateTime.now().toIso8601String(),
      'startTime': meeting['waktu_mulai'] ?? '',
      'endTime': meeting['waktu_selesai'] ?? '',
      'organizer': 'Admin',
      'attendees': '',
      'isOnline': 0,
      'meetingLink': null,
      'status': meeting['status'] ?? 'scheduled',
      'createdAt': meeting['created_at'] ?? DateTime.now().toIso8601String(),
      'updatedAt': meeting['updated_at'] ?? DateTime.now().toIso8601String(),
    };
  }

  Future<int> insertMeeting({
    required String title,
    String? description,
    required String room,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String organizer,
    List<String> attendees = const [],
    bool isOnline = false,
    String? meetingLink,
    String status = 'scheduled',
  }) async {
    final db = await database;
    final now = DateTime.now();
    
    final meetingData = {
      'judul': title,
      'deskripsi': description,
      'tanggal': date.toIso8601String().split('T')[0], // Store as YYYY-MM-DD
      'waktu_mulai': startTime,
      'waktu_selesai': endTime,
      'lokasi': room,
      'organizer': 1, // Default organizer ID
      'status': status,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
    
    final result = await db.insert('meetings', meetingData);
    
    return result;
  }

  Future<int> updateMeeting({
    required int id,
    required String title,
    String? description,
    required String room,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String organizer,
    List<String> attendees = const [],
    bool isOnline = false,
    String? meetingLink,
    String? status,
  }) async {
    final db = await database;
    final now = DateTime.now();
    
    final meetingData = <String, dynamic>{
      'judul': title,
      'deskripsi': description,
      'tanggal': date.toIso8601String().split('T')[0],
      'waktu_mulai': startTime,
      'waktu_selesai': endTime,
      'lokasi': room,
      'updated_at': now.toIso8601String(),
    };
    
    if (status != null) {
      meetingData['status'] = status;
    }
    
    return await db.update(
      'meetings', 
      meetingData, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  Future<int> updateMeetingStatus(int id, String status) async {
    final db = await database;
    final now = DateTime.now();
    
    final statusData = {
      'status': status,
      'updated_at': now.toIso8601String(),
    };
    
    return await db.update(
      'meetings', 
      statusData, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  Future<int> deleteMeeting(int id) async {
    final db = await database;
    return await db.delete('meetings', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, int>> getMeetingStatistics() async {
    final db = await database;
    
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM meetings');
    final scheduledResult = await db.rawQuery('SELECT COUNT(*) as count FROM meetings WHERE status = ?', ['scheduled']);
    final completedResult = await db.rawQuery('SELECT COUNT(*) as count FROM meetings WHERE status = ?', ['completed']);
    final cancelledResult = await db.rawQuery('SELECT COUNT(*) as count FROM meetings WHERE status = ?', ['cancelled']);
    
    return {
      'total': totalResult.first['count'] as int,
      'scheduled': scheduledResult.first['count'] as int,
      'completed': completedResult.first['count'] as int,
      'cancelled': cancelledResult.first['count'] as int,
    };
  }

  // ===== SIHAKI CRUD OPERATIONS =====

  // Agenda Pribadi Anggota Operations
  Future<int> insertAgendaPribadi(Map<String, dynamic> agenda) async {
    final db = await database;
    return await db.insert('agenda_pribadi_anggota', agenda);
  }

  Future<List<Map<String, dynamic>>> getAllAgendaPribadi([int? userId]) async {
    final db = await database;
    if (userId != null) {
      return await db.query(
        'agenda_pribadi_anggota',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'tanggal DESC, waktu DESC'
      );
    }
    return await db.query('agenda_pribadi_anggota', orderBy: 'tanggal DESC, waktu DESC');
  }

  Future<Map<String, dynamic>?> getAgendaPribadiById(int id) async {
    final db = await database;
    final result = await db.query(
      'agenda_pribadi_anggota',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateAgendaPribadi(int id, Map<String, dynamic> agenda) async {
    final db = await database;
    return await db.update(
      'agenda_pribadi_anggota',
      agenda,
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<int> deleteAgendaPribadi(int id) async {
    final db = await database;
    return await db.delete('agenda_pribadi_anggota', where: 'id = ?', whereArgs: [id]);
  }

  // Media Sosial Anggota Operations
  Future<int> insertMediaSosial(Map<String, dynamic> mediaSosial) async {
    final db = await database;
    return await db.insert('media_sosial_anggota', mediaSosial);
  }

  Future<List<Map<String, dynamic>>> getAllMediaSosial([int? userId]) async {
    final db = await database;
    if (userId != null) {
      return await db.query(
        'media_sosial_anggota',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'platform ASC'
      );
    }
    return await db.query('media_sosial_anggota', orderBy: 'platform ASC');
  }

  Future<Map<String, dynamic>?> getMediaSosialById(int id) async {
    final db = await database;
    final result = await db.query(
      'media_sosial_anggota',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateMediaSosial(int id, Map<String, dynamic> mediaSosial) async {
    final db = await database;
    return await db.update(
      'media_sosial_anggota',
      mediaSosial,
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<int> deleteMediaSosial(int id) async {
    final db = await database;
    return await db.delete('media_sosial_anggota', where: 'id = ?', whereArgs: [id]);
  }

  // Data BPJS Operations
  Future<int> insertDataBPJS(Map<String, dynamic> dataBpjs) async {
    final db = await database;
    return await db.insert('data_bpjs', dataBpjs);
  }

  Future<List<Map<String, dynamic>>> getAllDataBPJS([int? userId]) async {
    final db = await database;
    if (userId != null) {
      return await db.query(
        'data_bpjs',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'jenis_bpjs ASC, nama_peserta ASC'
      );
    }
    return await db.query('data_bpjs', orderBy: 'jenis_bpjs ASC, nama_peserta ASC');
  }

  Future<Map<String, dynamic>?> getDataBPJSById(int id) async {
    final db = await database;
    final result = await db.query(
      'data_bpjs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateDataBPJS(int id, Map<String, dynamic> dataBpjs) async {
    final db = await database;
    return await db.update(
      'data_bpjs',
      dataBpjs,
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<int> deleteDataBPJS(int id) async {
    final db = await database;
    return await db.delete('data_bpjs', where: 'id = ?', whereArgs: [id]);
  }

  // Data Pajak Anggota Operations
  Future<int> insertDataPajakAnggota(Map<String, dynamic> dataPajak) async {
    final db = await database;
    return await db.insert('data_pajak_anggota', dataPajak);
  }

  Future<List<Map<String, dynamic>>> getAllDataPajakAnggota([int? userId]) async {
    final db = await database;
    if (userId != null) {
      return await db.query(
        'data_pajak_anggota',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'tahun_pajak DESC, jenis_pajak ASC'
      );
    }
    return await db.query('data_pajak_anggota', orderBy: 'tahun_pajak DESC, jenis_pajak ASC');
  }

  Future<Map<String, dynamic>?> getDataPajakAnggotaById(int id) async {
    final db = await database;
    final result = await db.query(
      'data_pajak_anggota',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateDataPajakAnggota(int id, Map<String, dynamic> dataPajak) async {
    final db = await database;
    return await db.update(
      'data_pajak_anggota',
      dataPajak,
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<int> deleteDataPajakAnggota(int id) async {
    final db = await database;
    return await db.delete('data_pajak_anggota', where: 'id = ?', whereArgs: [id]);
  }

  // Data Pajak PPNPN Operations
  Future<int> insertDataPajakPPNPN(Map<String, dynamic> dataPajak) async {
    final db = await database;
    return await db.insert('data_pajak_ppnpn', dataPajak);
  }

  Future<List<Map<String, dynamic>>> getAllDataPajakPPNPN([int? userId]) async {
    final db = await database;
    if (userId != null) {
      return await db.query(
        'data_pajak_ppnpn',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'tahun_pajak DESC, bulan_pajak DESC'
      );
    }
    return await db.query('data_pajak_ppnpn', orderBy: 'tahun_pajak DESC, bulan_pajak DESC');
  }

  Future<Map<String, dynamic>?> getDataPajakPPNPNById(int id) async {
    final db = await database;
    final result = await db.query(
      'data_pajak_ppnpn',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateDataPajakPPNPN(int id, Map<String, dynamic> dataPajak) async {
    final db = await database;
    return await db.update(
      'data_pajak_ppnpn',
      dataPajak,
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<int> deleteDataPajakPPNPN(int id) async {
    final db = await database;
    return await db.delete('data_pajak_ppnpn', where: 'id = ?', whereArgs: [id]);
  }

  // Kegiatan Rumah Aspirasi Operations
  Future<int> insertKegiatanRumahAspirasi(Map<String, dynamic> kegiatan) async {
    final db = await database;
    return await db.insert('kegiatan_rumah_aspirasi', kegiatan);
  }

  Future<List<Map<String, dynamic>>> getAllKegiatanRumahAspirasi([int? userId]) async {
    final db = await database;
    if (userId != null) {
      return await db.query(
        'kegiatan_rumah_aspirasi',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'tanggal_kegiatan DESC'
      );
    }
    return await db.query('kegiatan_rumah_aspirasi', orderBy: 'tanggal_kegiatan DESC');
  }

  Future<Map<String, dynamic>?> getKegiatanRumahAspirasiById(int id) async {
    final db = await database;
    final result = await db.query(
      'kegiatan_rumah_aspirasi',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateKegiatanRumahAspirasi(int id, Map<String, dynamic> kegiatan) async {
    final db = await database;
    return await db.update(
      'kegiatan_rumah_aspirasi',
      kegiatan,
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<int> deleteKegiatanRumahAspirasi(int id) async {
    final db = await database;
    return await db.delete('kegiatan_rumah_aspirasi', where: 'id = ?', whereArgs: [id]);
  }

  // BPJS Operations
  Future<int> insertBPJS(Map<String, dynamic> bpjs) async {
    try {
      final db = await database;
      final result = await db.insert('data_bpjs', bpjs);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllBPJS([int? userId]) async {
    final db = await database;
    if (userId != null) {
      return await db.query(
        'data_bpjs',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'nama ASC'
      );
    }
    return await db.query('data_bpjs', orderBy: 'nama ASC');
  }

  Future<Map<String, dynamic>?> getBPJSById(int id) async {
    final db = await database;
    final result = await db.query(
      'data_bpjs',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateBPJS(int id, Map<String, dynamic> bpjs) async {
    final db = await database;
    return await db.update(
      'data_bpjs',
      bpjs,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBPJS(int id) async {
    final db = await database;
    return await db.delete('data_bpjs', where: 'id = ?', whereArgs: [id]);
  }

  // Kunker Perorangan Operations
  Future<int> insertKunkerPerorangan(Map<String, dynamic> kunker) async {
    final db = await database;
    return await db.insert('kunker_perorangan', kunker);
  }

  Future<List<Map<String, dynamic>>> getAllKunkerPerorangan([int? userId]) async {
    final db = await database;
    if (userId != null) {
      return await db.query(
        'kunker_perorangan',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'tanggal_berangkat DESC'
      );
    }
    return await db.query('kunker_perorangan', orderBy: 'tanggal_berangkat DESC');
  }

  Future<Map<String, dynamic>?> getKunkerPeroranganById(int id) async {
    final db = await database;
    final result = await db.query(
      'kunker_perorangan',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateKunkerPerorangan(int id, Map<String, dynamic> kunker) async {
    final db = await database;
    return await db.update(
      'kunker_perorangan',
      kunker,
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<int> deleteKunkerPerorangan(int id) async {
    final db = await database;
    return await db.delete('kunker_perorangan', where: 'id = ?', whereArgs: [id]);
  }

  // Anggota DPR Operations
  Future<int> insertAnggotaDPR(Map<String, dynamic> anggota) async {
    final db = await database;
    return await db.insert('anggota_dpr', anggota);
  }

  Future<List<Map<String, dynamic>>> getAllAnggotaDPR() async {
    final db = await database;
    return await db.query('anggota_dpr', orderBy: 'nama_lengkap ASC');
  }

  Future<Map<String, dynamic>?> getAnggotaDPRById(int id) async {
    final db = await database;
    final result = await db.query(
      'anggota_dpr',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getAnggotaDPRByNIP(String nip) async {
    final db = await database;
    final result = await db.query(
      'anggota_dpr',
      where: 'nip = ?',
      whereArgs: [nip],
      limit: 1
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> searchAnggotaDPR(String keyword) async {
    final db = await database;
    return await db.query(
      'anggota_dpr',
      where: 'nama_lengkap LIKE ? OR partai LIKE ? OR dapil LIKE ? OR provinsi LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'nama_lengkap ASC'
    );
  }

  Future<List<Map<String, dynamic>>> getAnggotaDPRByPartai(String partai) async {
    final db = await database;
    return await db.query(
      'anggota_dpr',
      where: 'partai = ?',
      whereArgs: [partai],
      orderBy: 'nama_lengkap ASC'
    );
  }

  Future<List<Map<String, dynamic>>> getAnggotaDPRByDapil(String dapil) async {
    final db = await database;
    return await db.query(
      'anggota_dpr',
      where: 'dapil = ?',
      whereArgs: [dapil],
      orderBy: 'nama_lengkap ASC'
    );
  }

  Future<int> updateAnggotaDPR(int id, Map<String, dynamic> anggota) async {
    final db = await database;
    return await db.update(
      'anggota_dpr',
      anggota,
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<int> deleteAnggotaDPR(int id) async {
    final db = await database;
    return await db.delete('anggota_dpr', where: 'id = ?', whereArgs: [id]);
  }

  // Dokumen Anggota Operations
  Future<int> insertDokumenAnggota(Map<String, dynamic> dokumen) async {
    try {
      final db = await database;
      final id = await db.insert('dokumen_anggota', dokumen);
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDokumenAnggotaByNama(String namaAnggota) async {
    final db = await database;
    return await db.query(
      'dokumen_anggota',
      where: 'nama_anggota = ?',
      whereArgs: [namaAnggota],
      orderBy: 'uploaded_at DESC'
    );
  }

  Future<List<Map<String, dynamic>>> getAllDokumenAnggota() async {
    final db = await database;
    return await db.query('dokumen_anggota', orderBy: 'uploaded_at DESC');
  }

  Future<Map<String, dynamic>?> getDokumenAnggotaByDocumentId(String namaAnggota, String documentId) async {
    final db = await database;
    final result = await db.query(
      'dokumen_anggota',
      where: 'nama_anggota = ? AND document_id = ?',
      whereArgs: [namaAnggota, documentId],
      limit: 1
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateDokumenAnggota(int id, Map<String, dynamic> dokumen) async {
    final db = await database;
    return await db.update(
      'dokumen_anggota',
      dokumen,
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<int> deleteDokumenAnggota(int id) async {
    final db = await database;
    return await db.delete('dokumen_anggota', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteDokumenAnggotaByDocumentId(String namaAnggota, String documentId) async {
    final db = await database;
    return await db.delete(
      'dokumen_anggota',
      where: 'nama_anggota = ? AND document_id = ?',
      whereArgs: [namaAnggota, documentId]
    );
  }

  Future<List<Map<String, dynamic>>> searchDokumenAnggota(String keyword) async {
    final db = await database;
    return await db.query(
      'dokumen_anggota',
      where: 'nama_anggota LIKE ? OR document_title LIKE ? OR file_name LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'uploaded_at DESC'
    );
  }

  // SIHAKI Statistics
  Future<Map<String, int>> getSIHAKIStatistics() async {
    final db = await database;
    
    final agendaResult = await db.rawQuery('SELECT COUNT(*) as count FROM agenda_pribadi_anggota');
    final mediaSosialResult = await db.rawQuery('SELECT COUNT(*) as count FROM media_sosial_anggota');
    final bpjsResult = await db.rawQuery('SELECT COUNT(*) as count FROM data_bpjs');
    final pajakAnggotaResult = await db.rawQuery('SELECT COUNT(*) as count FROM data_pajak_anggota');
    final pajakPpnpnResult = await db.rawQuery('SELECT COUNT(*) as count FROM data_pajak_ppnpn');
    final rumahAspirasiResult = await db.rawQuery('SELECT COUNT(*) as count FROM kegiatan_rumah_aspirasi');
    final kunkerResult = await db.rawQuery('SELECT COUNT(*) as count FROM kunker_perorangan');
    final anggotaDprResult = await db.rawQuery('SELECT COUNT(*) as count FROM anggota_dpr');
    
    return {
      'agenda_pribadi': agendaResult.first['count'] as int,
      'media_sosial': mediaSosialResult.first['count'] as int,
      'data_bpjs': bpjsResult.first['count'] as int,
      'pajak_anggota': pajakAnggotaResult.first['count'] as int,
      'pajak_ppnpn': pajakPpnpnResult.first['count'] as int,
      'rumah_aspirasi': rumahAspirasiResult.first['count'] as int,
      'kunker_perorangan': kunkerResult.first['count'] as int,
      'anggota_dpr': anggotaDprResult.first['count'] as int,
    };
  }

  // Force recreate database (untuk development/testing)
  Future<void> forceRecreateDatabase() async {
    try {
      // Close existing database
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      
      // Delete database file
      String path = join(await getDatabasesPath(), 'ppnpn_app.db');
      await File(path).delete();
      
      // Reinitialize database
      _database = await _initDatabase();
      
      // Ensure default user exists
      await _ensureDefaultUser();
      
      print('DEBUG: Database forcefully recreated with default user');
    } catch (e) {
      print('DEBUG: Error recreating database: $e');
      rethrow;
    }
  }

  // Method untuk debug - check database state
  Future<Map<String, dynamic>> checkDatabaseState() async {
    final db = await database;
    
    final userCount = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    final izinCount = await db.rawQuery('SELECT COUNT(*) as count FROM izin');
    final defaultUser = await db.query('users', where: 'id = ?', whereArgs: [1]);
    
    return {
      'user_count': userCount.first['count'],
      'izin_count': izinCount.first['count'],
      'default_user_exists': defaultUser.isNotEmpty,
      'default_user_data': defaultUser.isNotEmpty ? defaultUser.first : null,
    };
  }

}