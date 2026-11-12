import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_state_widget.dart';
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
                // Header & Action Row
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
                        // Tombol simulasi state untuk dokumentasi & penilaian UTS
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.tune, color: AppColors.primary),
                          tooltip: 'Uji Simulasi State UI (UTS)',
                          onSelected: (value) {
                            switch (value) {
                              case 'refresh':
                                jobProvider.fetchJobs();
                                break;
                              case 'error':
                                jobProvider.simulateError();
                                break;
                              case 'empty':
                                jobProvider.simulateEmpty();
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'refresh',
                              child: Row(
                                children: [
                                  Icon(Icons.refresh, size: 18, color: AppColors.secondary),
                                  SizedBox(width: 8),
                                  Text('1. Normal Fetch (Loading -> Loaded)'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'error',
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, size: 18, color: AppColors.danger),
                                  SizedBox(width: 8),
                                  Text('2. Simulasi Error State'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'empty',
                              child: Row(
                                children: [
                                  Icon(Icons.inbox_outlined, size: 18, color: AppColors.textMuted),
                                  SizedBox(width: 8),
                                  Text('3. Simulasi Empty State'),
                                ],
                              ),
                            ),
                          ],
                        ),
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

                // State Handling: LoadingStateWidget, ErrorStateWidget, EmptyStateWidget, Loaded
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
      return const LoadingStateWidget(
        message: 'Mengambil lowongan pekerjaan dari REST API server...',
      );
    }

    if (provider.state == ViewState.error) {
      return ErrorStateWidget(
        errorMessage: provider.errorMessage ?? 'Gagal terhubung ke REST API server.',
        onRetry: () => provider.fetchJobs(),
      );
    }

    if (jobs.isEmpty) {
      return EmptyStateWidget(
        title: 'Tidak Ada Lowongan Ditemukan',
        description: provider.searchQuery.isNotEmpty
            ? 'Tidak ada lowongan yang cocok dengan kata kunci "${provider.searchQuery}". Silakan periksa kembali ejaan pencarian Anda.'
            : 'Belum ada lowongan pekerjaan yang tersedia saat ini.',
        actionLabel: provider.searchQuery.isNotEmpty ? 'Reset Pencarian' : 'Muat Ulang Data',
        onAction: () {
          if (provider.searchQuery.isNotEmpty) {
            provider.setSearchQuery('');
          } else {
            provider.fetchJobs();
          }
        },
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
