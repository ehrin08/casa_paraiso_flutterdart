// Home screen — the landing page after onboarding.
//
// Displays: logo, data-recovery notice (if any), web reminder card for
// appointments within 24 hours, a hero banner with business hours and
// a "Book Now" call-to-action, a responsive grid of featured service cards,
// and contact shortcuts (call, message, directions).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../contact/contact_actions.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(catalogProvider);
    final state = ref.watch(appControllerProvider);
    final manila = tz.getLocation('Asia/Manila');
    final now = DateTime.now().toUtc();

    // Filter and sort upcoming confirmed appointments for the reminder card.
    final upcoming =
        state.appointments
            .where(
              (item) =>
                  item.status == AppointmentStatus.confirmed &&
                  item.startUtc.isAfter(now),
            )
            .toList()
          ..sort((a, b) => a.startUtc.compareTo(b.startUtc));

    // Show a web-based reminder if the next appointment is within 24 hours.
    final reminder =
        upcoming.isNotEmpty &&
        upcoming.first.startUtc.difference(now) <= const Duration(hours: 24);

    return Scaffold(
      body: SingleChildScrollView(
        child: ResponsivePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppLogo(height: 64),
              const SizedBox(height: 20),
              // Data recovery notice — shown when a corrupt payload was cleared.
              if (state.recoveredData)
                Card(
                  color: const Color(0xFFFFF1E8),
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(l10n.dataRecovered),
                  ),
                ),
              // Web reminder card — in-app alternative to push notifications.
              if (reminder)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    color: AppColors.sand,
                    child: ListTile(
                      leading: const Icon(
                        Icons.notifications_active_outlined,
                        color: AppColors.palm,
                      ),
                      title: Text(l10n.webReminder),
                      subtitle: Text(
                        '${upcoming.first.service.name} · ${_formatDate(upcoming.first.startUtc, manila, state.localeCode)}',
                      ),
                      onTap: () =>
                          context.push('/appointment/${upcoming.first.id}'),
                    ),
                  ),
                ),
              // Hero banner with spa image, business hours, and Book Now CTA.
              _Hero(
                l10n: l10n,
                onBook: () => context.push('/service/gaia_touch'),
              ),
              const SizedBox(height: 32),
              // Featured service packages grid — responsive columns.
              SectionHeader(title: l10n.featuredServices),
              const SizedBox(height: 16),
              catalog.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(child: Text(l10n.tryAgain)),
                data: (value) => LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 760 ? 2 : 1;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisExtent: 250,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: value.services.length,
                      itemBuilder: (context, index) =>
                          ServiceCard(service: value.services[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Contact section — address, landmark, and action buttons.
              SectionHeader(title: l10n.contactUs),
              const SizedBox(height: 12),
              Text(
                l10n.address,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(l10n.landmark),
              const SizedBox(height: 16),
              const ContactActionRow(),
            ],
          ),
        ),
      ),
    );
  }

  /// Formats a UTC DateTime for display in Manila timezone.
  String _formatDate(DateTime utc, tz.Location location, String locale) {
    final local = tz.TZDateTime.from(utc, location);
    return DateFormat.yMMMd(locale).add_jm().format(local);
  }
}

/// Full-width hero banner with the spa still-life image, gradient overlay,
/// headline, subtitle, business hours pill, and primary booking button.
class _Hero extends StatelessWidget {
  const _Hero({required this.l10n, required this.onBook});
  final AppLocalizations l10n;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.vertical(
      top: Radius.circular(72),
      bottom: Radius.circular(24),
    ),
    child: SizedBox(
      height: MediaQuery.sizeOf(context).width >= 700 ? 620 : 760,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background spa banner image.
          Image.asset(
            'assets/images/home_spa_banner.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          // Dark gradient overlay for text readability.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x22000000), Color(0xDD211811)],
              ),
            ),
          ),
          // Text content anchored at the bottom of the hero.
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  l10n.reserveHeadline,
                  style:
                      (MediaQuery.sizeOf(context).width < 420
                              ? Theme.of(context).textTheme.headlineLarge
                              : Theme.of(context).textTheme.displayMedium)
                          ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.reserveSubtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 16),
                // Business hours pill.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 18,
                        color: AppColors.palm,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.openEveryDay,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onBook,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(l10n.bookNow),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// A branded card for a single service package — shows leaf icon, price,
/// name, description, and duration pill. Taps navigate to the detail screen.
class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service});
  final ServicePackage service;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/service/${service.id}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const LeafMark(),
                  const Spacer(),
                  Text(
                    peso(service.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.cacao,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                service.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                locale == 'fil'
                    ? service.descriptionFil
                    : service.descriptionEn,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              InfoPill(
                icon: Icons.schedule,
                label: '${service.durationMinutes} min',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
