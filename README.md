# Casa Paraiso

**Casa Paraiso: Spa Service Browsing and Appointment Booking Application** is a customer-facing Flutter academic prototype for Android and responsive web. It combines a warm tropical wellness identity with a clear, dependable local appointment workflow.

## Features

- English and Filipino interface with a saved language preference
- Static spa catalog with package, style, treatment, extras, price, and duration rules
- Manila-time slot generation from 1:00 PM to 1:00 AM at 30-minute intervals
- Local guest profile, booking confirmation, history, rescheduling, and cancellation
- Customer-overlap prevention, one-hour lead time, and 30-day booking horizon
- Android reminders 24 hours and one hour before appointments
- In-app web reminders, contact links, privacy consent, and full local-data reset
- Responsive bottom navigation on phones and navigation rail on larger screens

## Important limitation

This is a backend-free academic prototype. Appointments are stored only in the current device or browser and are **not transmitted to Casa Paraiso**. Availability checks cover only appointments stored by the current customer; they do not represent spa-wide capacity.

## Requirements

- Flutter 3.44.4 / Dart 3.12.2 or a compatible stable release
- Android SDK with API 26 or later for Android builds
- Chrome or Edge for web testing

## Run locally

```powershell
flutter pub get
flutter gen-l10n
flutter run -d chrome
```

For Android, start an emulator or connect a device and run:

```powershell
flutter run -d <device-id>
```

## Validate

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --release
flutter build web --release --base-href /casa_paraiso_flutterdart/
```

## GitHub Pages

The web build uses hash routing and the repository base path. Build with the command above, then publish the contents of `build/web` to the `gh-pages` branch. Local browser data remains isolated per origin and browser profile.

## Architecture

The project uses feature-first Flutter modules with Riverpod, GoRouter, SharedPreferences, bundled JSON assets, ARB localization, Manila timezone rules, and platform-specific notifications. See [Architecture](docs/architecture.md) and [Requirements](docs/requirements.md).

## Documentation

- [Requirements and acceptance criteria](docs/requirements.md)
- [Architecture and data flow](docs/architecture.md)
- [User guide](docs/user-guide.md)
- [Privacy and limitations](docs/privacy-and-limitations.md)
- [Test report](docs/test-report.md)

## Business information

Casa Paraiso Body & Wellness Spa  
Barangay Cuta East, Santa Teresita, Batangas, Philippines  
Landmark: In front of Alfamart and PLDT  
DITO: 0991 652 2754 · TM: 0953 657 9029 · Landline: (02) 8808 9476
