// Responsive app shell — the main navigation scaffold after onboarding.
//
// Uses [LayoutBuilder] to switch between:
// - Bottom [NavigationBar] on phones (< 600dp width).
// - [NavigationRail] on tablets/desktops (≥ 600dp), extended labels at ≥ 900dp.
//
// The four primary destinations (Home, Services, Bookings, Profile) are
// maintained in an [IndexedStack] so each screen preserves its scroll
// position when the user switches tabs.
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../appointments/bookings_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../services/services_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Destination tuples: (outlined icon, filled icon, localized label).
    final destinations = [
      (Icons.home_outlined, Icons.home, l10n.home),
      (Icons.spa_outlined, Icons.spa, l10n.services),
      (Icons.calendar_month_outlined, Icons.calendar_month, l10n.bookings),
      (Icons.person_outline, Icons.person, l10n.profile),
    ];
    const pages = [
      HomeScreen(),
      ServicesScreen(),
      BookingsScreen(),
      ProfileScreen(),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 600;
        final content = IndexedStack(index: _index, children: pages);

        // Tablet / desktop layout — side navigation rail.
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: (value) =>
                        setState(() => _index = value),
                    extended: constraints.maxWidth >= 900,
                    backgroundColor: AppColors.surface,
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Icon(Icons.spa, color: AppColors.palm, size: 34),
                    ),
                    destinations: [
                      for (final item in destinations)
                        NavigationRailDestination(
                          icon: Icon(item.$1),
                          selectedIcon: Icon(item.$2),
                          label: Text(item.$3),
                        ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: content),
              ],
            ),
          );
        }

        // Phone layout — bottom navigation bar.
        return Scaffold(
          body: content,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: [
              for (final item in destinations)
                NavigationDestination(
                  icon: Icon(item.$1),
                  selectedIcon: Icon(item.$2),
                  label: item.$3,
                ),
            ],
          ),
        );
      },
    );
  }
}
