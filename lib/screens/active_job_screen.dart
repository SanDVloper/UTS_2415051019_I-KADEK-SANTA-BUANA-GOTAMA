import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/job_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/escrow_status_card.dart';

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
    final isWorker = userProvider.worker.role == 'Worker';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppConstants.compactBreakpoint;

        return Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
            child: activeJob == null
                ? _buildEmptyState(context, isWorker)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Role Indicator Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isWorker ? AppColors.primaryLight : AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isWorker ? Icons.person_pin : Icons.business_center,
                              size: 14,
                              color: isWorker ? AppColors.primary : AppColors.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isWorker
                                  ? 'Mode Tampilan: Lembar Kerja Pekerja (Worker)'
                                  : 'Mode Tampilan: Panel Verifikasi Pemberi Kerja (Employer)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isWorker ? AppColors.primary : AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isWorker ? 'Pekerjaan Berjalan & Alur Upah' : 'Panel Manajemen Tugas & Escrow',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isWorker
                                      ? 'Pelacakan status pengerjaan dan pencairan dana Escrow ke saldo Anda'
                                      : 'Meninjau hasil submission worker dan menyetujui pelepasan dana Escrow',
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
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
                                isWorker
                                    ? 'Pemberi Kerja: ${activeJob.employerName} • ${activeJob.location}'
                                    : 'Pelaksana Tugas: Made Suardana • ${activeJob.location}',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                              const Divider(height: 24),
                              // Reusable Escrow Card
                              EscrowStatusCard(
                                amount: activeJob.formattedWage,
                                status: activeJob.paymentStatus,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stepper Alur Transaksi (Role-Specific Labels)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isWorker ? 'Tahapan Pengerjaan Worker (Golden Flow)' : 'Tahapan Alur Pengawasan Escrow (Employer Flow)',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 14),
                              _buildStepItem(
                                '1',
                                isWorker ? 'Pekerjaan Dibuat & Upah Terkunci' : 'Anda Mendepositkan Upah ke Escrow',
                                'Dana ${activeJob.formattedWage} diamankan di sistem',
                                true,
                              ),
                              _buildStepItem(
                                '2',
                                isWorker ? 'Worker Menerima Pekerjaan' : 'Worker Ditugaskan untuk Pekerjaan Ini',
                                'Tugas masuk ke lembar kerja aktif',
                                true,
                              ),
                              _buildStepItem(
                                '3',
                                isWorker ? 'Pengumpulan Berkas Hasil Tugas' : 'Worker Mengunggah Berkas Hasil Tugas',
                                activeJob.submissionUrl != null ? 'Tautan: ${activeJob.submissionUrl}' : 'Menunggu pengumpulan link pengerjaan',
                                activeJob.status == 'Waiting Confirmation' || activeJob.status == 'Completed',
                              ),
                              _buildStepItem(
                                '4',
                                isWorker ? 'Pemeriksaan oleh Employer' : 'Anda Memeriksa Kesesuaian Hasil Tugas',
                                activeJob.status == 'Completed'
                                    ? 'Employer telah memverifikasi dan menyetujui hasil'
                                    : 'Meninjau berkas tugas yang diserahkan worker',
                                activeJob.status == 'Completed',
                              ),
                              _buildStepItem(
                                '5',
                                isWorker ? 'Pencairan Dana ke Saldo Anda' : 'Otomasi Pencairan Dana ke Saldo Worker',
                                activeJob.status == 'Completed'
                                    ? 'Dana ${activeJob.formattedWage} berhasil masuk ke rekening/saldo pekerja'
                                    : 'Upah diteruskan setelah hasil pengerjaan disetujui',
                                activeJob.status == 'Completed',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Submission / Action Card (Role-Specific)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildActionArea(context, activeJob, jobProvider, userProvider, isWorker),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isWorker) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              isWorker ? 'Belum Ada Pekerjaan Berjalan' : 'Belum Ada Penugasan Aktif',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isWorker
                  ? 'Anda belum menerima tugas apapun. Buka katalog untuk memilih lowongan yang sesuai kemampuan Anda.'
                  : 'Belum ada worker yang sedang mengerjakan lowongan Anda. Buat lowongan baru untuk mencari kandidat.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(isWorker ? 1 : 2); // Catalog for worker, Create for employer
                }
              },
              icon: Icon(isWorker ? Icons.search : Icons.add_circle_outline),
              label: Text(isWorker ? 'Buka Katalog Pekerjaan' : 'Posting Lowongan Baru'),
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
    bool isWorker,
  ) {
    if (isWorker) {
      // ================= WORKER ACTIONS =================
      if (activeJob.status == 'Active') {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pengumpulan Hasil Tugas (Worker Submission)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                    title: const Text('Konfirmasi Pengumpulan'),
                    content: const Text('Apakah Anda yakin ingin mengirimkan hasil tugas ini ke Employer untuk diverifikasi?'),
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
              icon: const Icon(Icons.send_rounded),
              label: const Text('Kirim Hasil Tugas ke Employer'),
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
              'Tautan tugas yang Anda serahkan:\n${activeJob.submissionUrl}\n\nPemberi kerja sedang meninjau kualitas pekerjaan Anda sebelum mencairkan dana escrow.',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '💡 Tip Dosen: Beralihlah ke peran "Employer" di tab Profil untuk mencoba menyetujui tugas ini dari sisi pemberi kerja.',
                style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
              ),
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
    } else {
      // ================= EMPLOYER ACTIONS =================
      if (activeJob.status == 'Active') {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.pending_actions, color: AppColors.warning, size: 20),
                SizedBox(width: 8),
                Text('Status: Sedang Dikerjakan oleh Worker', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Worker Made Suardana sedang menyelesaikan instruksi tugas ini. Dana sebesar ${activeJob.formattedWage} Anda aman terlindungi di Escrow hingga berkas tugas dikumpulkan.',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
            ),
          ],
        );
      } else if (activeJob.status == 'Waiting Confirmation') {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assignment_turned_in, color: AppColors.secondary, size: 22),
                SizedBox(width: 8),
                Text('Tugas Siap Diverifikasi (Employer Review)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Worker telah mengumpulkan hasil pengerjaan pada tautan berikut:\n${activeJob.submissionUrl}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMain, fontWeight: FontWeight.w500, height: 1.4),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Setujui & Cairkan Escrow'),
                    content: Text('Apakah Anda puas dengan hasil tugas ini dan menyetujui pelepasan dana ${activeJob.formattedWage} ke saldo worker?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          jobProvider.confirmJobCompletion(activeJob.id);
                          userProvider.completeJob(activeJob.wage);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pekerjaan disetujui! Dana ${activeJob.formattedWage} sukses ditransfer ke worker.'),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                        child: const Text('Ya, Setujui & Cairkan'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.verified, size: 18),
              label: const Text('Setujui Hasil & Cairkan Dana Escrow'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
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
                Text('Tugas Terverifikasi Selesai', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondary)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Anda telah memverifikasi tugas ini dan dana upah ${activeJob.formattedWage} telah resmi dicairkan ke saldo worker.',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        );
      }
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
