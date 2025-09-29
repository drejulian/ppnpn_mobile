import 'app_database_helper.dart';
import '../models/user_model.dart';

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  final AppDatabaseHelper _dbHelper = AppDatabaseHelper();

  /// Mendapatkan semua users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        orderBy: 'nama ASC',
      );

      return List.generate(maps.length, (i) {
        return UserModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan daftar users. Error: $e');
    }
  }

  /// Mendapatkan user berdasarkan ID
  Future<UserModel?> getUserById(int id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return UserModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan user dengan ID $id. Error: $e');
    }
  }

  /// Mendapatkan user berdasarkan username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (maps.isNotEmpty) {
        return UserModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan user dengan username $username. Error: $e');
    }
  }

  /// Mendapatkan user berdasarkan email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (maps.isNotEmpty) {
        return UserModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan user dengan email $email. Error: $e');
    }
  }

  /// Login user dengan username/email dan password
  Future<UserModel?> loginUser(String usernameOrEmail, String password) async {
    try {
      final db = await _dbHelper.database;
      
      // Cari user berdasarkan username atau email
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: '(username = ? OR email = ?) AND password = ?',
        whereArgs: [usernameOrEmail, usernameOrEmail, password],
      );

      if (maps.isNotEmpty) {
        // Update last login
        final user = UserModel.fromMap(maps.first);
        await updateLastLogin(user.id!);
        return user;
      }
      return null;
    } catch (e) {
      throw Exception('Repository: Gagal login user. Error: $e');
    }
  }

  /// Mendapatkan users berdasarkan role
  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'role = ?',
        whereArgs: [role.toString().split('.').last],
        orderBy: 'nama ASC',
      );

      return List.generate(maps.length, (i) {
        return UserModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan users dengan role $role. Error: $e');
    }
  }

  /// Mencari users berdasarkan nama
  Future<List<UserModel>> searchUsersByName(String query) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'nama LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'nama ASC',
      );

      return List.generate(maps.length, (i) {
        return UserModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Repository: Gagal mencari users dengan nama $query. Error: $e');
    }
  }

  /// Menambah user baru
  Future<UserModel> insertUser(UserModel user) async {
    try {
      // Validasi user
      user.validate();

      // Cek apakah username sudah ada
      final existingUsername = await getUserByUsername(user.username);
      if (existingUsername != null) {
        throw Exception('Username sudah digunakan');
      }

      // Cek apakah email sudah ada
      final existingEmail = await getUserByEmail(user.email);
      if (existingEmail != null) {
        throw Exception('Email sudah digunakan');
      }

      final db = await _dbHelper.database;
      final id = await db.insert('users', user.toMap());
      
      return user.copyWith(id: id);
    } catch (e) {
      throw Exception('Repository: Gagal menambah user baru. Error: $e');
    }
  }

  /// Update user
  Future<UserModel> updateUser(UserModel user) async {
    try {
      if (user.id == null) {
        throw Exception('ID user tidak boleh null untuk update');
      }

      // Validasi user
      user.validate();

      // Cek apakah username sudah digunakan oleh user lain
      final existingUsername = await getUserByUsername(user.username);
      if (existingUsername != null && existingUsername.id != user.id) {
        throw Exception('Username sudah digunakan oleh user lain');
      }

      // Cek apakah email sudah digunakan oleh user lain
      final existingEmail = await getUserByEmail(user.email);
      if (existingEmail != null && existingEmail.id != user.id) {
        throw Exception('Email sudah digunakan oleh user lain');
      }

      final db = await _dbHelper.database;
      final count = await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );

      if (count == 0) {
        throw Exception('User dengan ID ${user.id} tidak ditemukan');
      }

      return user;
    } catch (e) {
      throw Exception('Repository: Gagal mengupdate user. Error: $e');
    }
  }

  /// Update last login timestamp
  Future<void> updateLastLogin(int userId) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'users',
        {'lastLogin': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw Exception('Repository: Gagal update last login. Error: $e');
    }
  }

  /// Update password user
  Future<void> updatePassword(int userId, String newPassword) async {
    try {
      if (newPassword.length < 6) {
        throw Exception('Password minimal 6 karakter');
      }

      final db = await _dbHelper.database;
      final count = await db.update(
        'users',
        {'password': newPassword},
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (count == 0) {
        throw Exception('User dengan ID $userId tidak ditemukan');
      }
    } catch (e) {
      throw Exception('Repository: Gagal update password. Error: $e');
    }
  }

  /// Hapus user
  Future<void> deleteUser(int id) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw Exception('User dengan ID $id tidak ditemukan');
      }
    } catch (e) {
      throw Exception('Repository: Gagal menghapus user. Error: $e');
    }
  }

  /// Mendapatkan jumlah total users
  Future<int> getTotalUsers() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
      return result.first['count'] as int;
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan total users. Error: $e');
    }
  }

  /// Mendapatkan jumlah users berdasarkan role
  Future<Map<UserRole, int>> getUserCountByRole() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT role, COUNT(*) as count 
        FROM users 
        GROUP BY role
      ''');

      Map<UserRole, int> counts = {
        UserRole.admin: 0,
        UserRole.pegawai: 0,
        UserRole.magang: 0,
      };

      for (var row in result) {
        final roleStr = row['role'] as String;
        final count = row['count'] as int;
        
        if (roleStr == 'admin') {
          counts[UserRole.admin] = count;
        } else if (roleStr == 'pegawai') {
          counts[UserRole.pegawai] = count;
        } else if (roleStr == 'magang') {
          counts[UserRole.magang] = count;
        }
      }

      return counts;
    } catch (e) {
      throw Exception('Repository: Gagal mendapatkan count users by role. Error: $e');
    }
  }

  /// Cek apakah username tersedia
  Future<bool> isUsernameAvailable(String username, {int? excludeUserId}) async {
    try {
      final user = await getUserByUsername(username);
      if (user == null) return true;
      if (excludeUserId != null && user.id == excludeUserId) return true;
      return false;
    } catch (e) {
      throw Exception('Repository: Gagal cek username availability. Error: $e');
    }
  }

  /// Cek apakah email tersedia
  Future<bool> isEmailAvailable(String email, {int? excludeUserId}) async {
    try {
      final user = await getUserByEmail(email);
      if (user == null) return true;
      if (excludeUserId != null && user.id == excludeUserId) return true;
      return false;
    } catch (e) {
      throw Exception('Repository: Gagal cek email availability. Error: $e');
    }
  }
}