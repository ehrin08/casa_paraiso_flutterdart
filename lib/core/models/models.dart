// Immutable domain models shared across the entire application.
//
// All models support JSON round-tripping so they can be persisted in
// SharedPreferences and embedded in appointment snapshots. The snapshot
// approach means that even if the catalog changes later, historical
// appointment records retain the original package name, price, and duration.
import 'dart:convert';

/// Tracks whether an appointment is still active or was explicitly cancelled.
enum AppointmentStatus { confirmed, cancelled }

// ---------------------------------------------------------------------------
// Catalog models — loaded once from assets/data/services.json
// ---------------------------------------------------------------------------

/// A spa service package (e.g., "Gaia Touch ₱499 / 60 min").
///
/// Each package has bilingual descriptions and a list of included treatment
/// choices. Gaia Touch has none; higher-tier packages offer Ventosa,
/// Hot Stone, or Hot Compress at no extra charge.
class ServicePackage {
  const ServicePackage({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
    required this.descriptionEn,
    required this.descriptionFil,
    required this.treatments,
  });

  final String id;
  final String name;
  final double price;
  final int durationMinutes;
  final String descriptionEn;
  final String descriptionFil;

  /// Available treatment choices included at no extra cost.
  /// Empty for packages that don't bundle a treatment.
  final List<String> treatments;

  factory ServicePackage.fromJson(Map<String, dynamic> json) => ServicePackage(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    durationMinutes: json['durationMinutes'] as int,
    descriptionEn: json['descriptionEn'] as String,
    descriptionFil: json['descriptionFil'] as String,
    treatments: List<String>.from(json['treatments'] as List),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'durationMinutes': durationMinutes,
    'descriptionEn': descriptionEn,
    'descriptionFil': descriptionFil,
    'treatments': treatments,
  };
}

/// An optional paid add-on (e.g., "30-minute Back Massage ₱298").
///
/// Back Massage adds 30 minutes to the total duration.
/// VIP Room adds ₱200 with no extra time.
class PaidExtra {
  const PaidExtra({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
  });

  final String id;
  final String name;
  final double price;
  final int durationMinutes;

  factory PaidExtra.fromJson(Map<String, dynamic> json) => PaidExtra(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    durationMinutes: json['durationMinutes'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'durationMinutes': durationMinutes,
  };
}

/// The complete spa catalog: four packages, two extras, three massage styles.
/// Loaded once at startup from the bundled JSON asset.
class Catalog {
  const Catalog({
    required this.services,
    required this.extras,
    required this.massageStyles,
  });

  final List<ServicePackage> services;
  final List<PaidExtra> extras;

  /// Swedish, Shiatsu, and Traditional Hilot.
  final List<String> massageStyles;

  factory Catalog.fromJson(Map<String, dynamic> json) => Catalog(
    services: (json['services'] as List)
        .map((item) => ServicePackage.fromJson(item as Map<String, dynamic>))
        .toList(),
    extras: (json['extras'] as List)
        .map((item) => PaidExtra.fromJson(item as Map<String, dynamic>))
        .toList(),
    massageStyles: List<String>.from(json['massageStyles'] as List),
  );
}

// ---------------------------------------------------------------------------
// Customer and appointment models
// ---------------------------------------------------------------------------

/// Reusable guest profile — saved after the first booking and pre-filled
/// in subsequent booking forms.
class CustomerProfile {
  const CustomerProfile({required this.name, required this.mobile, this.email});

  final String name;

  /// Philippine mobile in normalized +63 format (e.g., "+639916522754").
  final String mobile;

  /// Optional; validated when supplied but never required.
  final String? email;

  factory CustomerProfile.fromJson(Map<String, dynamic> json) =>
      CustomerProfile(
        name: json['name'] as String,
        mobile: json['mobile'] as String,
        email: json['email'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'mobile': mobile,
    'email': email,
  };
}

/// An immutable booking record with a full snapshot of the selected service,
/// extras, and customer details at the time of creation.
///
/// Times are stored in UTC. Display code converts via Asia/Manila.
/// The [reference] follows the format CP-YYYYMMDD-XXXX and is locally unique.
class Appointment {
  const Appointment({
    required this.id,
    required this.reference,
    required this.service,
    required this.massageStyle,
    this.treatment,
    required this.extras,
    required this.startUtc,
    required this.endUtc,
    required this.total,
    required this.customer,
    required this.createdAtUtc,
    this.notes,
    this.status = AppointmentStatus.confirmed,
  });

