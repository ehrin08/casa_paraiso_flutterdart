# Privacy and Prototype Limitations

## Local data

The prototype stores the customer profile, consent, locale, onboarding state, and appointment records in SharedPreferences belonging to the current Android installation or browser origin. It has no account system, remote API, shared database, analytics, or cloud synchronization.

Reset Data removes locally stored customer information and cancels scheduled Android reminders. Removing the Android application or clearing site data also removes records.

## Booking limitations

- A displayed confirmation is a local prototype record and is not sent to Casa Paraiso.
- Availability checks only the current customer's locally saved appointments.
- Different devices and browsers cannot see one another's records.
- Contact the spa directly for real availability and operational confirmation.
- Payment is due at the spa; the application collects no payment information.

## Notifications

Android requests notification permission after the first booking and schedules eligible reminders 24 hours and one hour before the appointment. Delivery depends on device permissions and operating-system behavior. Web reminders appear only while the application is open; no background web push service exists.

## Content provenance

The logo, service-board photograph, package names, visible prices, business hours, address, phone numbers, and social/map links were supplied for this academic project. No stock or generated spa photography is included.
