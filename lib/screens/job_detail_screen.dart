import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';
import '../widgets/escrow_status_card.dart';
import '../widgets/smart_match_badge.dart';

class JobDetailScreen extends StatelessWidget {
  final JobModel? job;
  final Map<String, dynamic>? jobData;

  const JobDetailScreen({super.key, this.job, this.jobData});

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final currentId = job?.id ?? jobData?['id']?.toString() ?? 'job-001';
    final isBookmarked = jobProvider.isBookmarked(currentId);
    final isAlreadyActive = jobProvider.activeJob?.id == currentId;

    final title = job?.title ?? jobData?['title'] ?? 'Transkripsi Audio Webinar Bahasa Indonesia';
    final employer = job?.employerName ?? jobData?['employer'] ?? 'PT Inovasi Inklusif';
    final wageStr = job?.formattedWage ?? jobData?['wage'] ?? 'Rp 50.000';
    final distanceStr = job != null ? '📍 ${job!.distanceKm} km' : jobData?['distance'] ?? '📍 1.2 km';
    final category = job?.category ?? 'Transkripsi & Teks Mandiri';
    final description = job?.description ??
        'Pemberi kerja memerlukan bantuan untuk mentranskripsikan rekaman audio webinar 45 menit ke dalam dokumen Google Docs atau Microsoft Word. Rekaman suara jernih dan bebas kebisingan.\n\n'
            'Ketentuan Pengumpulan:\n'
            '• Berkas hasil berupa tautan Google Docs atau file .docx\n'
            '• Bahasa Indonesia baku sesuai dengan konteks rekaman\n'
            '• Batas waktu pengerjaan: 48 jam sejak tawaran diterima.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pekerjaan'),
        actions: [
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
            return _buildCompactDetail(context, currentId, title, employer, category, wageStr, distanceStr, description, isAlreadyActive);
          } else {
            return _buildExpandedDetail(context, currentId, title, employer, category, wageStr, distanceStr, description, isAlreadyActive);
          }
        },
      ),
    );
  }

  Widget _buildCompactDetail(
    BuildContext context,
    String jobId,
    String title,
    String employer,
    String category,
    String wage,
    String distance,
    String description,
    bool isAlreadyActive,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJobHeader(title, employer, distance, category),
          const SizedBox(height: 16),
          const SmartMatchBadge(score: 92, rank: 'Peringkat #1', isDetailed: true),
          const SizedBox(height: 16),
          EscrowStatusCard(amount: wage, status: 'Locked', isDetailed: true),
          const SizedBox(height: 16),
          _buildJobDescription(description),
          const SizedBox(height: 24),
          _buildActionButtons(context, jobId, isAlreadyActive),
        ],
      ),
    );
  }

  Widget _buildExpandedDetail(
    BuildContext context,
    String jobId,
    String title,
    String employer,
    String category,
    String wage,
    String distance,
    String description,
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
                _buildJobHeader(title, employer, distance, category),
                const SizedBox(height: 20),
                _buildJobDescription(description),
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
                EscrowStatusCard(amount: wage, status: 'Locked', isDetailed: true),
                const SizedBox(height: 20),
                _buildActionButtons(context, jobId, isAlreadyActive),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobHeader(String title, String employer, String distance, String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Kategori: $category',
            style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('$employer • $distance', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
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
