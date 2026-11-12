import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
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
                            'Data real-time disinkronkan dari REST API server',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh, color: AppColors.primary),
                          tooltip: 'Muat Ulang dari REST API',
                          onPressed: () => jobProvider.fetchJobs(),
                        ),
                        Chip(
                          backgroundColor: AppColors.primaryLight,
                          label: Text(
                            isCompact ? 'List (1 Col)' : 'Grid (2 Col)',
                            style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
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
                  child: RefreshIndicator(
                    onRefresh: () => jobProvider.fetchJobs(),
                    child: _buildStateContent(context, jobProvider, jobs, isCompact),
                  ),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text(
              'Menghubungkan ke REST API Endpoint...',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (provider.state == ViewState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data dari server:\n${provider.errorMessage ?? "Koneksi terputus"}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.danger, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.fetchJobs(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Coba Lagi'),
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
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: jobs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = jobs[index];
        return JobCard(
          job: item,
          isBookmarked: provider.isBookmarked(item.id),
          onBookmarkToggle: () => provider.toggleBookmark(item.id),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => JobDetailScreen(job: item),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context, JobProvider provider, List<JobModel> jobs) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final item = jobs[index];
        return JobCard(
          job: item,
          isBookmarked: provider.isBookmarked(item.id),
          onBookmarkToggle: () => provider.toggleBookmark(item.id),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => JobDetailScreen(job: item),
              ),
            );
          },
        );
      },
    );
  }
}
