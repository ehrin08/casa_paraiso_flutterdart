import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/data/repositories.dart';
import 'core/models/models.dart';
import 'core/services/booking_services.dart';
import 'core/services/notification_service.dart';

final localStoreProvider = Provider<LocalStore>(
  (ref) => throw UnimplementedError(),
);
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError(),
);
final catalogRepositoryProvider = Provider((ref) => CatalogRepository());
final catalogProvider = FutureProvider<Catalog>(
  (ref) => ref.read(catalogRepositoryProvider).load(),
);
final pricingServiceProvider = Provider((ref) => BookingPricingService());
final availabilityServiceProvider = Provider((ref) => AvailabilityService());

final appControllerProvider = NotifierProvider<AppController, AppState>(
  AppController.new,
);

class AppController extends Notifier<AppState> {
  LocalStore get _store => ref.read(localStoreProvider);
  NotificationService get _notifications =>
      ref.read(notificationServiceProvider);

  @override
  AppState build() => _store.load();

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingComplete: true);
    await _store.saveOnboarding(true);
  }

  Future<void> replayOnboarding() async {
    state = state.copyWith(onboardingComplete: false);
    await _store.saveOnboarding(false);
  }

  Future<void> setLocale(String code) async {
    state = state.copyWith(localeCode: code);
    await _store.saveLocale(code);
  }

  Future<void> saveProfile(CustomerProfile profile) async {
    state = state.copyWith(profile: profile);
    await _store.saveProfile(profile);
  }

  Future<void> acceptConsent() async {
    state = state.copyWith(consentAccepted: true);
    await _store.saveConsent(true);
  }

  Future<void> addAppointment(Appointment appointment) async {
    final updated = [...state.appointments, appointment];
    state = state.copyWith(appointments: updated);
    await _store.saveAppointments(updated);
    await _notifications.schedule(appointment);
  }

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

  Future<bool> requestNotificationPermission() =>
      _notifications.requestPermission();

  Future<void> reset() async {
    await _notifications.cancelAll();
    await _store.reset();
    state = const AppState();
  }
}
