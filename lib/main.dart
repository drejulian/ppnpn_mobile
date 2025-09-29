import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:ppnpm_dpr/common/services/notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  // Initialize notification service
  await NotificationService.init();

  await initializeDateFormatting('id_ID', null);

  runApp(const ProviderScope(child: MyApp()));
}
