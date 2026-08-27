// Business logic services — pricing, availability, and validation.
//
// These are pure Dart classes with no Flutter or platform dependency,
// making them easy to unit-test. [AppClock] is an injectable time source
// so tests can control "now" without real delays.
import 'dart:math';

import 'package:timezone/timezone.dart' as tz;

import '../models/models.dart';

// ---------------------------------------------------------------------------
// Clock abstraction — enables deterministic time in tests
// ---------------------------------------------------------------------------

/// Abstract clock so tests can inject a fixed time.
abstract class AppClock {
  DateTime nowUtc();
}

/// Default production clock — returns the real system time.
class SystemClock implements AppClock {
  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

// ---------------------------------------------------------------------------
// Pricing service
// ---------------------------------------------------------------------------

/// Calculates total duration and price for a package + optional extras.
///
/// Example: Hestia Warmth (90 min, ₱749) + Back Massage (30 min, ₱298)
/// = 120 min, ₱1,047.
class BookingPricingService {
  /// Total duration in minutes = base package + sum of extras' durations.
  int durationMinutes(ServicePackage service, Iterable<PaidExtra> extras) =>
      service.durationMinutes +
      extras.fold(0, (total, extra) => total + extra.durationMinutes);

  /// Total price = base package price + sum of extras' prices.
  double total(ServicePackage service, Iterable<PaidExtra> extras) =>
      service.price + extras.fold(0, (total, extra) => total + extra.price);
}

// ---------------------------------------------------------------------------
// Availability service — Manila-timezone slot generation
// ---------------------------------------------------------------------------

/// Generates bookable time slots and unique reference codes.
///
/// Business rules enforced here:
/// - Open daily 1:00 PM – 1:00 AM next day (Asia/Manila).
/// - 30-minute slot intervals; appointment must finish before closing.
/// - At least 1 hour lead time from "now".
/// - Maximum 30-day booking horizon.
/// - No overlaps with the user's own non-cancelled appointments.
class AvailabilityService {
  AvailabilityService({AppClock? clock}) : clock = clock ?? SystemClock();

  final AppClock clock;

  /// IANA timezone for the spa's location.
  final tz.Location manila = tz.getLocation('Asia/Manila');

  /// Returns available start times for a given business date.
  ///
  /// [businessDate] — the calendar date the user selected.
  /// [durationMinutes] — total duration including extras.
  /// [appointments] — the user's existing appointments (for overlap checks).
  /// [excludingAppointmentId] — skip this appointment during overlap checks
  ///   (used when rescheduling so the moved appointment doesn't block itself).
  List<tz.TZDateTime> slots({
    required DateTime businessDate,
    required int durationMinutes,
    required List<Appointment> appointments,
    String? excludingAppointmentId,
  }) {
    // Build the business window: 1 PM on the selected date → 1 AM next day.
    final day = tz.TZDateTime(
      manila,
      businessDate.year,
      businessDate.month,
      businessDate.day,
    );
    final opening = day.add(const Duration(hours: 13));
    final closing = day.add(const Duration(days: 1, hours: 1));

    // Enforce 1-hour lead time and 30-day horizon from current Manila time.
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
      // Skip past slots and slots beyond the booking horizon.
      if (cursor.isBefore(earliest) || cursor.isAfter(latestDate)) continue;

      // Check overlap with existing non-cancelled appointments.
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

  /// Generates a unique booking reference like "CP-20260828-AB3K".
  ///
  /// Uses a cryptographically secure random suffix and retries up to 20
  /// times to avoid collisions with existing references.
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
    // Fallback — virtually impossible collision case.
    return 'CP-${date.millisecondsSinceEpoch}';
  }
}

// ---------------------------------------------------------------------------
// Contact validation helpers
// ---------------------------------------------------------------------------

/// Validates and normalizes a Philippine mobile number.
///
/// Accepts "09XX…" (11 digits) or "+639XX…" (13 chars) formats.
/// Returns the normalized "+63…" string, or null if invalid.
String? validatePhilippineMobile(String input) {
  final compact = input.replaceAll(RegExp(r'[\s()-]'), '');
  if (RegExp(r'^09\d{9}$').hasMatch(compact)) {
    return '+63${compact.substring(1)}';
  }
  if (RegExp(r'^\+639\d{9}$').hasMatch(compact)) return compact;
  return null;
}

/// Returns true if the input is empty (optional) or a well-formed email.
bool isValidOptionalEmail(String input) =>
    input.trim().isEmpty ||
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(input.trim());
