import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import 'job_detail_screen.dart';

class JobCatalogScreen extends StatelessWidget {
  const JobCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppConstants.compactBreakpoint;

        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Filter Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Katalog Rekomendasi Pekerjaan',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Disaring berdasarkan Smart Matching keahlian & lokasi Anda',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                    Chip(
                      backgroundColor: AppColors.primaryLight,
                      label: Text(
                        isCompact ? 'Layout: List (1 Col)' : 'Layout: Grid (2 Col)',
                        style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari judul lowongan, skill, atau instansi...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Responsive List vs Grid View
                Expanded(
                  child: isCompact ? _buildListView(context) : _buildGridView(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context) {
    return ListView.separated(
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildJobCard(context, index),
    );
  }

  Widget _buildGridView(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.45,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => _buildJobCard(context, index),
    );
  }

  Widget _buildJobCard(BuildContext context, int index) {
    final jobs = [
      {
        'title': 'Transkripsi Audio Webinar Bahasa Indonesia',
        'employer': 'PT Inovasi Inklusif',
        'distance': '📍 1.2 km',
        'match': '⭐ 92% Match (5/5 Skill)',
        'wage': 'Rp 50.000',
        'tags': ['Mengetik', 'Membaca', 'Remote'],
      },
      {
        'title': 'Input Data Rekam Pasien Klinik',
        'employer': 'Klinik Harapan Sehat',
        'distance': '📍 2.5 km',
        'match': '⭐ 88% Match (4/5 Skill)',
        'wage': 'Rp 75.000',
        'tags': ['Excel', 'Ketelitian', 'Fleksibel'],
      },
      {
        'title': 'Desain Konten Sosialisasi Disabilitas',
        'employer': 'Yayasan Peduli Sesama',
        'distance': '📍 3.8 km',
        'match': '⭐ 84% Match (4/5 Skill)',
        'wage': 'Rp 100.000',
        'tags': ['Canva', 'Komunikasi Teks'],
      },
      {
        'title': 'Pemeriksaan Ejaan & Koreksi Naskah Buku',
        'employer': 'Penerbit Mandiri',
        'distance': '📍 4.1 km',
        'match': '⭐ 82% Match (4/5 Skill)',
        'wage': 'Rp 60.000',
        'tags': ['Bahasa Indonesia', 'Koreksi Teks'],
      },
    ];

    final job = jobs[index % jobs.length];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    job['match'] as String,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  job['distance'] as String,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              job['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              job['employer'] as String,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Upah Terkunci', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    Text(
                      job['wage'] as String,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobDetailScreen(jobData: job),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(90, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Detail', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
