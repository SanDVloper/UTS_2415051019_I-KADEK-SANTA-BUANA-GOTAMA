import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/accessibility_provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final accessProvider = context.watch<AccessibilityProvider>();
    final worker = userProvider.worker;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppConstants.compactBreakpoint;

        return Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: worker.role == 'Worker' ? AppColors.primaryLight : AppColors.secondaryLight,
                          child: Text(
                            worker.name.isNotEmpty
                                ? worker.name.split(' ').map((e) => e[0]).take(2).join()
                                : 'MS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: worker.role == 'Worker' ? AppColors.primary : AppColors.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(worker.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('${worker.role} Terverifikasi ✓ • ${worker.location}', style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                              Text('NIM: 2415051019 • Rating: ${worker.rating}/5 (${worker.completedJobsCount} Selesai)', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Role Switcher Card (Khusus Pengujian Evaluasi Dosen UTS)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Mode Peran (Role Switcher)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Evaluasi UTS',
                                style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Ubah peran secara instan untuk menguji alur aplikasi dari sudut pandang Pekerja maupun Pemberi Kerja:',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'Worker',
                                icon: Icon(Icons.person_pin_outlined, size: 16),
                                label: Text('Pekerja', style: TextStyle(fontSize: 11)),
                              ),
                              ButtonSegment(
                                value: 'Employer',
                                icon: Icon(Icons.business_center_outlined, size: 16),
                                label: Text('Employer', style: TextStyle(fontSize: 11)),
                              ),
                            ],
                            selected: {worker.role},
                            onSelectionChanged: (Set<String> newSelection) {
                              final newRole = newSelection.first;
                              userProvider.switchRole(newRole);
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      Text('Mode peran beralih ke: $newRole'),
                                    ],
                                  ),
                                  backgroundColor: newRole == 'Worker' ? AppColors.primary : AppColors.secondary,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Conditional Content based on Role
                if (worker.role == 'Worker') ...[
                  // Skill Management (Worker only)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Daftar Kemampuan Saya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              TextButton.icon(
                                onPressed: () => _showAddSkillDialog(context),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Tambah Skill', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: worker.skills.map((s) {
                              return Chip(
                                label: Text(s, style: const TextStyle(fontSize: 12)),
                                deleteIcon: const Icon(Icons.close, size: 14),
                                onDeleted: () {
                                  userProvider.removeSkill(s);
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Radius Lokasi Slider (Worker only)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Radius Lokasi Penugasan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('${worker.radiusKm.toInt()} km', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                          Slider(
                            value: worker.radiusKm,
                            min: 1,
                            max: 25,
                            divisions: 24,
                            label: '${worker.radiusKm.toInt()} km',
                            onChanged: (val) {
                              userProvider.setRadius(val);
                            },
                          ),
                          const Text(
                            'Sistem Smart Matching hanya akan mencocokkan pekerjaan di dalam radius ini.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  // Employer Profile Card (Employer only)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.business_rounded, color: AppColors.secondary, size: 20),
                              SizedBox(width: 8),
                              Text('Informasi Lembaga & Usaha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildEmployerInfoRow('Nama Lembaga', 'PT Inovasi Inklusif'),
                          _buildEmployerInfoRow('Bidang Industri', 'Layanan Kreatif & Agensi Digital Inklusif'),
                          _buildEmployerInfoRow('Lokasi Kantor', 'Denpasar Barat, Bali'),
                          _buildEmployerInfoRow('Status Verifikasi', 'Terverifikasi Escrow Guard ✓'),
                          _buildEmployerInfoRow('Total Escrow Dikelola', 'Rp 1.500.000 (100% Aman)'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Employer Escrow & Policy Card (Employer only)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 20),
                              SizedBox(width: 8),
                              Text('Kebijakan Perekrutan & Escrow', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '• Seluruh lowongan yang Anda terbitkan otomatis mewajibkan deposit dana ke sistem Escrow sebelum pengerjaan dimulai.\n'
                            '• Anda memiliki wewenang penuh memeriksa dan menyetujui hasil tugas sebelum dana dicairkan ke saldo worker.\n'
                            '• Jangkauan penugasan terbuka untuk remote maupun on-site seluruh Bali.',
                            style: TextStyle(fontSize: 12, height: 1.6, color: AppColors.textMain),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Accessibility Settings (USP KaryaSetara)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Preferensi Aksesibilitas (WCAG AAA Compliance)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Mode Kontras Tinggi (WCAG AAA)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Rasio kontras warna 7:1 untuk kenyamanan disabilitas netra/low vision', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          value: accessProvider.isHighContrast,
                          onChanged: (_) {
                            accessProvider.toggleHighContrast();
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  accessProvider.isHighContrast
                                      ? 'Mode Kontras Tinggi WCAG AAA (7:1) Aktif'
                                      : 'Kembali ke Tema Standar Material 3',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Ukuran Font Ekstra Besar (+20%)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: const Text('TextScaler 1.2x untuk meningkatkan keterbacaan secara global', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          value: accessProvider.isLargeFont,
                          onChanged: (_) {
                            accessProvider.toggleLargeFont();
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  accessProvider.isLargeFont
                                      ? 'Skala Teks Ekstra Besar (1.2x) Aktif'
                                      : 'Skala Teks Standar (1.0x) Aktif',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Akomodasi Komunikasi Teks Mandiri', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Memprioritaskan instruksi berbasis teks tanpa panggilan suara', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          value: accessProvider.isTextOnly,
                          onChanged: (v) => accessProvider.setTextOnly(v),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profil dan Preferensi Aksesibilitas Berhasil Disimpan!'),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  },
                  child: const Text('Simpan Perubahan Profil'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddSkillDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Kemampuan Baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Contoh: Desain Grafis, Canva, Python',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<UserProvider>().addSkill(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployerInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMain),
            ),
          ),
        ],
      ),
    );
  }
}
