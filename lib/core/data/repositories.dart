// Data access layer — catalog loading and local persistence.
//
// [CatalogRepository] reads the static JSON asset bundled with the app.
// [LocalStore] wraps SharedPreferences with versioned keys, isolating
// each data domain so a corrupt payload only affects its own segment.
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Loads the read-only spa catalog from the bundled asset.
class CatalogRepository {
  Future<Catalog> load() async {
    final raw = await rootBundle.loadString('assets/data/services.json');
    return Catalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

/// SharedPreferences-backed local persistence with per-domain error isolation.
///
/// Each data segment (onboarding, locale, profile, appointments, consent) is
/// stored under a versioned key (e.g., "profile.v1") so that future schema
/// changes can be detected and migrated without data loss.
class LocalStore {
  LocalStore(this._preferences);

  final SharedPreferences _preferences;

  // Versioned storage keys — bump the version when the schema changes.
  static const _onboardingKey = 'onboarding.v1';
  static const _localeKey = 'locale.v1';
  static const _profileKey = 'profile.v1';
  static const _appointmentsKey = 'appointments.v1';
  static const _consentKey = 'consent.v1';

  /// Hydrates [AppState] from all stored keys.
  ///
  /// If a profile or appointments payload is malformed, only that key is
  /// cleared — the other settings survive. The [AppState.recoveredData]
  /// flag signals the UI to show a recovery notice.
  AppState load() {
    var recovered = false;
    CustomerProfile? profile;
    var appointments = <Appointment>[];

    // Attempt to deserialize the profile; clear key on failure.
    try {
      final raw = _preferences.getString(_profileKey);
      if (raw != null) {
        profile = CustomerProfile.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      }
    } catch (_) {
      recovered = true;
      _preferences.remove(_profileKey);
    }

    // Attempt to deserialize the appointment list; clear key on failure.
    try {
      final raw = _preferences.getString(_appointmentsKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        appointments = (decoded['items'] as List)
            .map((item) => Appointment.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      recovered = true;
      _preferences.remove(_appointmentsKey);
    }

    return AppState(
      onboardingComplete: _preferences.getBool(_onboardingKey) ?? false,
      localeCode: _preferences.getString(_localeKey) ?? 'en',
      profile: profile,
      appointments: appointments,
      consentAccepted: _preferences.getBool(_consentKey) ?? false,
      recoveredData: recovered,
    );
  }

  // Individual save methods — each writes to its own key.
  Future<void> saveOnboarding(bool value) =>
      _preferences.setBool(_onboardingKey, value);
  Future<void> saveLocale(String value) =>
      _preferences.setString(_localeKey, value);
  Future<void> saveConsent(bool value) =>
      _preferences.setBool(_consentKey, value);
  Future<void> saveProfile(CustomerProfile profile) =>
      _preferences.setString(_profileKey, jsonEncode(profile.toJson()));
  Future<void> saveAppointments(List<Appointment> appointments) => _preferences
      .setString(_appointmentsKey, encodeAppointments(appointments));

  /// Erases all local data — called from Profile → Reset Data.
  Future<void> reset() async {
    await Future.wait([
      _preferences.remove(_onboardingKey),
      _preferences.remove(_localeKey),
      _preferences.remove(_profileKey),
      _preferences.remove(_appointmentsKey),
      _preferences.remove(_consentKey),
    ]);
  }
}
