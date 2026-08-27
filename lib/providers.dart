// Riverpod providers and the central [AppController] state notifier.
//
// This file wires together all dependency-injectable services:
// - [localStoreProvider] / [notificationServiceProvider]: placeholders
//   overridden in main.dart with real implementations (testable via mocks).
// - [catalogRepositoryProvider] / [catalogProvider]: loads the bundled
//   services.json spa catalog.
// - [pricingServiceProvider] / [availabilityServiceProvider]: pure business
//   logic with no platform dependency.
// - [appControllerProvider]: manages the global [AppState] (onboarding,
//   locale, profile, appointments, consent) and persists changes via
//   [LocalStore].
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/data/repositories.dart';
import 'core/models/models.dart';
import 'core/services/booking_services.dart';
import 'core/services/notification_service.dart';

// ---------------------------------------------------------------------------
// Service providers — injected via ProviderScope overrides in main.dart
// ---------------------------------------------------------------------------

/// Local persistence layer (SharedPreferences). Throws at compile time if
/// not overridden — ensures tests never accidentally hit real storage.
final localStoreProvider = Provider<LocalStore>(
  (ref) => throw UnimplementedError(),
);

/// Notification scheduling abstraction. Also requires an override.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError(),
);

/// Loads the bundled JSON catalog from assets/data/services.json.
final catalogRepositoryProvider = Provider((ref) => CatalogRepository());

/// Async catalog data — screens watch this to render service cards.
final catalogProvider = FutureProvider<Catalog>(
  (ref) => ref.read(catalogRepositoryProvider).load(),
);

/// Calculates total price and duration for a package + selected extras.
final pricingServiceProvider = Provider((ref) => BookingPricingService());

/// Generates Manila-timezone time slots and booking reference codes.
final availabilityServiceProvider = Provider((ref) => AvailabilityService());

// ---------------------------------------------------------------------------
// Central application state controller
// ---------------------------------------------------------------------------

/// Holds all user-facing mutable state and exposes actions that persist
/// changes to [LocalStore] and schedule/cancel notifications.
final appControllerProvider = NotifierProvider<AppController, AppState>(
  AppController.new,
);

class AppController extends Notifier<AppState> {
  LocalStore get _store => ref.read(localStoreProvider);
  NotificationService get _notifications =>
      ref.read(notificationServiceProvider);

  /// Called once by Riverpod — hydrates state from SharedPreferences.
  @override
  AppState build() => _store.load();

  /// Marks onboarding as finished; persists so it never shows again.
  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingComplete: true);
    await _store.saveOnboarding(true);
  }

  /// Re-enables onboarding (accessible from Profile → Replay Intro).
  Future<void> replayOnboarding() async {
    state = state.copyWith(onboardingComplete: false);
    await _store.saveOnboarding(false);
  }

  /// Switches the display language between English ('en') and Filipino ('fil').
  Future<void> setLocale(String code) async {
    state = state.copyWith(localeCode: code);
    await _store.saveLocale(code);
  }

  /// Saves or updates the guest profile (name, mobile, optional email).
  Future<void> saveProfile(CustomerProfile profile) async {
    state = state.copyWith(profile: profile);
    await _store.saveProfile(profile);
  }

  /// Records that the user accepted the local-data consent checkbox.
  Future<void> acceptConsent() async {
    state = state.copyWith(consentAccepted: true);
    await _store.saveConsent(true);
  }

  /// Persists a new appointment and schedules 24h + 1h reminders.
  Future<void> addAppointment(Appointment appointment) async {
    final updated = [...state.appointments, appointment];
    state = state.copyWith(appointments: updated);
    await _store.saveAppointments(updated);
    await _notifications.schedule(appointment);
  }

  /// Sets an appointment to cancelled status and removes its reminders.
  Future<void> cancelAppointment(String id) async {
    final original = state.appointments.firstWhere((item) => item.id == id);
    final updated = state.appointments
        .map(
          (item) => item.id == id
              ? item.copyWith(status: AppointmentStatus.cancelled)
              : item,
        )
        .toList();
    state = state.copyWith(appointments: updated);
    await _store.saveAppointments(updated);
    await _notifications.cancel(original);
  }

  /// Changes only date/time on an existing appointment; replaces reminders.
  Future<void> reschedule(String id, DateTime startUtc, DateTime endUtc) async {
    late Appointment changed;
    final updated = state.appointments.map((item) {
      if (item.id != id) return item;
      changed = item.copyWith(startUtc: startUtc, endUtc: endUtc);
      return changed;
    }).toList();
    state = state.copyWith(appointments: updated);
    await _store.saveAppointments(updated);
    await _notifications.schedule(changed);
  }

  /// Triggers the Android notification permission dialog.
  Future<bool> requestNotificationPermission() =>
      _notifications.requestPermission();

  /// Erases all local data (profile, appointments, settings, reminders).
  Future<void> reset() async {
    await _notifications.cancelAll();
    await _store.reset();
    state = const AppState();
  }
}
