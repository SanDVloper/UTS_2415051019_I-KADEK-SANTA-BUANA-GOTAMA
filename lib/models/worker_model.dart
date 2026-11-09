import 'package:intl/intl.dart';

class WorkerModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String location;
  final double radiusKm;
  final List<String> skills;
  final bool isHighContrast;
  final bool isLargeFont;
  final bool isTextOnly;
  final double rating;
  final int completedJobsCount;
  final int balance;

  const WorkerModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'Worker',
    this.location = 'Denpasar Barat',
    this.radiusKm = 5.0,
    required this.skills,
    this.isHighContrast = false,
    this.isLargeFont = false,
    this.isTextOnly = true,
    this.rating = 4.9,
    this.completedJobsCount = 12,
    this.balance = 650000,
  });

  // Getter saldo dalam format Rupiah
  String get formattedBalance {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(balance);
  }

  // JSON Deserialization
  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Made Suardana',
      email: json['email'] as String? ?? 'made.suardana@karyasetara.id',
      role: json['role'] as String? ?? 'Worker',
      location: json['location'] as String? ?? 'Denpasar Barat',
      radiusKm: (json['radius_km'] is num)
          ? (json['radius_km'] as num).toDouble()
          : (json['radiusKm'] is num)
              ? (json['radiusKm'] as num).toDouble()
              : 5.0,
      skills: json['skills'] != null ? List<String>.from(json['skills'] as List) : <String>[],
      isHighContrast: json['is_high_contrast'] as bool? ?? json['isHighContrast'] as bool? ?? false,
      isLargeFont: json['is_large_font'] as bool? ?? json['isLargeFont'] as bool? ?? false,
      isTextOnly: json['is_text_only'] as bool? ?? json['isTextOnly'] as bool? ?? true,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 4.9,
      completedJobsCount: (json['completed_jobs_count'] is num)
          ? (json['completed_jobs_count'] as num).toInt()
          : (json['completedJobsCount'] is num)
              ? (json['completedJobsCount'] as num).toInt()
              : 12,
      balance: (json['balance'] is num) ? (json['balance'] as num).toInt() : 650000,
    );
  }

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'location': location,
      'radius_km': radiusKm,
      'skills': skills,
      'is_high_contrast': isHighContrast,
      'is_large_font': isLargeFont,
      'is_text_only': isTextOnly,
      'rating': rating,
      'completed_jobs_count': completedJobsCount,
      'balance': balance,
    };
  }

  // CopyWith Method
  WorkerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? location,
    double? radiusKm,
    List<String>? skills,
    bool? isHighContrast,
    bool? isLargeFont,
    bool? isTextOnly,
    double? rating,
    int? completedJobsCount,
    int? balance,
  }) {
    return WorkerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      location: location ?? this.location,
      radiusKm: radiusKm ?? this.radiusKm,
      skills: skills ?? this.skills,
      isHighContrast: isHighContrast ?? this.isHighContrast,
      isLargeFont: isLargeFont ?? this.isLargeFont,
      isTextOnly: isTextOnly ?? this.isTextOnly,
      rating: rating ?? this.rating,
      completedJobsCount: completedJobsCount ?? this.completedJobsCount,
      balance: balance ?? this.balance,
    );
  }
}
