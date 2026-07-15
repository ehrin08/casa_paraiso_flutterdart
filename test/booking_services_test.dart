import 'package:casa_paraiso/core/models/models.dart';
import 'package:casa_paraiso/core/services/booking_services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

class FakeClock implements AppClock {
  FakeClock(this.value);
  final DateTime value;
  @override
  DateTime nowUtc() => value;
}

const service = ServicePackage(
  id: 'gaia_touch',
  name: 'Gaia Touch',
  price: 499,
  durationMinutes: 60,
  descriptionEn: 'English',
  descriptionFil: 'Filipino',
  treatments: [],
);

const backMassage = PaidExtra(
  id: 'back_massage',
  name: '30-minute Back Massage',
  price: 298,
  durationMinutes: 30,
);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('pricing includes paid extras and added duration', () {
    final pricing = BookingPricingService();
    expect(pricing.total(service, [backMassage]), 797);
    expect(pricing.durationMinutes(service, [backMassage]), 90);
  });

  test('normalizes Philippine mobile formats', () {
    expect(validatePhilippineMobile('0991 652 2754'), '+639916522754');
    expect(validatePhilippineMobile('+63 991 652 2754'), '+639916522754');
    expect(validatePhilippineMobile('12345'), isNull);
  });

  test('generates slots until cross-midnight closing time', () {
    final availability = AvailabilityService(
      clock: FakeClock(DateTime.utc(2026, 7, 1, 0)),
    );
    final slots = availability.slots(
      businessDate: DateTime(2026, 7, 2),
      durationMinutes: 120,
      appointments: const [],
    );
    expect(slots.first.hour, 13);
    expect(slots.last.hour, 23);
    expect(slots.last.minute, 0);
  });

  test('back massage moves the last valid start to 10:30 PM', () {
    final availability = AvailabilityService(
      clock: FakeClock(DateTime.utc(2026, 7, 1, 0)),
    );
    final slots = availability.slots(
      businessDate: DateTime(2026, 7, 2),
      durationMinutes: 150,
      appointments: const [],
    );
    expect(slots.last.hour, 22);
    expect(slots.last.minute, 30);
  });

  test('blocks overlapping customer appointments', () {
    final availability = AvailabilityService(
      clock: FakeClock(DateTime.utc(2026, 7, 1, 0)),
    );
    const customer = CustomerProfile(name: 'Ana', mobile: '+639916522754');
    final existing = Appointment(
      id: '1',
      reference: 'CP-20260702-TEST',
      service: service,
      massageStyle: 'Swedish',
      extras: const [],
      startUtc: DateTime.utc(2026, 7, 2, 6),
      endUtc: DateTime.utc(2026, 7, 2, 7),
      total: 499,
      customer: customer,
      createdAtUtc: DateTime.utc(2026, 7, 1),
    );
    final slots = availability.slots(
      businessDate: DateTime(2026, 7, 2),
      durationMinutes: 60,
      appointments: [existing],
    );
    expect(slots.where((item) => item.toUtc() == existing.startUtc), isEmpty);
  });

  test('validates optional email', () {
    expect(isValidOptionalEmail(''), isTrue);
    expect(isValidOptionalEmail('guest@example.com'), isTrue);
    expect(isValidOptionalEmail('invalid'), isFalse);
  });
}
