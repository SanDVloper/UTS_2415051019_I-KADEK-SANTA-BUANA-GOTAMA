import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> _skills = ['Mengetik Cepat', 'Membaca Teks', 'Komunikasi Teks', 'Excel'];
  double _radiusKm = 5.0;
  bool _isHighContrast = false;
  bool _isLargeFont = false;
  bool _isTextOnly = true;

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
                // Profile Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryLight,
                          child: Text('MS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Made Suardana', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 2),
                              Text('Worker Terverifikasi ✓ • Denpasar Barat', style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                              Text('NIM: 2415051019 • Rating: 4.9/5 (12 Selesai)', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Skill Management
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
                              onPressed: () {
                                _showAddSkillDialog(context);
                              },
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Tambah Skill', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _skills.map((s) {
                            return Chip(
                              label: Text(s, style: const TextStyle(fontSize: 12)),
                              deleteIcon: const Icon(Icons.close, size: 14),
                              onDeleted: () {
                                setState(() => _skills.remove(s));
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Radius Lokasi Slider
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
                            Text('${_radiusKm.toInt()} km', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                        Slider(
                          value: _radiusKm,
                          min: 1,
                          max: 25,
                          divisions: 24,
                          label: '${_radiusKm.toInt()} km',
                          onChanged: (val) {
                            setState(() => _radiusKm = val);
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
                          title: const Text('Mode Kontras Tinggi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Mengoptimalkan rasio kontras warna latar belakang dan teks', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          value: _isHighContrast,
                          onChanged: (v) => setState(() => _isHighContrast = v),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Ukuran Font Ekstra Besar (+20%)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Meningkatkan keterbacaan teks untuk kenyamanan visual', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          value: _isLargeFont,
                          onChanged: (v) => setState(() => _isLargeFont = v),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Akomodasi Komunikasi Teks Mandiri', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Memprioritaskan instruksi berbasis teks tanpa panggilan suara', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          value: _isTextOnly,
                          onChanged: (v) => setState(() => _isTextOnly = v),
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
                        content: Text('Profil dan Preferensi Aksesibilitas Berhasil Diperbarui!'),
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
                setState(() => _skills.add(controller.text.trim()));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
