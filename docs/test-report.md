# Test Report

## Automated verification

Date: 2026-07-15  
Environment: Windows 11, Flutter stable 3.44.4, Dart 3.12.2

| Check | Result | Coverage |
| --- | --- | --- |
| `dart format --output=none --set-exit-if-changed lib test` | Pass | Source and test formatting |
| `flutter analyze` | Pass | No analyzer issues |
| `flutter test` | Pass: 9 tests | Pricing, duration, phone/email validation, Manila slots, last starts, overlap, persistence, JSON recovery, onboarding/navigation |
| `flutter build web --release --base-href /casa_paraiso_flutterdart/` | Pass | Release web compilation and Pages base path |
| `flutter build apk --release --target=lib/main.dart` | Pass: 56,079,425-byte APK | Android release packaging |

The Android build uses an explicit target because this Windows environment's Gradle invocation otherwise resolved the entry point as `/main.dart`.

## Tested business scenarios

- Gaia Touch plus Back Massage totals ₱797.00 and lasts 90 minutes.
- A 120-minute service can start no later than 11:00 PM.
- A 150-minute service can start no later than 10:30 PM.
- `09…` and `+63…` Philippine mobile formats normalize to `+63…`.
- Invalid email values are rejected while blank email is accepted.
- Active local appointments remove overlapping slots.
- Profile and appointment snapshots survive SharedPreferences reload.
- Malformed appointment JSON is cleared without removing a valid profile.
- Onboarding can be skipped into the phone bottom-navigation shell.

## Manual acceptance checklist

- [ ] Android API 26 device or emulator
- [ ] Android 13+ notification permission and reminder rescheduling
- [ ] Chrome and Edge phone, tablet, and desktop widths
- [ ] Keyboard navigation and visible focus
- [ ] Largest practical text scale and long Filipino strings
- [ ] Denied notification permission does not block booking
- [ ] Refresh and hash-route behavior under GitHub Pages
- [ ] Contact dialer, Messenger, Facebook, and Maps actions
- [ ] Corrupted local data recovery notice
- [ ] Full reset removes profile, locale, consent, appointments, and reminders
