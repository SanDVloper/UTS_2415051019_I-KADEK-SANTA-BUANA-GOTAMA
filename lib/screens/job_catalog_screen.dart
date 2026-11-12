import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';
import 'job_detail_screen.dart';

class JobCatalogScreen extends StatelessWidget {
  const JobCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final jobs = jobProvider.filteredJobs;

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
                    Expanded(
                      child: Column(
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
                  onChanged: (val) => jobProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Cari judul lowongan, skill, atau instansi...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: jobProvider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => jobProvider.setSearchQuery(''),
                          )
                        : null,
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

                // State Handling: Loading, Error, Empty, Loaded
                Expanded(
                  child: _buildStateContent(context, jobProvider, jobs, isCompact),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStateContent(BuildContext context, JobProvider provider, List<JobModel> jobs, bool isCompact) {
    if (provider.state == ViewState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.state == ViewState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text('Terjadi kesalahan: ${provider.errorMessage ?? "Gagal memuat data"}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => provider.fetchJobs(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            const Text('Tidak ada lowongan yang sesuai kriteria pencarian.', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => provider.setSearchQuery(''),
              child: const Text('Reset Pencarian'),
            ),
          ],
        ),
      );
    }

    return isCompact ? _buildListView(context, provider, jobs) : _buildGridView(context, provider, jobs);
  }

  Widget _buildListView(BuildContext context, JobProvider provider, List<JobModel> jobs) {
    return ListView.separated(
      itemCount: jobs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildJobCard(context, provider, jobs[index]),
    );
  }

  Widget _buildGridView(BuildContext context, JobProvider provider, List<JobModel> jobs) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.45,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: jobs.length,
      itemBuilder: (context, index) => _buildJobCard(context, provider, jobs[index]),
    );
  }

  Widget _buildJobCard(BuildContext context, JobProvider provider, JobModel job) {
    final isSaved = provider.isBookmarked(job.id);

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
                Row(
                  children: [
                    Text(
                      '📍 ${job.distanceKm} km',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? AppColors.primary : AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => provider.toggleBookmark(job.id),
                    ),
                  ],
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
