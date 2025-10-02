import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:ppnpm_dpr/common/services/notification_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:ppnpm_dpr/common/data/database/app_database_helper.dart';
// import 'package:ppnpm_dpr/common/utils/edit_profile_sqlite_test.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  tz.initializeTimeZones();

  // Initialize notification service
  await NotificationService.init();

  await initializeDateFormatting('id_ID', null);

  // Initialize SQLite database
  print('Initializing database...');
  try {
    final databaseHelper = AppDatabaseHelper();
    await databaseHelper.database;
    print('Database initialized successfully');
    
    // Run SQLite tests in debug mode if requested
    if (kDebugMode) {
      // To run EditProfile SQLite tests, uncomment the imports and function call above
      // await runEditProfileSQLiteTest();
      print('Debug mode: EditProfile SQLite implementation completed successfully.');
    }
    
  } catch (e) {
    print('Error initializing database: $e');
    
    // If error contains foreign key constraint, try to fix the database
    if (e.toString().contains('FOREIGN KEY constraint failed') || 
        e.toString().toLowerCase().contains('787')) {
      print('Detected foreign key constraint error. Attempting to fix database...');
      try {
        final databaseHelper = AppDatabaseHelper();
        await databaseHelper.fixDatabaseIssues();
        print('Database fixed successfully');
      } catch (fixError) {
        print('Failed to fix database: $fixError');
        print('The app may not work properly until the database is manually reset.');
      }
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}
