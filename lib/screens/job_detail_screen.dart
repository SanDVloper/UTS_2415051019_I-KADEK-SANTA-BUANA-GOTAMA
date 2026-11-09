import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/job_model.dart';

class JobDetailScreen extends StatelessWidget {
  final JobModel? job;
  final Map<String, dynamic>? jobData;

  const JobDetailScreen({super.key, this.job, this.jobData});

  @override
  Widget build(BuildContext context) {
    final title = job?.title ?? jobData?['title'] ?? 'Transkripsi Audio Webinar Bahasa Indonesia';
    final employer = job?.employerName ?? jobData?['employer'] ?? 'PT Inovasi Inklusif';
    final wageStr = job?.formattedWage ?? jobData?['wage'] ?? 'Rp 50.000';
    final distanceStr = job != null ? '📍 ${job!.distanceKm} km' : jobData?['distance'] ?? '📍 1.2 km';
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
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pekerjaan disimpan ke Favorit')),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < AppConstants.compactBreakpoint;

          if (isCompact) {
            return _buildCompactDetail(context, title, employer, wageStr, distanceStr, description);
          } else {
            return _buildExpandedDetail(context, title, employer, wageStr, distanceStr, description);
          }
        },
      ),
    );
  }

  Widget _buildCompactDetail(BuildContext context, String title, String employer, String wage, String distance, String description) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJobHeader(title, employer, distance),
          const SizedBox(height: 16),
          _buildSmartMatchCard(),
          const SizedBox(height: 16),
          _buildEscrowWageCard(wage),
          const SizedBox(height: 16),
          _buildJobDescription(description),
          const SizedBox(height: 24),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildExpandedDetail(BuildContext context, String title, String employer, String wage, String distance, String description) {
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
                _buildJobHeader(title, employer, distance),
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
                _buildSmartMatchCard(),
                const SizedBox(height: 16),
                _buildEscrowWageCard(wage),
                const SizedBox(height: 20),
                _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobHeader(String title, String employer, String distance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'Kategori: Transkripsi & Teks Mandiri',
            style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('$employer • $distance', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
      ],
    );
  }

  Widget _buildSmartMatchCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('⭐ Match Score: 92%', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 14)),
              Text('Peringkat #1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.secondary)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '✓ 5/5 Kemampuan Terpenuhi (Mengetik, Membaca, Komunikasi Teks)\n'
            '✓ Jarak Sangat Dekat: 1.2 km dari domisili Anda\n'
            '✓ Kompatibilitas Aksesibilitas: Instruksi 100% via teks mandiri',
            style: TextStyle(fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEscrowWageCard(String wage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nominal Upah Aman', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text(wage, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🔒 Upah Terkunci di Sistem',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
            ),
          ),
        ],
      ),
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

  Widget _buildActionButtons(BuildContext context) {
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pekerjaan Diterima! Upah otomatis terkunci aman di Escrow.'),
                  backgroundColor: AppColors.secondary,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('✓ Terima Pekerjaan Ini'),
          ),
        ),
      ],
    );
  }
}
