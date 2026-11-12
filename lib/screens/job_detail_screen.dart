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

  void _confirmDelete(BuildContext context, JobModel targetJob) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 44),
        title: const Text(
          'Konfirmasi Hapus Data',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apakah Anda yakin ingin menghapus data lowongan ini dari Database Supabase?',
              style: TextStyle(color: AppColors.textMain, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Judul: ${targetJob.title}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
                  Text('• Sumber: ${targetJob.dataSourceLabel}', style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B))),
                  Text('• ID: ${targetJob.id}', style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B))),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '⚠️ Operasi ini bersifat permanen dan tidak dapat dibatalkan.',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              final success = await context.read<JobProvider>().deleteJob(targetJob.id);

              if (success) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.delete_forever, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Lowongan "${targetJob.title}" berhasil dihapus dari Database!'),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.danger,
                  ),
                );
                navigator.pop(); // Kembali ke katalog
              }
            },
            icon: const Icon(Icons.delete_forever, size: 16),
            label: const Text('Ya, Hapus Sekarang'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          ),
        ],
      ),
    );
  }

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
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            tooltip: 'Hapus Lowongan (Delete Database)',
            onPressed: () => _confirmDelete(context, currentJob),
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
          _buildActionButtons(context, item, isAlreadyActive),
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
                _buildActionButtons(context, item, isAlreadyActive),
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

  Widget _buildActionButtons(BuildContext context, JobModel item, bool isAlreadyActive) {
    return Column(
      children: [
        Row(
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
                        context.read<JobProvider>().acceptJob(item.id);
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
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _confirmDelete(context, item),
            icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
            label: const Text('Hapus Lowongan dari Database', style: TextStyle(color: AppColors.danger)),
          ),
        ),
      ],
    );
  }
}
