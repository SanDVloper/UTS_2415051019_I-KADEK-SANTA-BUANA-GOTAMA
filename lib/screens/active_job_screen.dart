import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/job_provider.dart';
import '../providers/user_provider.dart';

class ActiveJobScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const ActiveJobScreen({super.key, this.onNavigateToTab});

  @override
  State<ActiveJobScreen> createState() => _ActiveJobScreenState();
}

class _ActiveJobScreenState extends State<ActiveJobScreen> {
  final _submissionController = TextEditingController(
    text: 'https://docs.google.com/document/d/transkrip-audio-final',
  );

  @override
  void dispose() {
    _submissionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final userProvider = context.watch<UserProvider>();
    final activeJob = jobProvider.activeJob;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppConstants.compactBreakpoint;

        return Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
            child: activeJob == null
                ? _buildEmptyState(context)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pekerjaan Berjalan & Alur Upah',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              const Text('Pelacakan status pengerjaan dan pencairan dana Escrow', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: activeJob.status == 'Completed'
                                  ? AppColors.secondaryLight
                                  : AppColors.warningLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Status: ${activeJob.status}',
                              style: TextStyle(
                                color: activeJob.status == 'Completed' ? AppColors.secondary : AppColors.warning,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Job Summary
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(activeJob.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                'Pemberi Kerja: ${activeJob.employerName} • ${activeJob.location}',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                              const Divider(height: 24),
                              // Escrow Card
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '🔒 Dana Terkunci di Escrow: ${activeJob.formattedWage}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 13),
                                    ),
                                    Text(
                                      activeJob.paymentStatus == 'Locked' ? 'Aman Terjamin ✓' : 'Proses Pencairan ✓',
                                      style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stepper Alur Transaksi
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tahapan Alur Pengerjaan (Golden Flow)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 14),
                              _buildStepItem('1', 'Pekerjaan Dibuat & Upah Terkunci', 'Dana ${activeJob.formattedWage} telah diamankan sistem', true),
                              _buildStepItem('2', 'Worker Menerima Pekerjaan', 'Tugas masuk ke lembar kerja aktif', true),
                              _buildStepItem(
                                '3',
                                'Pengerjaan & Pengumpulan Hasil',
                                activeJob.submissionUrl != null ? 'Tautan: ${activeJob.submissionUrl}' : 'Unggah berkas hasil tugas pada formulir di bawah',
                                activeJob.status == 'Waiting Confirmation' || activeJob.status == 'Completed',
                              ),
                              _buildStepItem(
                                '4',
                                'Konfirmasi Pemberi Kerja',
                                activeJob.status == 'Completed' ? 'Employer telah menyetujui hasil pengerjaan' : 'Employer memeriksa kesesuaian hasil pengerjaan',
                                activeJob.status == 'Completed',
                              ),
                              _buildStepItem(
                                '5',
                                'Pencairan Dana ke Saldo',
                                activeJob.status == 'Completed' ? 'Upah telah ditambahkan ke saldo Made Suardana' : 'Upah otomatis diteruskan setelah disetujui',
                                activeJob.status == 'Completed',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Submission / Action Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildActionArea(context, activeJob, jobProvider, userProvider),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Pekerjaan Berjalan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Anda belum menerima tugas apapun. Buka katalog untuk memilih lowongan yang sesuai kemampuan Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(1); // Go to Catalog tab
                }
              },
              icon: const Icon(Icons.search),
              label: const Text('Buka Katalog Pekerjaan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionArea(
    BuildContext context,
    dynamic activeJob,
    JobProvider jobProvider,
    UserProvider userProvider,
  ) {
    if (activeJob.status == 'Active') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pengumpulan Hasil Tugas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _submissionController,
            decoration: const InputDecoration(
              labelText: 'Tautan Berkas Hasil Transkripsi (Google Docs/Drive)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi Selesai'),
                  content: const Text('Apakah Anda yakin ingin menandai pekerjaan ini selesai dan mengirimkan hasil tugas ke Employer?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        jobProvider.submitJob(activeJob.id, _submissionController.text.trim());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pekerjaan berhasil diserahkan! Menunggu konfirmasi Employer.'),
                            backgroundColor: AppColors.secondary,
                          ),
                        );
                      },
                      child: const Text('Ya, Kirim Hasil'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Tandai Selesai & Kirim Hasil ke Employer'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
          ),
        ],
      );
    } else if (activeJob.status == 'Waiting Confirmation') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.hourglass_top, color: AppColors.warning, size: 20),
              SizedBox(width: 8),
              Text('Menunggu Konfirmasi Employer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tautan hasil tugas Anda: ${activeJob.submissionUrl}\nEmployer sedang meninjau kualitas pekerjaan.',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {
              jobProvider.confirmJobCompletion(activeJob.id);
              userProvider.completeJob(activeJob.wage);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Simulasi Berhasil: Employer menyetujui tugas! Saldo bertambah ${activeJob.formattedWage}.'),
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
            icon: const Icon(Icons.verified_outlined, color: AppColors.secondary),
            label: const Text('(Simulasi) Setujui & Cairkan Saldo'),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.secondary, size: 22),
              SizedBox(width: 8),
              Text('Tugas Selesai & Upah Diterima', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pekerjaan ini telah berhasil diselesaikan dan upah ${activeJob.formattedWage} telah masuk ke saldo Made Suardana.',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      );
    }
  }

  Widget _buildStepItem(String num, String title, String subtitle, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isDone ? AppColors.secondary : AppColors.border,
            child: Text(
              isDone ? '✓' : num,
              style: TextStyle(
                color: isDone ? Colors.white : AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDone ? AppColors.textMain : AppColors.textMuted)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
