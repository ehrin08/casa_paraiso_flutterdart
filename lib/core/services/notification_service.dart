import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/models.dart';

abstract class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> schedule(Appointment appointment);
  Future<void> cancel(Appointment appointment);
  Future<void> cancelAll();
}

class LocalNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

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

  int _id(Appointment appointment, int offset) =>
      (appointment.id.hashCode & 0x3fffffff) + offset;

  @override
  Future<void> schedule(Appointment appointment) async {
    if (!_isAndroid) return;
    await cancel(appointment);
    final now = DateTime.now().toUtc();
    final reminders = <(Duration, int)>[
      (const Duration(hours: 24), 1),
      (const Duration(hours: 1), 2),
    ];
    for (final (before, offset) in reminders) {
      final instant = appointment.startUtc.subtract(before);
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
