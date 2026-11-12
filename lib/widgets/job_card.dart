import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/job_model.dart';
import 'smart_match_badge.dart';

/// Reusable Job Card widget representing an individual micro-job offer.
/// Fully compliant with WCAG accessibility semantics for screen readers (TalkBack/VoiceOver).
class JobCard extends StatelessWidget {
  final JobModel job;
  final bool isBookmarked;
  final VoidCallback? onBookmarkToggle;
  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.job,
    this.isBookmarked = false,
    this.onBookmarkToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Lowongan: ${job.title}, Kategori: ${job.category}, Upah: ${job.formattedWage}, Jarak: ${job.distanceKm} km dari lokasi Anda',
      hint: 'Ketuk dua kali untuk melihat detail lengkap tugas ini',
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Bar: Category + Data Source + Match Badge + Bookmark Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              job.category,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: job.isFromDatabase ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  job.isFromDatabase ? Icons.cloud_done : Icons.api,
                                  size: 11,
                                  color: job.isFromDatabase ? const Color(0xFF0284C7) : AppColors.textMuted,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  job.dataSourceLabel,
                                  style: TextStyle(
                                    color: job.isFromDatabase ? const Color(0xFF0284C7) : AppColors.textMuted,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SmartMatchBadge(score: 92),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Semantics(
                      button: true,
                      label: isBookmarked ? 'Hapus ${job.title} dari favorit' : 'Simpan ${job.title} ke favorit',
                      child: IconButton(
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked ? AppColors.primary : AppColors.textMuted,
                        ),
                        tooltip: isBookmarked ? 'Hapus bookmark' : 'Simpan lowongan',
                        onPressed: onBookmarkToggle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Employer & Distance
                Row(
                  children: [
                    const Icon(Icons.business_outlined, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${job.employerName} • 📍 ${job.distanceKm} km',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Skill Chips
                if (job.requiredSkills.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: job.requiredSkills.take(3).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(fontSize: 10, color: AppColors.textMain),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 10),

                // Bottom Row: Wage + Escrow Indicator + Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upah Terjamin',
                          style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                        Text(
                          job.formattedWage,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield, size: 10, color: AppColors.secondary),
                              SizedBox(width: 2),
                              Text(
                                'Escrow',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textMuted),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
