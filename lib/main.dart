// Application entry point — bootstraps platform services before launching
// the widget tree.
//
// Initializes timezone data, date formatters for both supported locales
// (English and Filipino), SharedPreferences for local persistence, and the
// Android notification plugin. Real implementations are injected into
// Riverpod via [ProviderScope] overrides so that tests can swap them out.
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
  // Ensure Flutter engine is ready before calling async platform channels.
  WidgetsFlutterBinding.ensureInitialized();

  // Load IANA timezone database for Asia/Manila slot generation.
  tz.initializeTimeZones();

  // Pre-load date formatting symbols for bilingual date display.
  await initializeDateFormatting('en');
  await initializeDateFormatting('fil');

  // Platform services that persist across the app lifetime.
  final preferences = await SharedPreferences.getInstance();
  final notifications = LocalNotificationService();
  await notifications.initialize();

  // Launch the app, injecting real persistence and notification services.
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
