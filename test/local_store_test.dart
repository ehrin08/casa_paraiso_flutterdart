import 'package:casa_paraiso/core/data/repositories.dart';
import 'package:casa_paraiso/core/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists profile and appointments as versioned local JSON', () async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalStore(await SharedPreferences.getInstance());
    const profile = CustomerProfile(name: 'Ana Cruz', mobile: '+639916522754');
    const service = ServicePackage(
      id: 'gaia_touch',
      name: 'Gaia Touch',
      price: 499,
      durationMinutes: 60,
      descriptionEn: 'English',
      descriptionFil: 'Filipino',
      treatments: [],
    );
    final appointment = Appointment(
      id: '1',
      reference: 'CP-20260715-TEST',
      service: service,
      massageStyle: 'Swedish',
      extras: const [],
      startUtc: DateTime.utc(2026, 7, 15, 6),
      endUtc: DateTime.utc(2026, 7, 15, 7),
      total: 499,
      customer: profile,
      createdAtUtc: DateTime.utc(2026, 7, 14),
    );
    await store.saveProfile(profile);
    await store.saveAppointments([appointment]);

    final loaded = store.load();
    expect(loaded.profile?.name, 'Ana Cruz');
    expect(loaded.appointments.single.reference, appointment.reference);
  });

  test('recovers only malformed appointment data', () async {
    SharedPreferences.setMockInitialValues({
      'profile.v1': '{"name":"Ana","mobile":"+639916522754","email":null}',
      'appointments.v1': 'not-json',
    });
    final store = LocalStore(await SharedPreferences.getInstance());
    final state = store.load();
    expect(state.profile?.name, 'Ana');
    expect(state.appointments, isEmpty);
    expect(state.recoveredData, isTrue);
  });
}
