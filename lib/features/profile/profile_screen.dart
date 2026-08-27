// Profile screen — customer info, language, notifications, contact,
// privacy, and app information.
//
// Sections: profile card (with edit), language switcher (en/fil),
// notifications info, contact shortcuts (call/message/directions/Facebook),
// privacy (replay onboarding, reset data), and About.
//
// Edit Profile opens a dialog with validated form fields.
// Reset Data requires confirmation and erases all local data.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/models.dart';
import '../../core/services/booking_services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../contact/contact_actions.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(appControllerProvider);
    return Scaffold(
      body: SingleChildScrollView(
        child: ResponsivePage(
          maxWidth: 900,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.profile,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 24),
              // Profile card — shows saved name/mobile/email or a placeholder.
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const LeafMark(size: 56),
                      const SizedBox(width: 16),
                      Expanded(
                        child: state.profile == null
                            ? Text(
                                l10n.customerDetails,
                                style: Theme.of(context).textTheme.titleLarge,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.profile!.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  Text(state.profile!.mobile),
                                  if (state.profile!.email != null)
                                    Text(state.profile!.email!),
                                ],
                              ),
                      ),
                      IconButton(
                        tooltip: l10n.editProfile,
                        onPressed: () =>
                            _editProfile(context, ref, state.profile),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Language switcher — persists locale preference.
              _Section(
                title: l10n.language,
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'en', label: Text(l10n.english)),
                    ButtonSegment(value: 'fil', label: Text(l10n.filipino)),
                  ],
                  selected: {state.localeCode},
                  onSelectionChanged: (value) => ref
                      .read(appControllerProvider.notifier)
                      .setLocale(value.first),
                ),
              ),
              const SizedBox(height: 16),
              // Notification info — explains reminder behavior.
              _Section(
                title: l10n.notifications,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.palm,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.notificationsDescription)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Contact section — address, landmark, action buttons, Facebook.
              _Section(
                title: l10n.contactUs,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.address,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(l10n.landmark),
                    const SizedBox(height: 14),
                    const ContactActionRow(),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => launchExternal(context, facebookUrl),
                      icon: const Icon(Icons.public),
                      label: const Text('Facebook'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Privacy section — replay onboarding and destructive reset.
              _Section(
                title: l10n.privacy,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.privacySummary),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => ref
                          .read(appControllerProvider.notifier)
                          .replayOnboarding(),
                      icon: const Icon(Icons.replay),
                      label: Text(l10n.replayIntro),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      onPressed: () => _reset(context, ref),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.resetData),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // About section — app identity and version.
              _Section(
                title: l10n.about,
                child: const Text(
                  'Casa Paraiso: Spa Service Browsing and Appointment Booking Application\nVersion 1.0.0 · Academic prototype',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens a dialog to edit customer profile with validated fields.
  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref,
    CustomerProfile? current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final key = GlobalKey<FormState>();
    final name = TextEditingController(text: current?.name ?? '');
    final mobile = TextEditingController(text: current?.mobile ?? '');
    final email = TextEditingController(text: current?.email ?? '');
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editProfile),
        content: SizedBox(
          width: 460,
          child: Form(
            key: key,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    decoration: InputDecoration(labelText: l10n.fullName),
                    validator: (value) =>
                        value == null || value.trim().length < 2
                        ? l10n.requiredField
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: mobile,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: l10n.mobileNumber),
                    validator: (value) =>
                        validatePhilippineMobile(value ?? '') == null
                        ? l10n.invalidMobile
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: l10n.emailOptional),
                    validator: (value) => isValidOptionalEmail(value ?? '')
                        ? null
                        : l10n.invalidEmail,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.back),
          ),
          FilledButton(
            onPressed: () async {
              if (!(key.currentState?.validate() ?? false)) return;
              await ref
                  .read(appControllerProvider.notifier)
                  .saveProfile(
                    CustomerProfile(
                      name: name.text.trim(),
                      mobile: validatePhilippineMobile(mobile.text)!,
                      email: email.text.trim().isEmpty
                          ? null
                          : email.text.trim(),
                    ),
                  );
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    name.dispose();
    mobile.dispose();
    email.dispose();
  }

  /// Confirms and executes a full data reset — erases profile, appointments,
  /// settings, consent, onboarding state, and scheduled reminders.
  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetData),
        content: Text(l10n.resetWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.back),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.resetData),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appControllerProvider.notifier).reset();
    }
  }
}

/// Reusable card section widget used throughout the profile screen.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}
