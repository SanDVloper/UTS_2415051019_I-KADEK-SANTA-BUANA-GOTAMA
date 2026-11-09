import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

class ActiveJobScreen extends StatefulWidget {
  const ActiveJobScreen({super.key});

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppConstants.compactBreakpoint;

        return Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
            child: Column(
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
                      decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(20)),
                      child: const Text('Status: Aktif', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 11)),
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
                        const Text('Transkripsi Audio Webinar Bahasa Indonesia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Pemberi Kerja: PT Inovasi Inklusif • Batas Waktu: 24 Jam', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        const Divider(height: 24),
                        // Escrow Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('🔒 Dana Terkunci di Escrow: Rp 50.000', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 13)),
                              Text('Aman Terjamin ✓', style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w600)),
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
                        _buildStepItem('1', 'Pekerjaan Dibuat & Upah Terkunci', 'Dana Rp 50.000 telah diamankan sistem', true),
                        _buildStepItem('2', 'Worker Menerima Pekerjaan', 'Tugas masuk ke lembar kerja aktif', true),
                        _buildStepItem('3', 'Pengerjaan & Pengumpulan Hasil', 'Unggah berkas hasil tugas pada formulir di bawah', true),
                        _buildStepItem('4', 'Konfirmasi Pemberi Kerja', 'Employer memeriksa kesesuaian hasil pengerjaan', false),
                        _buildStepItem('5', 'Pencairan Dana ke Saldo', 'Upah otomatis diteruskan ke rekening pekerja', false),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Submission Form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
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
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Pekerjaan berhasil diselesaikan! Menunggu konfirmasi Employer.'),
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
