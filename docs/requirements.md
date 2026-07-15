# Requirements and Acceptance Criteria

## Product objective

Provide an approachable, bilingual way for customers to browse Casa Paraiso services, configure one package, choose a Manila-time appointment, and manage the resulting record locally on Android or web.

## Included scope

- Android 8/API 26+ and responsive Chrome/Edge web
- Three-screen onboarding and four-destination customer shell
- Home hero, service catalog and details, booking flow, appointment history, and profile
- English and Filipino ARB localization
- Locally persisted profile, consent, locale, onboarding state, and appointments
- Android appointment reminders and in-app web reminders
- Official call, Messenger, Facebook, and directions actions
- Academic documentation, automated tests, release builds, and presentation

## Excluded scope

Authentication, staff/admin tools, shared backend or database, real spa-wide capacity, synchronization, online payment, promotions, loyalty rewards, feedback/sentiment analysis, analytics, appointment sharing, and dark mode.

## Catalog rules

| Package | Price | Duration | Included treatment |
| --- | ---: | ---: | --- |
| Gaia Touch | ₱499.00 | 60 min | None |
| Tethys Flow | ₱649.00 | 60 min | Ventosa or Hot Compress |
| Hestia Warmth | ₱749.00 | 90 min | Ventosa, Hot Stone, or Hot Compress |
| Aurora Breeze | ₱849.00 | 120 min | Ventosa, Hot Compress, or Hot Stone |

Every appointment requires one massage style: Swedish, Shiatsu, or Traditional Hilot. The optional 30-minute Back Massage costs ₱298.00 and adds 30 minutes. The optional VIP Room costs ₱200.00 and adds no time.

## Booking acceptance criteria

1. Customers can browse without creating a profile.
2. The app requires one package, one massage style, and one included treatment when the package offers choices.
3. Totals and duration update when extras change.
4. Slots use Asia/Manila time, start every 30 minutes, and finish by 1:00 AM.
5. The app enforces a one-hour lead time and 30-day horizon.
6. Active local appointments cannot overlap; cancelled records do not block slots.
7. The first booking requires valid customer details and local-data consent.
8. Confirmation generates a unique `CP-YYYYMMDD-XXXX` reference and persists the service snapshot.
9. Rescheduling changes only date/time, retains the reference, and replaces reminders.
10. Cancellation retains the record and removes reminders.
11. Completed grouping is derived after appointment end; confirmed records are not permanently rewritten.
12. Reset removes all local customer data and reminders after confirmation.

## Quality acceptance criteria

- Light Material 3 design uses bundled Cormorant Garamond and Manrope fonts.
- Phone layouts use bottom navigation; widths of 600dp and above use a navigation rail.
- Interactive targets meet Android minimum sizes and have semantic labels or visible text.
- Keyboard focus, large text, scroll behavior, and bilingual layouts avoid viewport-level overflow.
- `flutter analyze`, `flutter test`, Android release build, and Pages-targeted web release build complete successfully before final delivery.
