# Casa Paraiso Flutter Agent Guide

This file applies to the entire repository. Treat it as the durable product and engineering brief for future work. The earlier planning conversation records product intent; the checked-out files remain the source of truth for the current implementation.

## Product identity and boundaries

- Title: **Casa Paraiso: Spa Service Browsing and Appointment Booking Application**.
- Build a customer-only academic prototype for Android and responsive web. It browses a bundled spa catalog and manages appointment records locally on the user's device.
- The app is static/local-first. It does not transmit bookings to Casa Paraiso, check spa-wide capacity, or synchronize data between devices. Make this limitation clear in the UI and documentation wherever a user could mistake a local confirmation for a real reservation.
- Do not introduce authentication, staff/admin workspaces, a backend or shared database, online payments, promotions, rewards, analytics, sentiment analysis, appointment sharing, or dark mode unless the user explicitly changes the scope.
- Do not add Firebase, Supabase, SQLite, Hive, remote APIs, or production analytics. A future backend should be able to replace repository implementations without forcing a presentation-layer redesign.
- Primary deliverables are source code, a release APK, a manually published GitHub Pages build, English project documentation, diagrams, a user guide, test evidence, and an editable presentation.

## Experience and brand

- Use a light-only Material 3 experience that feels like a warm tropical wellness retreat translated into a dependable modern booking tool: calm, restorative, premium, natural, and caring.
- Use `assets/images/casa_paraiso_logo.jpg` for splash/header contexts and crop its leaf emblem onto cream for launcher/web icons. Use `assets/images/service_board.jpg` as the Home hero image; do not add stock or generated spa photography without approval.
- Brand colors: cacao `#7A3518`, palm `#2F5D45`, muted brass `#A98245`, warm sand `#E4D4BD`, cream `#FBF7EF`, white surface `#FFFDF8`, ink `#2B211B`, muted text `#6F6259`, and error `#B3261E`.
- Bundle and use Cormorant Garamond for display/emotional copy and Manrope for navigation, forms, prices, dates, and operational information. Do not require runtime font or icon downloads.
- Prefer soft depth, arched image masks, restrained foliage, 4/8dp spacing, and purposeful 150–300ms motion. Honor reduced-motion preferences.
- Primary destinations are Home, Services, Bookings, and Profile. Use bottom navigation on phones and a navigation rail at widths of 600dp and above, with centered width-constrained content and multi-column catalog layouts where space allows.
- Home includes the hero, business hours, featured packages, a booking call to action, and contact shortcuts. Services uses branded typographic cards and service details. Bookings separates upcoming, completed, and cancelled records. Profile contains customer details, locale, notification status, privacy/local-data information, contact actions, onboarding replay, app information, and confirmed data reset.
- First launch shows three skippable onboarding slides for service discovery, local booking management, and privacy/reminders; Profile can replay onboarding.
- Meet WCAG AA contrast, 48dp touch targets, visible web keyboard focus, semantic labels, logical focus order, large-text resilience, and responsive layouts without viewport-level horizontal overflow.

## Localization and business contacts

- Support English and Filipino through Flutter ARB localization. English is the default and the selected locale persists locally.
- Keep brand and package names unchanged. Translate navigation, descriptions, forms, validation, privacy, notification, and appointment copy.
- Authoritative public address: `Barangay Cuta East, Santa Teresita, Batangas, Philippines` with landmark copy `In front of Alfamart and PLDT.` Do not repeat the unverified BDO-building statement.
- Phone choices: DITO `0991 652 2754`, TM `0953 657 9029`, and landline `(02) 8808 9476`.
- Contact actions may open `https://www.facebook.com/61579320037378`, `https://m.me/61579320037378`, and `https://www.google.com/maps/search/?api=1&query=Casa+Paraiso+Body+%26+Wellness+Spa%2C+Cuta+East%2C+Santa+Teresita%2C+Batangas`. Do not invent an Instagram account or other contact channel.

## Catalog and pricing rules

Keep the catalog as versioned, read-only JSON assets. Each appointment selects exactly one package and one massage style: Swedish, Shiatsu, or Traditional Hilot.

| Package | Base price | Base duration | Included treatment |
| --- | ---: | ---: | --- |
| Gaia Touch | ₱499.00 | 60 min | None |
| Tethys Flow | ₱649.00 | 60 min | Ventosa or Hot Compress |
| Hestia Warmth | ₱749.00 | 90 min | Ventosa, Hot Stone, or Hot Compress |
| Aurora Breeze | ₱849.00 | 120 min | Ventosa, Hot Compress, or Hot Stone |

- A package with treatment choices requires exactly one listed treatment at no extra charge.
- Every package permits a 30-minute Back Massage extra for ₱298.00 and a VIP Room extra for ₱200.00.
- Back Massage adds 30 minutes. VIP Room changes price only.
- Store a service-and-price snapshot in each appointment so history is stable when the catalog changes.

## Booking behavior

