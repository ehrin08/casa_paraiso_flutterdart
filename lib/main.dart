import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'core/data/repositories.dart';
import 'core/services/notification_service.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await initializeDateFormatting('en');
  await initializeDateFormatting('fil');
  final preferences = await SharedPreferences.getInstance();
  final notifications = LocalNotificationService();
  await notifications.initialize();
  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(LocalStore(preferences)),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const CasaParaisoApp(),
    ),
  );
}
