import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/job_model.dart';
import 'job_detail_screen.dart';

class JobCatalogScreen extends StatelessWidget {
  const JobCatalogScreen({super.key});

  static final List<JobModel> dummyJobs = [
    JobModel(
      id: 'job-001',
      title: 'Transkripsi Audio Webinar Bahasa Indonesia',
      description: 'Mengetik naskah rekaman webinar 45 menit ke dalam Google Docs dengan ejaan yang rapi.',
      category: 'Transkripsi & Pengetikan',
      wage: 50000,
      employerName: 'PT Inovasi Inklusif',
      location: 'Denpasar Barat',
      distanceKm: 1.2,
      requiredSkills: const ['Mengetik Cepat', 'Membaca Teks', 'Komunikasi Teks'],
      status: 'Active',
      paymentStatus: 'Locked',
      createdAt: DateTime.now(),
    ),
    JobModel(
      id: 'job-002',
      title: 'Input Data Rekam Pasien Klinik',
      description: 'Memindahkan berkas fisik ke format spreadsheet Google Sheet online secara akurat.',
      category: 'Entri Data & Spreadsheet',
      wage: 75000,
      employerName: 'Klinik Harapan Sehat',
      location: 'Denpasar Selatan',
      distanceKm: 2.5,
      requiredSkills: const ['Excel', 'Ketelitian', 'Fleksibel'],
      status: 'Active',
      paymentStatus: 'Locked',
      createdAt: DateTime.now(),
    ),
    JobModel(
      id: 'job-003',
      title: 'Desain Konten Sosialisasi Disabilitas',
      description: 'Membuat 3 poster edukasi menggunakan template Canva siap pakai.',
      category: 'Desain Grafis',
      wage: 100000,
      employerName: 'Yayasan Peduli Sesama',
      location: 'Denpasar Timur',
      distanceKm: 3.8,
      requiredSkills: const ['Canva', 'Komunikasi Teks'],
      status: 'Active',
      paymentStatus: 'Locked',
      createdAt: DateTime.now(),
    ),
    JobModel(
      id: 'job-004',
      title: 'Pemeriksaan Ejaan & Koreksi Naskah Buku',
      description: 'Proofreading bab pengantar buku cerita anak berbahasa Indonesia.',
      category: 'Pemeriksaan Teks',
      wage: 60000,
      employerName: 'Penerbit Mandiri',
      location: 'Denpasar Utara',
      distanceKm: 4.1,
      requiredSkills: const ['Bahasa Indonesia', 'Koreksi Teks'],
      status: 'Active',
      paymentStatus: 'Locked',
      createdAt: DateTime.now(),
    ),
  ];

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
      itemCount: dummyJobs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildJobCard(context, dummyJobs[index]),
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
      itemCount: dummyJobs.length,
      itemBuilder: (context, index) => _buildJobCard(context, dummyJobs[index]),
    );
  }

  Widget _buildJobCard(BuildContext context, JobModel job) {
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
                    '⭐ ${job.requiredSkills.length}/${job.requiredSkills.length} Kemampuan Cocok',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '📍 ${job.distanceKm} km',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              job.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              job.employerName,
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
                      job.formattedWage,
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
                        builder: (_) => JobDetailScreen(job: job),
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
