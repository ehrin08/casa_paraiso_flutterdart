// Root application widget and first-launch onboarding gate.
//
// [CasaParaisoApp] configures Material 3 theming, bilingual localization,
// and hash-based GoRouter navigation. [OnboardingGate] decides whether the
// user sees the three-slide onboarding or the main [AppShell].
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

/// GoRouter configuration — hash-based URLs for GitHub Pages compatibility.
/// Routes: / (shell or onboarding), /service/:id, /book/:id, /appointment/:id.
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

/// Top-level Material 3 app — watches the locale from [AppController] so
/// the entire widget tree rebuilds when the user switches language.
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

/// Gate widget — shows onboarding slides on first launch; once completed
/// (or skipped), displays the main [AppShell] with bottom/rail navigation.
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
