// Appointment detail screen — full record view with reschedule/cancel actions.
//
// Shows all booking details (service, style, treatment, extras, date/time,
// customer info, total, reference). Reschedule and Cancel buttons appear
// only for confirmed appointments whose start time is still in the future.
//
// Navigation: /appointment/:id via GoRouter.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

class AppointmentDetailScreen extends ConsumerWidget {
  const AppointmentDetailScreen({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(
      appControllerProvider.select((value) => value.appointments),
    );
    final appointment = items
        .where((item) => item.id == appointmentId)
        .firstOrNull;
    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.noBookings)),
      );
    }
    final manila = tz.getLocation('Asia/Manila');
    final start = tz.TZDateTime.from(appointment.startUtc, manila);
    final end = tz.TZDateTime.from(appointment.endUtc, manila);
    final locale = Localizations.localeOf(context).languageCode;

    // Can only modify if confirmed and appointment hasn't started yet.
    final canChange =
        appointment.status == AppointmentStatus.confirmed &&
        appointment.startUtc.isAfter(DateTime.now().toUtc());

    // Detail rows — dynamically built based on what data is present.
    final rows = <(String, String)>[
      (l10n.bookingReference, appointment.reference),
      (l10n.services, appointment.service.name),
      (l10n.massageStyle, appointment.massageStyle),
      if (appointment.treatment != null)
        (l10n.includedTreatment, appointment.treatment!),
      if (appointment.extras.isNotEmpty)
        (l10n.extras, appointment.extras.map((item) => item.name).join(', ')),
      (
        l10n.dateAndTime,
        '${DateFormat.yMMMMd(locale).format(start)} · ${DateFormat.jm(locale).format(start)}–${DateFormat.jm(locale).format(end)}',
      ),
      (l10n.fullName, appointment.customer.name),
      (l10n.mobileNumber, appointment.customer.mobile),
      if (appointment.notes != null) (l10n.notesOptional, appointment.notes!),
      (l10n.total, peso(appointment.total)),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appointmentDetails)),
      body: SingleChildScrollView(
        child: ResponsivePage(
          maxWidth: 760,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with leaf badge and service name.
              Row(
                children: [
                  const LeafMark(size: 52),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      appointment.service.name,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Detail card with label–value rows.
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      for (final row in rows)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 150,
                                child: Text(
                                  row.$1,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SelectableText(
                                  row.$2,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(l10n.payAtSpa),
                      ),
                    ],
                  ),
                ),
              ),
              // Reschedule and Cancel buttons (only for modifiable appointments).
              if (canChange) ...[
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () =>
                          _showReschedule(context, ref, appointment),
                      icon: const Icon(Icons.edit_calendar_outlined),
                      label: Text(l10n.reschedule),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _confirmCancel(context, ref, appointment),
                      icon: const Icon(Icons.cancel_outlined),
                      label: Text(l10n.cancelBooking),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before cancelling; updates state and
  /// removes scheduled reminders on confirmation.
  Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref,
    Appointment appointment,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmCancel),
        content: Text('${appointment.service.name} · ${appointment.reference}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.keepBooking),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.cancelBooking),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(appControllerProvider.notifier)
          .cancelAppointment(appointment.id);
    }
  }

  /// Opens a dialog to pick a new date/time. Uses [AvailabilityService.slots]
  /// with [excludingAppointmentId] so the appointment being moved doesn't
  /// block its own time window during overlap checks.
  Future<void> _showReschedule(
    BuildContext context,
    WidgetRef ref,
    Appointment appointment,
  ) async {
    final locale = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context);
    final manila = tz.getLocation('Asia/Manila');
    DateTime? date = tz.TZDateTime.from(appointment.startUtc, manila);
    tz.TZDateTime? selected;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final duration = appointment.endUtc
              .difference(appointment.startUtc)
              .inMinutes;
          final slots = ref
              .read(availabilityServiceProvider)
              .slots(
                businessDate: date!,
                durationMinutes: duration,
                appointments: ref.read(appControllerProvider).appointments,
                excludingAppointmentId: appointment.id,
              );
          return AlertDialog(
            title: Text(l10n.reschedule),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date!,
                          firstDate: DateTime(now.year, now.month, now.day),
                          lastDate: now.add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            date = picked;
                            selected = null;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(DateFormat.yMMMMd(locale).format(date!)),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final slot in slots)
                          ChoiceChip(
                            label: Text(DateFormat.jm(locale).format(slot)),
                            selected: selected == slot,
                            onSelected: (_) =>
                                setDialogState(() => selected = slot),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.back),
              ),
              FilledButton(
                onPressed: selected == null
                    ? null
                    : () async {
                        final start = selected!.toUtc();
                        await ref
                            .read(appControllerProvider.notifier)
                            .reschedule(
                              appointment.id,
                              start,
                              start.add(Duration(minutes: duration)),
                            );
                        if (context.mounted) Navigator.pop(context);
                      },
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
  }
}
