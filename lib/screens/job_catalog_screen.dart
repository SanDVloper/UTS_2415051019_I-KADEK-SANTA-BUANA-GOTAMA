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

  Future<bool> _showDeleteConfirmation(BuildContext context, JobModel item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 44),
        title: const Text('Konfirmasi Hapus Data', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus data lowongan ini dari Database Supabase?',
              style: const TextStyle(fontSize: 13, color: AppColors.textMain),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Text(
                '• Judul: ${item.title}\n• Sumber: ${item.dataSourceLabel}\n• ID: ${item.id}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Ya, Hapus Data'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

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
                            'Terintegrasi Supabase PostgreSQL Cloud & REST API Server',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        // Tombol menu simulasi & opsi Read Database
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.tune, color: AppColors.primary),
                          tooltip: 'Opsi Sumber Data & Simulasi (UTS)',
                          onSelected: (value) {
                            switch (value) {
                              case 'refresh':
                                jobProvider.fetchJobs();
                                break;
                              case 'database_read':
                                jobProvider.fetchDatabaseOnly();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Menampilkan data hasil READ dari Database Supabase!'),
                                    backgroundColor: Color(0xFF0284C7),
                                  ),
                                );
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
                                  Icon(Icons.sync, size: 18, color: AppColors.secondary),
                                  SizedBox(width: 8),
                                  Text('1. Sinkronisasi Penuh (DB + API)'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'database_read',
                              child: Row(
                                children: [
                                  Icon(Icons.cloud_download_outlined, size: 18, color: Color(0xFF0284C7)),
                                  SizedBox(width: 8),
                                  Text('2. Baca Supabase DB Saja (READ)'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'error',
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, size: 18, color: AppColors.danger),
                                  SizedBox(width: 8),
                                  Text('3. Simulasi Error State'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'empty',
                              child: Row(
                                children: [
                                  Icon(Icons.inbox_outlined, size: 18, color: AppColors.textMuted),
                                  SizedBox(width: 8),
                                  Text('4. Simulasi Empty State'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: AppColors.primary),
                          tooltip: 'Muat Ulang Data',
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
                const SizedBox(height: 12),

                // Search Bar
                TextField(
                  onChanged: (val) => jobProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Cari lowongan, keahlian, atau instansi...',
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
                const SizedBox(height: 10),

                // Source Filter Chips: Semua | Supabase DB | REST API
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        selected: jobProvider.selectedSourceFilter == 'Semua',
                        label: Text('Semua Lowongan (${jobProvider.allJobs.length})'),
                        onSelected: (_) => jobProvider.setSourceFilter('Semua'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        selected: jobProvider.selectedSourceFilter == 'Supabase Cloud',
                        avatar: const Icon(Icons.cloud_done, size: 14, color: Color(0xFF0284C7)),
                        label: Text('Supabase DB (${jobProvider.databaseJobCount})'),
                        onSelected: (_) => jobProvider.setSourceFilter('Supabase Cloud'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        selected: jobProvider.selectedSourceFilter == 'REST API',
                        avatar: const Icon(Icons.api, size: 14, color: AppColors.primary),
                        label: Text('REST API (${jobProvider.apiJobCount})'),
                        onSelected: (_) => jobProvider.setSourceFilter('REST API'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

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
        message: 'Membaca records dari Database Supabase & REST API server...',
      );
    }

    if (provider.state == ViewState.error) {
      return ErrorStateWidget(
        errorMessage: provider.errorMessage ?? 'Gagal membaca data dari server.',
        onRetry: () => provider.fetchJobs(),
      );
    }

    if (jobs.isEmpty) {
      return EmptyStateWidget(
        title: 'Tidak Ada Lowongan Ditemukan',
        description: provider.searchQuery.isNotEmpty
            ? 'Tidak ada lowongan yang cocok dengan kata kunci "${provider.searchQuery}".'
            : provider.selectedSourceFilter == 'Supabase Cloud'
                ? 'Belum ada data lowongan di Supabase Database. Anda dapat membuat lowongan baru melalui tab "Buat Job".'
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
        return Dismissible(
          key: Key('job-${item.id}-$index'),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await _showDeleteConfirmation(context, item);
          },
          onDismissed: (_) async {
            await provider.deleteJob(item.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lowongan "${item.title}" berhasil dihapus dari Database.'),
                  backgroundColor: AppColors.danger,
                ),
              );
            }
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete_forever, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Text('HAPUS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          child: JobCard(
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
          ),
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
