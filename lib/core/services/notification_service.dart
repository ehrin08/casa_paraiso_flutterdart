// Notification scheduling — Android local notifications and web no-op.
//
// [NotificationService] is the abstract contract injected via Riverpod.
// [LocalNotificationService] is the concrete Android implementation that
// schedules 24-hour and 1-hour reminders for confirmed appointments.
// On web or non-Android platforms, all methods silently no-op.
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/models.dart';

/// Abstract notification contract — allows tests to mock notification behavior.
abstract class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> schedule(Appointment appointment);
  Future<void> cancel(Appointment appointment);
  Future<void> cancelAll();
}

/// Android-only notification service using flutter_local_notifications.
///
/// Each appointment gets two reminder notification IDs (24h and 1h before).
/// Rescheduling cancels old reminders and creates new ones.
/// Cancelling an appointment removes both reminders.
class LocalNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Guard: only run notification logic on Android (not web, not iOS).
  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<void> initialize() async {
    if (!_isAndroid) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    if (!_isAndroid) return false;
    return await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false;
  }

  /// Deterministic notification ID — derived from appointment ID hash + offset.
  /// Offset 1 = 24h reminder, offset 2 = 1h reminder.
  int _id(Appointment appointment, int offset) =>
      (appointment.id.hashCode & 0x3fffffff) + offset;

  @override
  Future<void> schedule(Appointment appointment) async {
    if (!_isAndroid) return;
    // Cancel any existing reminders first (handles rescheduling).
    await cancel(appointment);
    final now = DateTime.now().toUtc();
    final reminders = <(Duration, int)>[
      (const Duration(hours: 24), 1), // 24 hours before
      (const Duration(hours: 1), 2),  // 1 hour before
    ];
    for (final (before, offset) in reminders) {
      final instant = appointment.startUtc.subtract(before);
      // Only schedule if the reminder time is still in the future.
      if (!instant.isAfter(now)) continue;
      await _plugin.zonedSchedule(
        id: _id(appointment, offset),
        title: 'Casa Paraiso appointment',
        body: before.inHours == 24
            ? 'Your ${appointment.service.name} appointment is tomorrow.'
            : 'Your ${appointment.service.name} appointment starts in one hour.',
        scheduledDate: tz.TZDateTime.from(instant, tz.UTC),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'appointment_reminders',
            'Appointment reminders',
            channelDescription:
                'Reminders for confirmed Casa Paraiso appointments',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: appointment.id,
      );
    }
  }

  @override
  Future<void> cancel(Appointment appointment) async {
    if (!_isAndroid) return;
    await _plugin.cancel(id: _id(appointment, 1));
    await _plugin.cancel(id: _id(appointment, 2));
  }

  @override
  Future<void> cancelAll() async {
    if (_isAndroid) await _plugin.cancelAll();
  }
}
