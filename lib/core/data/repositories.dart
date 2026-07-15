import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class CatalogRepository {
  Future<Catalog> load() async {
    final raw = await rootBundle.loadString('assets/data/services.json');
    return Catalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

class LocalStore {
  LocalStore(this._preferences);

  final SharedPreferences _preferences;

  static const _onboardingKey = 'onboarding.v1';
  static const _localeKey = 'locale.v1';
  static const _profileKey = 'profile.v1';
  static const _appointmentsKey = 'appointments.v1';
  static const _consentKey = 'consent.v1';

  AppState load() {
    var recovered = false;
    CustomerProfile? profile;
    var appointments = <Appointment>[];
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
