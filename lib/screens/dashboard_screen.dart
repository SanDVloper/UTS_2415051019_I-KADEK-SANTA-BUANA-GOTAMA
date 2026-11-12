import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/job_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/escrow_status_card.dart';
import '../widgets/stat_metric_card.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final jobProvider = context.watch<JobProvider>();
    final worker = userProvider.worker;
    final activeJob = jobProvider.activeJob;
    final isWorker = worker.role == 'Worker';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppConstants.compactBreakpoint;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Banner (Role-Specific)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isWorker
                        ? [AppColors.primaryDark, AppColors.primary]
                        : [const Color(0xFF047857), AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Halo, ${worker.name} ${isWorker ? "👋" : "🏢"}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${worker.role} Terverifikasi ✓',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isWorker
                          ? 'Ada ${jobProvider.allJobs.length} lowongan aktif yang cocok dengan keahlian dan radius ${worker.radiusKm.toInt()} km Anda.'
                          : 'Kelola ${jobProvider.allJobs.length} lowongan aktif, pantau dana di Escrow, dan verifikasi hasil tugas worker.',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Responsive Metric Cards (Role-Specific)
              Text(
                isWorker ? 'Ringkasan Aktivitas Pekerja' : 'Ringkasan Dashboard Pemberi Kerja',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              isCompact
                  ? _buildCompactMetrics(isWorker, activeJob != null ? '1' : '0', '${worker.completedJobsCount}', worker.formattedBalance, jobProvider)
                  : _buildExpandedMetrics(isWorker, activeJob != null ? '1' : '0', '${worker.completedJobsCount}', worker.formattedBalance, jobProvider),

              const SizedBox(height: 24),

              // Active Job Escrow Quick Card (Role-Specific)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: activeJob != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isWorker ? 'Pekerjaan yang Sedang Anda Kerjakan' : 'Pantauan Tugas & Dana Escrow Terkunci',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: activeJob.status == 'Completed' ? AppColors.secondaryLight : AppColors.warningLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    activeJob.status,
                                    style: TextStyle(
                                      color: activeJob.status == 'Completed' ? AppColors.secondary : AppColors.warning,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            EscrowStatusCard(
                              amount: activeJob.formattedWage,
                              status: activeJob.paymentStatus,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              activeJob.title,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isWorker
                                  ? 'Pemberi Kerja: ${activeJob.employerName} • ${activeJob.location}'
                                  : 'Ditugaskan kepada: Made Suardana • ${activeJob.location}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: activeJob.status == 'Completed'
                                    ? 1.0
                                    : activeJob.status == 'Waiting Confirmation'
                                        ? 0.75
                                        : 0.5,
                                minHeight: 6,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isWorker ? AppColors.primary : AppColors.secondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (onNavigateToTab != null) {
                                  onNavigateToTab!(3); // Navigate to Active tab
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isWorker ? AppColors.primary : AppColors.secondary,
                              ),
                              icon: const Icon(Icons.arrow_forward, size: 16),
                              label: Text(
                                isWorker
                                    ? 'Buka Lembar Kerja & Alur Upah'
                                    : 'Tinjau Hasil Tugas & Kelola Escrow',
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isWorker ? 'Belum Ada Pekerjaan Berjalan' : 'Belum Ada Penugasan Aktif',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isWorker
                                  ? 'Pilih dan ambil lowongan yang sesuai dari katalog pekerjaan untuk mulai bekerja.'
                                  : 'Buat lowongan pekerjaan baru untuk merekrut worker bertalenta inklusif.',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (onNavigateToTab != null) {
                                  onNavigateToTab!(isWorker ? 1 : 2); // Go to Catalog (1) or Create Job (2)
                                }
                              },
                              icon: Icon(isWorker ? Icons.search : Icons.add_circle_outline, size: 16),
                              label: Text(isWorker ? 'Jelajahi Katalog Pekerjaan' : 'Posting Lowongan Baru Sekarang'),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactMetrics(bool isWorker, String activeCount, String completedCount, String balance, JobProvider jobProvider) {
    if (isWorker) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 155,
              child: StatMetricCard(
                value: activeCount,
                label: 'Pekerjaan Aktif',
                icon: Icons.work_outline,
                iconColor: AppColors.primary,
                backgroundColor: AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 155,
              child: StatMetricCard(
                value: completedCount,
                label: 'Tugas Selesai',
                icon: Icons.task_alt,
                iconColor: AppColors.secondary,
                backgroundColor: AppColors.secondaryLight,
              ),
            ),
            const SizedBox(width: 10),
            const SizedBox(
              width: 155,
              child: StatMetricCard(
                value: '94%',
                label: 'Match Score Avg',
                icon: Icons.star_outline,
                iconColor: AppColors.warning,
                backgroundColor: AppColors.warningLight,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 155,
              child: StatMetricCard(
                value: balance,
                label: 'Total Saldo',
                icon: Icons.account_balance_wallet_outlined,
                iconColor: Colors.purple,
                backgroundColor: const Color(0xFFF3E8FF),
              ),
            ),
          ],
        ),
      );
    } else {
      // Employer Compact Metrics
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 155,
              child: StatMetricCard(
                value: '${jobProvider.allJobs.length}',
                label: 'Lowongan Dibuka',
                icon: Icons.campaign_outlined,
                iconColor: AppColors.secondary,
                backgroundColor: AppColors.secondaryLight,
              ),
            ),
            const SizedBox(width: 10),
            const SizedBox(
              width: 155,
              child: StatMetricCard(
                value: '4 Orang',
                label: 'Kandidat Cocok',
                icon: Icons.people_outline,
                iconColor: AppColors.primary,
                backgroundColor: AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 155,
              child: StatMetricCard(
                value: jobProvider.activeJob != null ? 'Rp 50.000' : 'Rp 0',
                label: 'Dana di Escrow',
                icon: Icons.shield_outlined,
                iconColor: AppColors.warning,
                backgroundColor: AppColors.warningLight,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 155,
              child: StatMetricCard(
                value: '${jobProvider.databaseJobCount}',
                label: 'Tersimpan di Cloud DB',
                icon: Icons.cloud_done_outlined,
                iconColor: const Color(0xFF0284C7),
                backgroundColor: const Color(0xFFE0F2FE),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildExpandedMetrics(bool isWorker, String activeCount, String completedCount, String balance, JobProvider jobProvider) {
    if (isWorker) {
      return Row(
        children: [
          Expanded(
            child: StatMetricCard(
              value: activeCount,
              label: 'Pekerjaan Aktif',
              icon: Icons.work_outline,
              iconColor: AppColors.primary,
              backgroundColor: AppColors.primaryLight,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: StatMetricCard(
              value: completedCount,
              label: 'Tugas Selesai',
              icon: Icons.task_alt,
              iconColor: AppColors.secondary,
              backgroundColor: AppColors.secondaryLight,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: StatMetricCard(
              value: '94%',
              label: 'Rata-rata Match',
              icon: Icons.star_outline,
              iconColor: AppColors.warning,
              backgroundColor: AppColors.warningLight,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: StatMetricCard(
              value: balance,
              label: 'Total Saldo Diterima',
              icon: Icons.account_balance_wallet_outlined,
              iconColor: Colors.purple,
              backgroundColor: const Color(0xFFF3E8FF),
            ),
          ),
        ],
      );
    } else {
      // Employer Expanded Metrics
      return Row(
        children: [
          Expanded(
            child: StatMetricCard(
              value: '${jobProvider.allJobs.length}',
              label: 'Lowongan Dibuka',
              icon: Icons.campaign_outlined,
              iconColor: AppColors.secondary,
              backgroundColor: AppColors.secondaryLight,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: StatMetricCard(
              value: '4 Kandidat',
              label: 'Kandidat Cocok',
              icon: Icons.people_outline,
              iconColor: AppColors.primary,
              backgroundColor: AppColors.primaryLight,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: StatMetricCard(
              value: jobProvider.activeJob != null ? 'Rp 50.000' : 'Rp 0',
              label: 'Upah di Escrow',
              icon: Icons.shield_outlined,
              iconColor: AppColors.warning,
              backgroundColor: AppColors.warningLight,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: StatMetricCard(
              value: '${jobProvider.databaseJobCount}',
              label: 'Records di Supabase',
              icon: Icons.cloud_done_outlined,
              iconColor: const Color(0xFF0284C7),
              backgroundColor: const Color(0xFFE0F2FE),
            ),
          ),
        ],
      );
    }
  }
}
