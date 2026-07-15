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

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appointments = ref.watch(
      appControllerProvider.select((value) => value.appointments),
    );
    final now = DateTime.now().toUtc();
    final upcoming =
        appointments
            .where(
              (item) =>
                  item.status == AppointmentStatus.confirmed &&
                  item.endUtc.isAfter(now),
            )
            .toList()
          ..sort((a, b) => a.startUtc.compareTo(b.startUtc));
    final completed =
        appointments
            .where(
              (item) =>
                  item.status == AppointmentStatus.confirmed &&
                  !item.endUtc.isAfter(now),
            )
            .toList()
          ..sort((a, b) => b.startUtc.compareTo(a.startUtc));
    final cancelled =
        appointments
            .where((item) => item.status == AppointmentStatus.cancelled)
            .toList()
          ..sort((a, b) => b.startUtc.compareTo(a.startUtc));
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: ResponsivePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.bookings,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 18),
              TabBar(
                isScrollable: MediaQuery.sizeOf(context).width < 500,
                tabs: [
                  Tab(text: '${l10n.upcoming} (${upcoming.length})'),
                  Tab(text: '${l10n.completed} (${completed.length})'),
                  Tab(text: '${l10n.cancelled} (${cancelled.length})'),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    _AppointmentList(items: upcoming),
                    _AppointmentList(items: completed),
                    _AppointmentList(items: cancelled),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({required this.items});
  final List<Appointment> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 52,
              color: AppColors.palm,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noBookings,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final manila = tz.getLocation('Asia/Manila');
        final start = tz.TZDateTime.from(item.startUtc, manila);
        final locale = Localizations.localeOf(context).languageCode;
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(18),
            leading: const LeafMark(),
            title: Text(
              item.service.name,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${DateFormat.yMMMd(locale).format(start)} · ${DateFormat.jm(locale).format(start)}\n${item.reference}',
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/appointment/${item.id}'),
          ),
        );
      },
    );
  }
}
