import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/appointments/appointment_detail_screen.dart';
import 'features/booking/booking_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/services/service_detail_screen.dart';
import 'features/shell/app_shell.dart';
import 'l10n/app_localizations.dart';
import 'providers.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const OnboardingGate()),
    GoRoute(
      path: '/service/:id',
      builder: (_, state) =>
          ServiceDetailScreen(serviceId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/book/:id',
      builder: (_, state) =>
          BookingScreen(serviceId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/appointment/:id',
      builder: (_, state) =>
          AppointmentDetailScreen(appointmentId: state.pathParameters['id']!),
    ),
  ],
);

class CasaParaisoApp extends ConsumerWidget {
  const CasaParaisoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeCode = ref.watch(
      appControllerProvider.select((value) => value.localeCode),
    );
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Casa Paraiso',
      theme: buildCasaTheme(),
      locale: Locale(localeCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}

class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complete = ref.watch(
      appControllerProvider.select((value) => value.onboardingComplete),
    );
    return complete ? const AppShell() : const OnboardingScreen();
  }
}
