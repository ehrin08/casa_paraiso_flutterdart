import 'package:casa_paraiso/app.dart';
import 'package:casa_paraiso/core/data/repositories.dart';
import 'package:casa_paraiso/core/models/models.dart';
import 'package:casa_paraiso/core/services/notification_service.dart';
import 'package:casa_paraiso/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

class FakeNotifications implements NotificationService {
  @override
  Future<void> cancel(Appointment appointment) async {}
  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> schedule(Appointment appointment) async {}
}

void main() {
  setUpAll(tz.initializeTimeZones);

  testWidgets('onboarding can enter the four-destination customer shell', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final store = LocalStore(await SharedPreferences.getInstance());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          notificationServiceProvider.overrideWithValue(FakeNotifications()),
        ],
        child: const CasaParaisoApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('A calmer way to choose'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Services'), findsWidgets);
    expect(find.text('Bookings'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });
}
