import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

const facebookUrl = 'https://www.facebook.com/61579320037378';
const messengerUrl = 'https://m.me/61579320037378';
const mapsUrl =
    'https://www.google.com/maps/search/?api=1&query=Casa+Paraiso+Body+%26+Wellness+Spa%2C+Cuta+East%2C+Santa+Teresita%2C+Batangas';

Future<void> launchExternal(BuildContext context, String raw) async {
  final uri = Uri.parse(raw);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
      context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Unable to open this link.')));
  }
}

Future<void> showPhoneChooser(BuildContext context) async {
  final numbers = [
    ('DITO', '0991 652 2754', 'tel:09916522754'),
    ('TM', '0953 657 9029', 'tel:09536579029'),
    ('Landline', '(02) 8808 9476', 'tel:0288089476'),
  ];
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          const ListTile(
            title: Text(
              'Choose a number',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          for (final item in numbers)
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: Text(item.$1),
              subtitle: Text(item.$2),
              minVerticalPadding: 14,
              onTap: () {
                Navigator.pop(context);
                launchExternal(context, item.$3);
              },
            ),
        ],
      ),
    ),
  );
}

class ContactActionRow extends StatelessWidget {
  const ContactActionRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = [
      (Icons.phone_outlined, l10n.callUs, () => showPhoneChooser(context)),
      (
        Icons.chat_bubble_outline,
        l10n.messageUs,
        () => launchExternal(context, messengerUrl),
      ),
      (
        Icons.map_outlined,
        l10n.directions,
        () => launchExternal(context, mapsUrl),
      ),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final action in actions)
          OutlinedButton.icon(
            onPressed: action.$3,
            icon: Icon(action.$1),
            label: Text(action.$2),
          ),
      ],
    );
  }
}
