// Shared reusable widgets used across multiple feature screens.
//
// Kept small and focused — each widget handles one visual concern.
// Screens compose these to maintain consistent spacing, branding, and
// responsive behavior without duplicating layout code.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

/// Wraps page content in a centered, width-constrained, padded container.
///
/// Ensures content looks good on both phones (full width) and tablets/desktops
/// (max 1120dp by default). All scrollable screens use this as their root.
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.maxWidth = 1120,
    this.padding,
  });
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: child,
        ),
      ),
    ),
  );
}

/// A bold section title row with an optional trailing action widget.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      ),
      ?trailing,
    ],
  );
}

/// The Casa Paraiso logo loaded from bundled assets with a semantic label
/// for screen readers.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 72});
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Casa Paraiso Body and Wellness Spa logo',
    image: true,
    child: Image.asset(
      'assets/images/casa_paraiso_logo.jpg',
      height: height,
      fit: BoxFit.contain,
    ),
  );
}

/// A small circular badge with a spa leaf icon — used as a visual mark
/// on service cards and appointment list items.
class LeafMark extends StatelessWidget {
  const LeafMark({super.key, this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: AppColors.sand,
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.spa_outlined, color: AppColors.palm),
  );
}

/// Formats a [double] as a Philippine peso string (e.g., "₱749.00").
String peso(double amount) => NumberFormat.currency(
  locale: 'en_PH',
  symbol: '₱',
  decimalDigits: 2,
).format(amount);

/// A rounded pill-shaped chip displaying an icon and label — used for
/// duration and price metadata on service/booking cards.
class InfoPill extends StatelessWidget {
  const InfoPill({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.palm),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
