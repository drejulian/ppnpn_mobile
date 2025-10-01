import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:ppnpm_dpr/common/services/notification_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:ppnpm_dpr/common/data/database/app_database_helper.dart';

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
    
  } catch (e) {
    print('Error initializing database: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}
