// Service detail screen — shows full package info and a "Book Now" button.
//
// Displays: arched icon header, package name, localized description,
// duration/price pills, massage styles, included treatments (if any),
// available paid extras with prices, and the primary booking CTA.
//
// Navigated to via GoRouter: /service/:id.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

class ServiceDetailScreen extends ConsumerWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});
  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.services)),
      body: ref
          .watch(catalogProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(child: Text(l10n.tryAgain)),
            data: (catalog) {
              final service = catalog.services.firstWhere(
                (item) => item.id == serviceId,
              );
              return SingleChildScrollView(
                child: ResponsivePage(
                  maxWidth: 760,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Decorative arched container with spa icon.
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.sand,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(84),
                            bottom: Radius.circular(24),
                          ),
                        ),
                        child: const Icon(
                          Icons.spa_outlined,
                          color: AppColors.palm,
                          size: 72,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        service.name,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        locale == 'fil'
                            ? service.descriptionFil
                            : service.descriptionEn,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      // Duration and price metadata pills.
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          InfoPill(
                            icon: Icons.schedule,
                            label: '${service.durationMinutes} ${l10n.minutes}',
                          ),
                          InfoPill(
                            icon: Icons.payments_outlined,
                            label: peso(service.price),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Massage style options (Swedish, Shiatsu, Traditional Hilot).
                      Text(
                        l10n.massageStyle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(catalog.massageStyles.join(' · ')),
                      // Included treatments (only for packages that have them).
                      if (service.treatments.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          l10n.includedTreatment,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(service.treatments.join(' · ')),
                      ],
                      const SizedBox(height: 24),
                      // Available paid extras with prices.
                      Text(
                        l10n.extras,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      for (final extra in catalog.extras)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add_circle_outline,
                                color: AppColors.palm,
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(extra.name)),
                              Text(
                                peso(extra.price),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 32),
                      // Navigate to the booking flow for this package.
                      FilledButton.icon(
                        onPressed: () => context.push('/book/$serviceId'),
                        icon: const Icon(Icons.calendar_month),
                        label: Text(l10n.bookNow),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
