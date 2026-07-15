import 'dart:convert';

enum AppointmentStatus { confirmed, cancelled }

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

class Catalog {
  const Catalog({
    required this.services,
    required this.extras,
    required this.massageStyles,
  });

  final List<ServicePackage> services;
  final List<PaidExtra> extras;
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

class CustomerProfile {
  const CustomerProfile({required this.name, required this.mobile, this.email});

  final String name;
  final String mobile;
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

  final String id;
  final String reference;
  final ServicePackage service;
  final String massageStyle;
  final String? treatment;
  final List<PaidExtra> extras;
  final DateTime startUtc;
  final DateTime endUtc;
  final double total;
  final CustomerProfile customer;
  final DateTime createdAtUtc;
  final String? notes;
  final AppointmentStatus status;

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
  final String localeCode;
  final CustomerProfile? profile;
  final List<Appointment> appointments;
  final bool consentAccepted;
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

String encodeAppointments(List<Appointment> appointments) => jsonEncode({
  'version': 1,
  'items': appointments.map((item) => item.toJson()).toList(),
});
