import 'job_model.dart';
import 'worker_model.dart';

class SmartMatchModel {
  final String jobId;
  final String workerId;
  final int matchScore; // Nilai persentase 0 - 100%
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final double distanceKm;
  final String recommendationReason;

  const SmartMatchModel({
    required this.jobId,
    required this.workerId,
    required this.matchScore,
    required this.matchedSkills,
    required this.missingSkills,
    required this.distanceKm,
    required this.recommendationReason,
  });

  // Algoritma Smart Matching KaryaSetara
  // Bobot: Skill Matching (50%) + Radius Jarak (30%) + Akomodasi Aksesibilitas (20%)
  factory SmartMatchModel.calculateMatch(JobModel job, WorkerModel worker) {
    // 1. Skill Matching
    final matched = <String>[];
    final missing = <String>[];

    for (final skill in job.requiredSkills) {
      if (worker.skills.any((s) => s.toLowerCase() == skill.toLowerCase())) {
        matched.add(skill);
      } else {
        missing.add(skill);
      }
    }

    final skillRatio = job.requiredSkills.isEmpty ? 1.0 : matched.length / job.requiredSkills.length;
    final skillScore = skillRatio * 50.0;

    // 2. Distance Score (Semakin dekat, semakin tinggi skornya)
    double distanceScore = 0.0;
    if (job.distanceKm <= worker.radiusKm) {
      final distanceRatio = 1.0 - (job.distanceKm / (worker.radiusKm + 1.0));
      distanceScore = (distanceRatio.clamp(0.0, 1.0)) * 30.0;
    }

    // 3. Accommodation Score (Preferensi teks & mandiri)
    double accommodationScore = 15.0;
    if (worker.isTextOnly) {
      accommodationScore = 20.0;
    }

    final totalScore = (skillScore + distanceScore + accommodationScore).round().clamp(0, 100);

    String reason;
    if (totalScore >= 85) {
      reason = 'Sangat Direkomendasikan: ${matched.length}/${job.requiredSkills.length} kemampuan terpenuhi & jarak hanya ${job.distanceKm} km.';
    } else if (totalScore >= 70) {
      reason = 'Cocok: Memenuhi sebagian besar kriteria keahlian dan berada di dalam radius kerja Anda.';
    } else {
      reason = 'Cukup Cocok: Terdapat beberapa keahlian tambahan yang dibutuhkan pemberi kerja.';
    }

    return SmartMatchModel(
      jobId: job.id,
      workerId: worker.id,
      matchScore: totalScore,
      matchedSkills: matched,
      missingSkills: missing,
      distanceKm: job.distanceKm,
      recommendationReason: reason,
    );
  }

  factory SmartMatchModel.fromJson(Map<String, dynamic> json) {
    return SmartMatchModel(
      jobId: json['job_id'] as String? ?? json['jobId'] as String? ?? '',
      workerId: json['worker_id'] as String? ?? json['workerId'] as String? ?? '',
      matchScore: (json['match_score'] is num)
          ? (json['match_score'] as num).toInt()
          : (json['matchScore'] is num)
              ? (json['matchScore'] as num).toInt()
              : 0,
      matchedSkills: json['matched_skills'] != null
          ? List<String>.from(json['matched_skills'] as List)
          : json['matchedSkills'] != null
              ? List<String>.from(json['matchedSkills'] as List)
              : <String>[],
      missingSkills: json['missing_skills'] != null
          ? List<String>.from(json['missing_skills'] as List)
          : json['missingSkills'] != null
              ? List<String>.from(json['missingSkills'] as List)
              : <String>[],
      distanceKm: (json['distance_km'] is num)
          ? (json['distance_km'] as num).toDouble()
          : (json['distanceKm'] is num)
              ? (json['distanceKm'] as num).toDouble()
              : 0.0,
      recommendationReason: json['recommendation_reason'] as String? ?? json['recommendationReason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'worker_id': workerId,
      'match_score': matchScore,
      'matched_skills': matchedSkills,
      'missing_skills': missingSkills,
      'distance_km': distanceKm,
      'recommendation_reason': recommendationReason,
    };
  }
}