- Use `Asia/Manila` as the fixed business timezone, independent of device timezone. Store instants in UTC together with the business-zone identity; convert for slot generation and display.
- The spa is open daily from 1:00 PM until 1:00 AM the following calendar day. Generate starts in 30-minute intervals and require the full duration, including extras, to finish by closing.
- Enforce at least one hour of lead time and a maximum booking horizon of 30 days.
- Block only overlaps with the current customer's non-cancelled local appointments. When rescheduling, exclude the appointment being moved from conflict checks.
- A booking includes one package, massage style, the applicable treatment, optional extras, customer details, and an optional note of at most 250 characters.
- Require a full name and valid Philippine mobile number. Accept and normalize `09…` and `+63…` mobile formats. Email is optional but must be valid when supplied.
- The flow is: package; style/treatment/extras; date/time; customer details/notes; first-booking local-data consent; full review with duration, total, contact details, and “pay at spa”; immediate local confirmation.
- Confirmation references follow `CP-YYYYMMDD-XXXX` and must be unique among locally stored appointments.
- Rescheduling changes only date/time, retains the reference and selections, and is allowed until the original start. Cancellation is allowed until start and retains an explicit cancelled record. Derive completed grouping after the appointment end time.
- Browse without profile setup. Save/reuse the guest profile after the first booking.

## Persistence and notifications

- Use `SharedPreferences` with separate, versioned payloads for profile, appointments, locale, consent, onboarding completion, and preferences. Static catalog assets remain read-only.
- If one local JSON payload is malformed, clear only that payload, preserve other data and the static catalog, and show a recoverable message.
- Reset Data requires confirmation, cancels scheduled reminders, and clears all customer data, appointments, locale, consent, onboarding state, and preferences.
- On Android, explain and request notification permission after the first confirmation. When still in the future, schedule reminders 24 hours and one hour before an appointment.
- Rescheduling replaces previous reminders; cancellation and reset remove them. Permission denial must never block booking.
- Web may show equivalent in-app reminders while open but must not claim background notification delivery.

## Architecture and implementation rules

- Use a feature-first layout for app shell, onboarding, catalog, booking, appointments, profile, contact, localization, and notifications.
- Use `flutter_riverpod` without code generation, `go_router`, `shared_preferences`, `intl`, `timezone`, `flutter_local_notifications`, and `url_launcher` unless a scoped change justifies otherwise.
- Use hash-based web routing so GitHub Pages refresh/deep-link behavior does not require server rewrites. The deployment base path is `/casa_paraiso_flutterdart/`.
- Keep immutable models for `ServicePackage`, treatment choices, `PaidExtra`, `CustomerProfile`, `Appointment`, and appointment status.
- Keep contracts/boundaries for catalog loading, profile persistence, appointment persistence, pricing/duration, Manila-time availability/conflicts, clock access, and platform-specific notifications.
- Inject clocks, repositories, storage, and notification implementations through Riverpod so time and platform behavior can be tested without real persistence or notifications.
- Keep cancelled state explicit; compute upcoming/completed views from time rather than permanently mutating a confirmed appointment to completed.
- Put business rules in testable Dart services or controllers, not directly in widgets. Keep widgets focused on rendering, accessibility, navigation, and user interaction.
- Preserve existing user files and unrelated worktree changes. Prefer small, focused edits and inspect affected sources before introducing a new convention.
- Do not silently weaken validation, accessibility, localization, scheduling, privacy, or offline behavior to make a test pass. Update this guide when the user deliberately changes a durable requirement.

## Verification expectations

Run the narrowest relevant checks while developing, then the full applicable set before handoff:

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --release
flutter build web --release --base-href /casa_paraiso_flutterdart/
```

- Unit tests cover catalog parsing, pricing/duration, phone normalization, optional email validation, reference uniqueness, status derivation, JSON recovery, cross-midnight slots, last valid starts, lead time, booking horizon, overlap checks, and rescheduling exclusion.
- Widget tests cover onboarding, four-destination navigation, bottom-bar/rail switching, bilingual UI, forms and validation, consent/review totals, booking states, cancellation/reset dialogs, accessibility semantics, large text, and reduced motion.
- Integration tests use mocked platform services for booking, restart persistence, rescheduling/reminder replacement, cancellation, profile/locale persistence, reset, and contact links.
- Manual acceptance covers Android API 26 and Android 14+, Android 13+ notification permission, Chrome and Edge across phone/tablet/desktop widths, keyboard-only navigation, refresh/deep links, denied notifications, offline restart, corrupt data, cross-midnight bookings, and GitHub Pages assets.
- Never claim a check passed unless it was run successfully. Report environmental blockers and pre-existing failures separately from regressions caused by the current change.

## Current baseline — verify and maintain

This section describes the implemented checkout observed on 2026-07-15. Re-check generated artifacts and validation results before relying on them in future work.

- The Android and responsive web application is implemented on `agent/casa-paraiso-app` with feature-first Riverpod modules, GoRouter detail flows, ARB localization, bundled catalog/assets/fonts, SharedPreferences persistence, and platform notification boundaries.
- Customer flows cover onboarding, Home, Services, booking review/confirmation, appointment history, rescheduling, cancellation, Profile, official contact actions, privacy consent, and reset.
- Automated tests cover pricing/duration, Philippine contact validation, Manila-time slot rules, overlap detection, persistence/recovery, and onboarding/navigation.
- Static analysis, all automated tests, and the Pages-targeted release web build passed during the implementation session. Re-run the full verification commands after future changes.
- Academic requirements, architecture, privacy/limitations, user guide, and test evidence are maintained under `docs/`.

## Workspace tooling

- Follow the workspace lean-context instructions: use `ctx_compose` first for code understanding, `ctx_read` for file reads, `ctx_search` for code search, and `ctx_shell` for shell commands when available.
- Compressed output is for orientation. When exact file text, log lines, counts, or line numbers are required as evidence, rerun the exact command through `lean-ctx raw`/raw mode and do not reconstruct exact claims from compressed output.
- Use patch-based edits, preserve a dirty worktree, and avoid destructive Git or filesystem operations unless the user explicitly requests them.
