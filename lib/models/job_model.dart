import 'package:intl/intl.dart';

class JobModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int wage;
  final String employerName;
  final String location;
  final double distanceKm;
  final List<String> requiredSkills;
  final String status;
  final String paymentStatus;
  final String? submissionUrl;
  final DateTime createdAt;

  const JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.wage,
    required this.employerName,
    required this.location,
    required this.distanceKm,
    required this.requiredSkills,
    this.status = 'Active',
    this.paymentStatus = 'Locked',
    this.submissionUrl,
    required this.createdAt,
  });

  // Getter format mata uang Rupiah
  String get formattedWage {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(wage);
  }

  // Getter format tanggal lokal
  String get formattedDate {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(createdAt);
  }

  // JSON Deserialization (Dari REST API / Supabase Response)
  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Umum',
      wage: (json['wage'] is num) ? (json['wage'] as num).toInt() : 0,
      employerName: json['employer_name'] as String? ?? json['employerName'] as String? ?? 'Anonim',
      location: json['location'] as String? ?? 'Denpasar',
      distanceKm: (json['distance_km'] is num)
          ? (json['distance_km'] as num).toDouble()
          : (json['distanceKm'] is num)
              ? (json['distanceKm'] as num).toDouble()
              : 1.0,
      requiredSkills: json['required_skills'] != null
          ? List<String>.from(json['required_skills'] as List)
          : json['requiredSkills'] != null
              ? List<String>.from(json['requiredSkills'] as List)
              : <String>[],
      status: json['status'] as String? ?? 'Active',
      paymentStatus: json['payment_status'] as String? ?? json['paymentStatus'] as String? ?? 'Locked',
      submissionUrl: json['submission_url'] as String? ?? json['submissionUrl'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // JSON Serialization (Untuk dikirim ke Database / HTTP POST)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'wage': wage,
      'employer_name': employerName,
      'location': location,
      'distance_km': distanceKm,
      'required_skills': requiredSkills,
      'status': status,
      'payment_status': paymentStatus,
      'submission_url': submissionUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Immutability CopyWith Method
  JobModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? wage,
    String? employerName,
    String? location,
    double? distanceKm,
    List<String>? requiredSkills,
    String? status,
    String? paymentStatus,
    String? submissionUrl,
    DateTime? createdAt,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      wage: wage ?? this.wage,
      employerName: employerName ?? this.employerName,
      location: location ?? this.location,
      distanceKm: distanceKm ?? this.distanceKm,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      submissionUrl: submissionUrl ?? this.submissionUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
