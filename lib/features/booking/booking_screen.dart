import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/models/models.dart';
import '../../core/services/booking_services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.serviceId});
  final String serviceId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _notes = TextEditingController();
  String? _style;
  String? _treatment;
  final Set<String> _extraIds = {};
  DateTime? _businessDate;
  tz.TZDateTime? _start;
  bool _consent = false;
  var _step = 0;
  Appointment? _confirmed;

  @override
  void initState() {
    super.initState();
    final state = ref.read(appControllerProvider);
    final profile = state.profile;
    if (profile != null) {
      _name.text = profile.name;
      _mobile.text = profile.mobile;
      _email.text = profile.email ?? '';
    }
    _consent = state.consentAccepted;
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _email.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_confirmed != null) return _Confirmation(appointment: _confirmed!);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookNow)),
      body: ref
          .watch(catalogProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(child: Text(l10n.tryAgain)),
            data: (catalog) {
              final service = catalog.services.firstWhere(
                (item) => item.id == widget.serviceId,
              );
              final extras = catalog.extras
                  .where((item) => _extraIds.contains(item.id))
                  .toList();
              final pricing = ref.read(pricingServiceProvider);
              final duration = pricing.durationMinutes(service, extras);
              final total = pricing.total(service, extras);
              return SingleChildScrollView(
                child: ResponsivePage(
                  maxWidth: 800,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          InfoPill(
                            icon: Icons.schedule,
                            label: '$duration ${l10n.minutes}',
                          ),
                          InfoPill(
                            icon: Icons.payments_outlined,
                            label: peso(total),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _Progress(current: _step),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: switch (_step) {
                          0 => _OptionsStep(
                            key: const ValueKey(0),
                            catalog: catalog,
                            service: service,
                            style: _style,
                            treatment: _treatment,
                            extraIds: _extraIds,
                            onStyle: (value) => setState(() => _style = value),
                            onTreatment: (value) =>
                                setState(() => _treatment = value),
                            onExtra: (id, selected) => setState(() {
                              selected
                                  ? _extraIds.add(id)
                                  : _extraIds.remove(id);
                              _start = null;
                            }),
                          ),
                          1 => _DateTimeStep(
                            key: const ValueKey(1),
                            durationMinutes: duration,
                            businessDate: _businessDate,
                            selectedStart: _start,
                            onDate: (value) => setState(() {
                              _businessDate = value;
                              _start = null;
                            }),
                            onStart: (value) => setState(() => _start = value),
                          ),
                          2 => _DetailsStep(
                            key: const ValueKey(2),
                            formKey: _formKey,
                            name: _name,
                            mobile: _mobile,
                            email: _email,
                            notes: _notes,
                            consent: _consent,
                            onConsent: (value) =>
                                setState(() => _consent = value ?? false),
                          ),
                          _ => _ReviewStep(
                            key: const ValueKey(3),
                            service: service,
                            style: _style!,
                            treatment: _treatment,
                            extras: extras,
                            start: _start!,
                            durationMinutes: duration,
                            total: total,
                            name: _name.text.trim(),
                            mobile: validatePhilippineMobile(_mobile.text)!,
                            email: _email.text.trim(),
                            notes: _notes.text.trim(),
                          ),
                        },
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          if (_step > 0)
                            OutlinedButton.icon(
                              onPressed: () => setState(() => _step--),
                              icon: const Icon(Icons.arrow_back),
                              label: Text(l10n.back),
                            ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: () => _advance(
                              catalog,
                              service,
                              extras,
                              duration,
                              total,
                            ),
                            icon: Icon(
                              _step == 3 ? Icons.check : Icons.arrow_forward,
                            ),
                            label: Text(
                              _step == 3
                                  ? l10n.confirmBooking
                                  : l10n.continueLabel,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Future<void> _advance(
    Catalog catalog,
    ServicePackage service,
    List<PaidExtra> extras,
    int duration,
    double total,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (_step == 0) {
      if (_style == null ||
          (service.treatments.isNotEmpty && _treatment == null)) {
        _showError(l10n.selectOption);
        return;
      }
    } else if (_step == 1) {
      if (_start == null) {
        _showError(l10n.selectDateTime);
        return;
      }
    } else if (_step == 2) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      if (!_consent) {
        _showError(l10n.consentTitle);
        return;
      }
    } else {
      final controller = ref.read(appControllerProvider.notifier);
      final normalized = validatePhilippineMobile(_mobile.text)!;
      final customer = CustomerProfile(
        name: _name.text.trim(),
        mobile: normalized,
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      );
      await controller.saveProfile(customer);
      if (!ref.read(appControllerProvider).consentAccepted) {
        await controller.acceptConsent();
      }
      final availability = ref.read(availabilityServiceProvider);
      final start = _start!.toUtc();
      final appointment = Appointment(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        reference: availability.createReference(
          start,
          ref
              .read(appControllerProvider)
              .appointments
              .map((item) => item.reference),
        ),
        service: service,
        massageStyle: _style!,
        treatment: _treatment,
        extras: extras,
        startUtc: start,
        endUtc: start.add(Duration(minutes: duration)),
        total: total,
        customer: customer,
        createdAtUtc: DateTime.now().toUtc(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      await controller.addAppointment(appointment);
      if (!mounted) return;
      setState(() => _confirmed = appointment);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _offerNotifications(),
      );
      return;
    }
    setState(() => _step++);
  }

  Future<void> _offerNotifications() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.notifications),
        content: Text(l10n.notificationsDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.done),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.continueLabel),
          ),
        ],
      ),
    );
    if (accepted == true) {
      await ref
          .read(appControllerProvider.notifier)
          .requestNotificationPermission();
    }
  }

  void _showError(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

class _Progress extends StatelessWidget {
  const _Progress({required this.current});
  final int current;
  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(4, (index) {
      final active = index <= current;
      return Expanded(
        child: Container(
          margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
          height: 5,
          decoration: BoxDecoration(
            color: active ? AppColors.cacao : AppColors.sand,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      );
    }),
  );
}

class _OptionsStep extends StatelessWidget {
  const _OptionsStep({
    super.key,
    required this.catalog,
    required this.service,
    required this.style,
    required this.treatment,
    required this.extraIds,
    required this.onStyle,
    required this.onTreatment,
    required this.onExtra,
  });
  final Catalog catalog;
  final ServicePackage service;
  final String? style;
  final String? treatment;
  final Set<String> extraIds;
  final ValueChanged<String?> onStyle;
  final ValueChanged<String?> onTreatment;
  final void Function(String, bool) onExtra;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.massageStyle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in catalog.massageStyles)
              ChoiceChip(
                label: Text(item),
                selected: style == item,
                onSelected: (_) => onStyle(item),
              ),
          ],
        ),
        if (service.treatments.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            l10n.includedTreatment,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in service.treatments)
                ChoiceChip(
                  label: Text(item),
                  selected: treatment == item,
                  onSelected: (_) => onTreatment(item),
                ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        Text(l10n.extras, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final extra in catalog.extras)
          CheckboxListTile(
            value: extraIds.contains(extra.id),
            onChanged: (value) => onExtra(extra.id, value ?? false),
            contentPadding: EdgeInsets.zero,
            title: Text(extra.name),
            subtitle: Text(
              '${peso(extra.price)}${extra.durationMinutes > 0 ? ' · +${extra.durationMinutes} min' : ''}',
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
      ],
    );
  }
}

