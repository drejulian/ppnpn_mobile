import 'package:intl/intl.dart';
import '../database/app_database_helper.dart';
import '../models/absensi_model.dart';

class AbsensiRepository {
  static final AbsensiRepository _instance = AbsensiRepository._internal();
  factory AbsensiRepository() => _instance;
  AbsensiRepository._internal();

  static AbsensiRepository get instance => _instance;

  AppDatabaseHelper get _dbHelper => AppDatabaseHelper.instance;

  // Insert new absensi record
  Future<int> insertAbsensi(AbsensiModel absensi) async {
    final db = await _dbHelper.database;
    return await db.insert('absensi', absensi.toMap());
  }

  // Get absensi records for a specific date and user
  Future<List<AbsensiModel>> getAbsensiByDate(int userId, String date) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'absensi',
      where: 'user_id = ? AND tanggal = ?',
      whereArgs: [userId, date],
      orderBy: 'jam ASC',
    );

    return List.generate(maps.length, (i) => AbsensiModel.fromMap(maps[i]));
  }

  // Get specific type of absensi for today
  Future<AbsensiModel?> getTodayAbsensiByType(int userId, String type) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'absensi',
      where: 'user_id = ? AND tanggal = ? AND type = ?',
      whereArgs: [userId, today, type],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return AbsensiModel.fromMap(maps.first);
    }
    return null;
  }

  // Check if user can check out (must have checked in first)
  Future<bool> canCheckOut(int userId) async {
    final checkin = await getTodayAbsensiByType(userId, 'checkin');
    final checkout = await getTodayAbsensiByType(userId, 'checkout');
    
    return checkin != null && checkout == null;
  }

  // Check if user can check in (no checkin today)
  Future<bool> canCheckIn(int userId) async {
    final checkin = await getTodayAbsensiByType(userId, 'checkin');
    return checkin == null;
  }

  // Get absensi records for a specific month
  Future<List<AbsensiModel>> getAbsensiByMonth(int userId, int year, int month) async {
    final db = await _dbHelper.database;
    
    // Format: YYYY-MM
    final monthStr = '$year-${month.toString().padLeft(2, '0')}';
    
    final List<Map<String, dynamic>> maps = await db.query(
      'absensi',
      where: 'user_id = ? AND tanggal LIKE ?',
      whereArgs: [userId, '$monthStr%'],
      orderBy: 'tanggal ASC, jam ASC',
    );

    return List.generate(maps.length, (i) => AbsensiModel.fromMap(maps[i]));
  }

  // Get monthly statistics for the last 12 months
  Future<List<AbsensiMonthlyStats>> getMonthlyStats(int userId) async {
    final List<AbsensiMonthlyStats> stats = [];
    final now = DateTime.now();

    for (int i = 0; i < 12; i++) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final year = targetDate.year;
      final month = targetDate.month;
      
      final monthData = await getAbsensiByMonth(userId, year, month);
      
      // Group by date to get daily attendance
      final Map<String, List<AbsensiModel>> dailyRecords = {};
      for (final record in monthData) {
        if (!dailyRecords.containsKey(record.tanggal)) {
          dailyRecords[record.tanggal] = [];
        }
        dailyRecords[record.tanggal]!.add(record);
      }

      // Calculate working days in month (excluding weekends)
      final daysInMonth = DateTime(year, month + 1, 0).day;
      int workingDays = 0;
      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(year, month, day);
        if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
          workingDays++;
        }
      }

      // Count present days and late days
      int presentDays = 0;
      int lateDays = 0;

      dailyRecords.forEach((date, records) {
        final checkin = records.where((r) => r.type == 'checkin').firstOrNull;
        if (checkin != null) {
          presentDays++;
          
          // Check if late (after 08:00)
          final jamParts = checkin.jam.split(':');
          final hour = int.parse(jamParts[0]);
          final minute = int.parse(jamParts[1]);
          
          if (hour > 8 || (hour == 8 && minute > 0)) {
            lateDays++;
          }
        }
      });

      final attendancePercentage = workingDays > 0 ? (presentDays / workingDays) * 100 : 0.0;

      stats.add(AbsensiMonthlyStats(
        month: DateFormat('MMMM', 'id_ID').format(targetDate),
        year: year.toString(),
        totalWorkingDays: workingDays,
        presentDays: presentDays,
        lateDays: lateDays,
        attendancePercentage: attendancePercentage,
      ));
    }

    return stats;
  }

  // Update absensi record
  Future<int> updateAbsensi(AbsensiModel absensi) async {
    final db = await _dbHelper.database;
    return await db.update(
      'absensi',
      absensi.toMap(),
      where: 'id = ?',
      whereArgs: [absensi.id],
    );
  }

  // Delete absensi record
  Future<int> deleteAbsensi(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'absensi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get all absensi records for a user
  Future<List<AbsensiModel>> getAllAbsensiByUser(int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'absensi',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'tanggal DESC, jam DESC',
    );

    return List.generate(maps.length, (i) => AbsensiModel.fromMap(maps[i]));
  }

  // Check if user has already completed attendance for today
  Future<bool> hasCompletedTodayAttendance(int userId) async {
    final checkin = await getTodayAbsensiByType(userId, 'checkin');
    final checkout = await getTodayAbsensiByType(userId, 'checkout');
    
    return checkin != null && checkout != null;
  }

  // Get today's attendance status
  Future<Map<String, AbsensiModel?>> getTodayAttendanceStatus(int userId) async {
    final checkin = await getTodayAbsensiByType(userId, 'checkin');
    final checkout = await getTodayAbsensiByType(userId, 'checkout');
    
    return {
      'checkin': checkin,
      'checkout': checkout,
    };
  }

  // Clear old records (optional - for data management)
  Future<int> clearOldRecords(int daysToKeep) async {
    final db = await _dbHelper.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    final cutoffDateStr = DateFormat('yyyy-MM-dd').format(cutoffDate);
    
    return await db.delete(
      'absensi',
      where: 'tanggal < ?',
      whereArgs: [cutoffDateStr],
    );
  }

  // Get attendance streak (consecutive days with checkin)
  Future<int> getAttendanceStreak(int userId) async {
    final db = await _dbHelper.database;
    
    // Get distinct dates with checkin, ordered by date descending
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT tanggal 
      FROM absensi 
      WHERE user_id = ? AND type = 'checkin'
      ORDER BY tanggal DESC
    ''', [userId]);

    if (maps.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    for (final map in maps) {
      final expectedDate = currentDate.subtract(Duration(days: streak));
      
      // Skip weekends
      while (expectedDate.weekday == DateTime.saturday || 
             expectedDate.weekday == DateTime.sunday) {
        currentDate = currentDate.subtract(Duration(days: 1));
        continue;
      }
      
      if (DateFormat('yyyy-MM-dd').format(expectedDate) == map['tanggal']) {
        streak++;
        currentDate = currentDate.subtract(Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}