  /// Microsecond-based unique identifier.
  final String id;

  /// Human-readable reference code shown to the customer (e.g., "CP-20260828-AB3K").
  final String reference;

  /// Snapshot of the selected package at booking time.
  final ServicePackage service;
  final String massageStyle;

  /// The chosen included treatment (null for packages with no treatment).
  final String? treatment;

  /// Paid extras selected during booking.
  final List<PaidExtra> extras;

  /// Appointment window in UTC — use TZDateTime.from(startUtc, manila) to display.
  final DateTime startUtc;
  final DateTime endUtc;

  /// Precomputed total including base price and extras.
  final double total;
  final CustomerProfile customer;
  final DateTime createdAtUtc;

  /// Optional free-text note (max 250 characters).
  final String? notes;

  /// Confirmed by default. Cancelled is an explicit, permanent state.
  /// "Completed" is derived at display time when endUtc is in the past.
  final AppointmentStatus status;

  /// Only date/time and status can change — the rest of the snapshot is frozen.
  Appointment copyWith({
    DateTime? startUtc,
    DateTime? endUtc,
    AppointmentStatus? status,
  }) => Appointment(
    id: id,
    reference: reference,
    service: service,
    massageStyle: massageStyle,
    treatment: treatment,
    extras: extras,
    startUtc: startUtc ?? this.startUtc,
    endUtc: endUtc ?? this.endUtc,
    total: total,
    customer: customer,
    createdAtUtc: createdAtUtc,
    notes: notes,
    status: status ?? this.status,
  );

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json['id'] as String,
    reference: json['reference'] as String,
    service: ServicePackage.fromJson(json['service'] as Map<String, dynamic>),
    massageStyle: json['massageStyle'] as String,
    treatment: json['treatment'] as String?,
    extras: (json['extras'] as List)
        .map((item) => PaidExtra.fromJson(item as Map<String, dynamic>))
        .toList(),
    startUtc: DateTime.parse(json['startUtc'] as String).toUtc(),
    endUtc: DateTime.parse(json['endUtc'] as String).toUtc(),
    total: (json['total'] as num).toDouble(),
    customer: CustomerProfile.fromJson(
      json['customer'] as Map<String, dynamic>,
    ),
    createdAtUtc: DateTime.parse(json['createdAtUtc'] as String).toUtc(),
    notes: json['notes'] as String?,
    status: AppointmentStatus.values.byName(json['status'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'service': service.toJson(),
    'massageStyle': massageStyle,
    'treatment': treatment,
    'extras': extras.map((item) => item.toJson()).toList(),
    'startUtc': startUtc.toIso8601String(),
    'endUtc': endUtc.toIso8601String(),
    'total': total,
    'customer': customer.toJson(),
    'createdAtUtc': createdAtUtc.toIso8601String(),
    'notes': notes,
    'status': status.name,
  };
}

/// Global application state managed by [AppController].
///
/// Persisted across separate SharedPreferences keys so that a corrupt
/// appointments payload does not destroy the profile or locale setting.
class AppState {
  const AppState({
    this.onboardingComplete = false,
    this.localeCode = 'en',
    this.profile,
    this.appointments = const [],
    this.consentAccepted = false,
    this.recoveredData = false,
  });

  final bool onboardingComplete;

  /// 'en' or 'fil' — persisted and used to select the ARB translation file.
  final String localeCode;
  final CustomerProfile? profile;
  final List<Appointment> appointments;
  final bool consentAccepted;

  /// True when a corrupted JSON payload was cleared on startup.
  final bool recoveredData;

  AppState copyWith({
    bool? onboardingComplete,
    String? localeCode,
    CustomerProfile? profile,
    bool clearProfile = false,
    List<Appointment>? appointments,
    bool? consentAccepted,
    bool? recoveredData,
  }) => AppState(
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    localeCode: localeCode ?? this.localeCode,
    profile: clearProfile ? null : profile ?? this.profile,
    appointments: appointments ?? this.appointments,
    consentAccepted: consentAccepted ?? this.consentAccepted,
    recoveredData: recoveredData ?? this.recoveredData,
  );
}

/// Serializes appointments with a version tag for future migration safety.
String encodeAppointments(List<Appointment> appointments) => jsonEncode({
  'version': 1,
  'items': appointments.map((item) => item.toJson()).toList(),
});
