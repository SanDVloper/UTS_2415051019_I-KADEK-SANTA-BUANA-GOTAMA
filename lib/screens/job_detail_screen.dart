import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';
import '../widgets/escrow_status_card.dart';
import '../widgets/smart_match_badge.dart';
import 'edit_job_screen.dart';

class JobDetailScreen extends StatelessWidget {
  final JobModel? job;
  final Map<String, dynamic>? jobData;

  const JobDetailScreen({super.key, this.job, this.jobData});

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final currentId = job?.id ?? jobData?['id']?.toString() ?? 'job-api-1';

    // Cari model terbaru dari state provider jika telah mengalami Update
    final currentJob = jobProvider.allJobs.firstWhere(
      (j) => j.id == currentId,
      orElse: () =>
          job ??
          JobModel(
            id: currentId,
            title: jobData?['title'] ?? 'Transkripsi Audio Webinar Bahasa Indonesia',
            description: 'Pekerjaan mikro terverifikasi dengan sistem pembayaran aman Escrow.',
            category: 'Transkripsi & Pengetikan',
            wage: 50000,
            employerName: 'PT Inovasi Inklusif',
            location: 'Denpasar Barat',
            distanceKm: 1.2,
            requiredSkills: const ['Mengetik Cepat', 'Komunikasi Teks'],
            createdAt: DateTime.now(),
          ),
    );

    final isBookmarked = jobProvider.isBookmarked(currentId);
    final isAlreadyActive = jobProvider.activeJob?.id == currentId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pekerjaan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Lowongan (Update Database)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditJobScreen(job: currentJob),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? AppColors.primary : null,
            ),
            tooltip: isBookmarked ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
            onPressed: () {
              jobProvider.toggleBookmark(currentId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isBookmarked ? 'Pekerjaan dihapus dari Favorit' : 'Pekerjaan disimpan ke Favorit!',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < AppConstants.compactBreakpoint;

          if (isCompact) {
            return _buildCompactDetail(
              context,
              currentJob,
              isAlreadyActive,
            );
          } else {
            return _buildExpandedDetail(
              context,
              currentJob,
              isAlreadyActive,
            );
          }
        },
      ),
    );
  }

  Widget _buildCompactDetail(
    BuildContext context,
    JobModel item,
    bool isAlreadyActive,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJobHeader(item),
          const SizedBox(height: 16),
          const SmartMatchBadge(score: 92, rank: 'Peringkat #1', isDetailed: true),
          const SizedBox(height: 16),
          EscrowStatusCard(amount: item.formattedWage, status: item.paymentStatus, isDetailed: true),
          const SizedBox(height: 16),
          _buildJobDescription(item.description),
          const SizedBox(height: 24),
          _buildActionButtons(context, item.id, isAlreadyActive),
        ],
      ),
    );
  }

  Widget _buildExpandedDetail(
    BuildContext context,
    JobModel item,
    bool isAlreadyActive,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (60%): Description & Task Details
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildJobHeader(item),
                const SizedBox(height: 20),
                _buildJobDescription(item.description),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right Column (40%): Match Score & Escrow Protection
          Expanded(
            flex: 4,
            child: Column(
              children: [
                const SmartMatchBadge(score: 92, rank: 'Peringkat #1', isDetailed: true),
                const SizedBox(height: 16),
                EscrowStatusCard(amount: item.formattedWage, status: item.paymentStatus, isDetailed: true),
                const SizedBox(height: 20),
                _buildActionButtons(context, item.id, isAlreadyActive),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobHeader(JobModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Kategori: ${item.category}',
                style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: item.isFromDatabase ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.isFromDatabase ? Icons.cloud_done : Icons.api,
                    size: 11,
                    color: item.isFromDatabase ? const Color(0xFF0284C7) : AppColors.textMuted,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    item.dataSourceLabel,
                    style: TextStyle(
                      color: item.isFromDatabase ? const Color(0xFF0284C7) : AppColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('${item.employerName} • 📍 ${item.distanceKm} km', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
      ],
    );
  }

  Widget _buildJobDescription(String description) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Deskripsi Tugas & Luaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String jobId, bool isAlreadyActive) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            child: const Text('Kembali'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isAlreadyActive
                ? null
                : () {
                    context.read<JobProvider>().acceptJob(jobId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pekerjaan Diterima! Upah otomatis terkunci aman di Escrow.'),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                    Navigator.pop(context);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAlreadyActive ? Colors.grey : AppColors.secondary,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(isAlreadyActive ? '✓ Sedang Dikerjakan' : '✓ Terima Pekerjaan Ini'),
          ),
        ),
      ],
    );
  }
}
