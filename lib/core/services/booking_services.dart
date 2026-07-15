import 'dart:math';

import 'package:timezone/timezone.dart' as tz;

import '../models/models.dart';

abstract class AppClock {
  DateTime nowUtc();
}

class SystemClock implements AppClock {
  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

class BookingPricingService {
  int durationMinutes(ServicePackage service, Iterable<PaidExtra> extras) =>
      service.durationMinutes +
      extras.fold(0, (total, extra) => total + extra.durationMinutes);

  double total(ServicePackage service, Iterable<PaidExtra> extras) =>
      service.price + extras.fold(0, (total, extra) => total + extra.price);
}

class AvailabilityService {
  AvailabilityService({AppClock? clock}) : clock = clock ?? SystemClock();

  final AppClock clock;
  final tz.Location manila = tz.getLocation('Asia/Manila');

  List<tz.TZDateTime> slots({
    required DateTime businessDate,
    required int durationMinutes,
    required List<Appointment> appointments,
    String? excludingAppointmentId,
  }) {
    final day = tz.TZDateTime(
      manila,
      businessDate.year,
      businessDate.month,
      businessDate.day,
    );
    final opening = day.add(const Duration(hours: 13));
    final closing = day.add(const Duration(days: 1, hours: 1));
    final earliest = tz.TZDateTime.from(
      clock.nowUtc(),
      manila,
    ).add(const Duration(hours: 1));
    final latestDate = tz.TZDateTime.from(
      clock.nowUtc(),
      manila,
    ).add(const Duration(days: 30));
    final result = <tz.TZDateTime>[];
    for (
      var cursor = opening;
      !cursor.add(Duration(minutes: durationMinutes)).isAfter(closing);
      cursor = cursor.add(const Duration(minutes: 30))
    ) {
      if (cursor.isBefore(earliest) || cursor.isAfter(latestDate)) continue;
      final end = cursor.add(Duration(minutes: durationMinutes));
      final overlaps = appointments.where((item) {
        if (item.id == excludingAppointmentId ||
            item.status == AppointmentStatus.cancelled) {
          return false;
        }
        final existingStart = item.startUtc;
        final existingEnd = item.endUtc;
        return cursor.toUtc().isBefore(existingEnd) &&
            end.toUtc().isAfter(existingStart);
      }).isNotEmpty;
      if (!overlaps) result.add(cursor);
    }
    return result;
  }

  String createReference(DateTime startUtc, Iterable<String> existing) {
    final date = tz.TZDateTime.from(startUtc, manila);
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    for (var attempt = 0; attempt < 20; attempt++) {
      final suffix = List.generate(
        4,
        (_) => chars[random.nextInt(chars.length)],
      ).join();
      final reference =
          'CP-${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}-$suffix';
      if (!existing.contains(reference)) return reference;
    }
    return 'CP-${date.millisecondsSinceEpoch}';
  }
}

String? validatePhilippineMobile(String input) {
  final compact = input.replaceAll(RegExp(r'[\s()-]'), '');
  if (RegExp(r'^09\d{9}$').hasMatch(compact)) {
    return '+63${compact.substring(1)}';
  }
  if (RegExp(r'^\+639\d{9}$').hasMatch(compact)) return compact;
  return null;
}

bool isValidOptionalEmail(String input) =>
    input.trim().isEmpty ||
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(input.trim());
