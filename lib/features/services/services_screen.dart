// Services catalog screen — displays all spa packages in a responsive grid.
//
// Uses the async [catalogProvider] to load the bundled JSON catalog.
// The grid switches from 1 column on phones to 2 columns at ≥ 800dp.
// Each item renders as a [ServiceCard] (defined in home_screen.dart)
// that navigates to the service detail screen on tap.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/common.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../home/home_screen.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(catalogProvider);
    return Scaffold(
      body: SingleChildScrollView(
        child: ResponsivePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.serviceMenu,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.serviceMenuSubtitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              catalog.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(child: Text(l10n.tryAgain)),
                data: (value) => LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 800 ? 2 : 1;
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
                      itemBuilder: (_, index) =>
                          ServiceCard(service: value.services[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
