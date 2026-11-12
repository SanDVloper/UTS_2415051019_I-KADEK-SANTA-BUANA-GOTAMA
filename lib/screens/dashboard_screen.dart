import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/job_provider.dart';
import '../providers/user_provider.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final jobProvider = context.watch<JobProvider>();
    final worker = userProvider.worker;
    final activeJob = jobProvider.activeJob;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppConstants.compactBreakpoint;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
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
                        Text(
                          'Halo, ${worker.name} 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                      'Ada ${jobProvider.allJobs.length} lowongan aktif yang cocok dengan keahlian dan radius ${worker.radiusKm.toInt()} km Anda.',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Responsive Metric Cards
              Text(
                'Ringkasan Aktivitas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              isCompact
                  ? _buildCompactMetrics(activeJob != null ? '1' : '0', '${worker.completedJobsCount}', worker.formattedBalance)
                  : _buildExpandedMetrics(activeJob != null ? '1' : '0', '${worker.completedJobsCount}', worker.formattedBalance),

              const SizedBox(height: 24),

              // Active Job Escrow Quick Card
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Pekerjaan Aktif • ${activeJob.status}',
                                    style: const TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  '🔒 Upah Terkunci: ${activeJob.formattedWage}',
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              activeJob.title,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pemberi Kerja: ${activeJob.employerName} • ${activeJob.location}',
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
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (onNavigateToTab != null) {
                                  onNavigateToTab!(3); // Navigate to Active tab
                                }
                              },
                              icon: const Icon(Icons.arrow_forward, size: 16),
                              label: const Text('Buka Lembar Kerja & Alur Upah'),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Belum Ada Pekerjaan Berjalan',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Pilih dan ambil lowongan yang sesuai dari katalog pekerjaan untuk mulai bekerja.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (onNavigateToTab != null) {
                                  onNavigateToTab!(1); // Navigate to Catalog tab
                                }
                              },
                              icon: const Icon(Icons.search, size: 16),
                              label: const Text('Jelajahi Katalog Pekerjaan'),
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

  Widget _buildCompactMetrics(String activeCount, String completedCount, String balance) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard(activeCount, 'Pekerjaan Aktif', Icons.work_outline, AppColors.primary, AppColors.primaryLight),
          const SizedBox(width: 10),
          _buildStatCard(completedCount, 'Tugas Selesai', Icons.task_alt, AppColors.secondary, AppColors.secondaryLight),
          const SizedBox(width: 10),
          _buildStatCard('94%', 'Match Score Avg', Icons.star_outline, AppColors.warning, AppColors.warningLight),
          const SizedBox(width: 10),
          _buildStatCard(balance, 'Total Saldo', Icons.account_balance_wallet_outlined, Colors.purple, const Color(0xFFF3E8FF)),
        ],
      ),
    );
  }

  Widget _buildExpandedMetrics(String activeCount, String completedCount, String balance) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(activeCount, 'Pekerjaan Aktif', Icons.work_outline, AppColors.primary, AppColors.primaryLight)),
        const SizedBox(width: 14),
        Expanded(child: _buildStatCard(completedCount, 'Tugas Selesai', Icons.task_alt, AppColors.secondary, AppColors.secondaryLight)),
        const SizedBox(width: 14),
        Expanded(child: _buildStatCard('94%', 'Rata-rata Match', Icons.star_outline, AppColors.warning, AppColors.warningLight)),
        const SizedBox(width: 14),
        Expanded(child: _buildStatCard(balance, 'Total Saldo Diterima', Icons.account_balance_wallet_outlined, Colors.purple, const Color(0xFFF3E8FF))),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color, Color bgColor) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