class _DateTimeStep extends ConsumerWidget {
  const _DateTimeStep({
    super.key,
    required this.durationMinutes,
    required this.businessDate,
    required this.selectedStart,
    required this.onDate,
    required this.onStart,
  });
  final int durationMinutes;
  final DateTime? businessDate;
  final tz.TZDateTime? selectedStart;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<tz.TZDateTime> onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appointments = ref.watch(
      appControllerProvider.select((value) => value.appointments),
    );
    final slots = businessDate == null
        ? <tz.TZDateTime>[]
        : ref
              .read(availabilityServiceProvider)
              .slots(
                businessDate: businessDate!,
                durationMinutes: durationMinutes,
                appointments: appointments,
              );
    final locale = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dateAndTime, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: businessDate ?? now,
              firstDate: DateTime(now.year, now.month, now.day),
              lastDate: now.add(const Duration(days: 30)),
            );
            if (picked != null) onDate(picked);
          },
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text(
            businessDate == null
                ? l10n.dateAndTime
                : DateFormat.yMMMMd(locale).format(businessDate!),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.localOnlyAvailability,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        if (businessDate != null && slots.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(l10n.selectDateTime),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final slot in slots)
                ChoiceChip(
                  label: Text(DateFormat.jm(locale).format(slot)),
                  selected: selectedStart == slot,
                  onSelected: (_) => onStart(slot),
                ),
            ],
          ),
      ],
    );
  }
}

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    super.key,
    required this.formKey,
    required this.name,
    required this.mobile,
    required this.email,
    required this.notes,
    required this.consent,
    required this.onConsent,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController mobile;
  final TextEditingController email;
  final TextEditingController notes;
  final bool consent;
  final ValueChanged<bool?> onConsent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.customerDetails,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: name,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.fullName,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (value) => value == null || value.trim().length < 2
                ? l10n.requiredField
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: mobile,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.mobileNumber,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            validator: (value) => validatePhilippineMobile(value ?? '') == null
                ? l10n.invalidMobile
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.emailOptional,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (value) =>
                isValidOptionalEmail(value ?? '') ? null : l10n.invalidEmail,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: notes,
            maxLength: 250,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.notesOptional,
              alignLabelWithHint: true,
            ),
          ),
          CheckboxListTile(
            value: consent,
            onChanged: onConsent,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(l10n.consentTitle),
            subtitle: Text(l10n.consentBody),
          ),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    super.key,
    required this.service,
    required this.style,
    required this.treatment,
    required this.extras,
    required this.start,
    required this.durationMinutes,
    required this.total,
    required this.name,
    required this.mobile,
    required this.email,
    required this.notes,
  });
  final ServicePackage service;
  final String style;
  final String? treatment;
  final List<PaidExtra> extras;
  final tz.TZDateTime start;
  final int durationMinutes;
  final double total;
  final String name;
  final String mobile;
  final String email;
  final String notes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final rows = <(String, String)>[
      (l10n.services, service.name),
      (l10n.massageStyle, style),
      if (treatment != null) (l10n.includedTreatment, treatment!),
      if (extras.isNotEmpty)
        (l10n.extras, extras.map((item) => item.name).join(', ')),
      (
        l10n.dateAndTime,
        '${DateFormat.yMMMMd(locale).format(start)} · ${DateFormat.jm(locale).format(start)}',
      ),
      (l10n.duration, '$durationMinutes ${l10n.minutes}'),
      (l10n.fullName, name),
      (l10n.mobileNumber, mobile),
      if (email.isNotEmpty) (l10n.emailOptional, email),
      if (notes.isNotEmpty) (l10n.notesOptional, notes),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reviewBooking,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(
                        row.$1,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.$2,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
            Row(
              children: [
                Text(l10n.total, style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Text(
                  peso(total),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColors.cacao),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.payAtSpa),
          ],
        ),
      ),
    );
  }
}

class _Confirmation extends StatelessWidget {
  const _Confirmation({required this.appointment});
  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final manila = tz.getLocation('Asia/Manila');
    final start = tz.TZDateTime.from(appointment.startUtc, manila);
    return Scaffold(
      body: ResponsivePage(
        maxWidth: 640,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: const BoxDecoration(
                color: AppColors.sand,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 58, color: AppColors.palm),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.bookingConfirmed,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            Text(
              appointment.service.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              '${DateFormat.yMMMMd(locale).format(start)} · ${DateFormat.jm(locale).format(start)}',
            ),
            const SizedBox(height: 24),
            Text(
              l10n.bookingReference,
              style: const TextStyle(color: AppColors.muted),
            ),
            SelectableText(
              appointment.reference,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(l10n.normalConfirmationNote, textAlign: TextAlign.center),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: Text(l10n.done),
            ),
          ],
        ),
      ),
    );
  }
}
