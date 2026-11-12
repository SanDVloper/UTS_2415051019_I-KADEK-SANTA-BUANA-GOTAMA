import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/user_provider.dart';
import '../screens/dashboard_screen.dart';
import '../screens/job_catalog_screen.dart';
import '../screens/create_job_screen.dart';
import '../screens/active_job_screen.dart';
import '../screens/profile_screen.dart';

class ResponsiveScaffold extends StatefulWidget {
  const ResponsiveScaffold({super.key});

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showEscrowInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield, color: AppColors.secondary, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Protokol Escrow Guard KaryaSetara', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Keamanan Upah Terjamin 100% untuk Pekerja', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              '1. Deposit Terkunci: Pemberi kerja wajib mendepositkan upah penuh sebelum tugas dapat diambil.\n'
              '2. Pengerjaan Aman: Dana tidak dapat ditarik sepihak selama proses pengerjaan berjalan.\n'
              '3. Verifikasi Hasil: Employer meninjau hasil tugas sesuai kriteria kesepakatan.\n'
              '4. Pencairan Otomatis: Upah diteruskan ke saldo pekerja tanpa potongan liar.',
              style: TextStyle(fontSize: 13, height: 1.6, color: AppColors.textMain),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Saya Mengerti'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isWorker = userProvider.worker.role == 'Worker';

    final tabTitles = isWorker
        ? [
            'Beranda Pekerja (Worker)',
            'Katalog Lowongan Pekerjaan',
            'Posting Lowongan (Mode Employer)',
            'Lembar Kerja & Alur Upah Escrow',
            'Profil Pekerja & Aksesibilitas',
          ]
        : [
            'Dashboard Pemberi Kerja',
            'Manajemen Lowongan Supabase',
            'Posting Lowongan Baru (CRUD)',
            'Panel Verifikasi Tugas & Escrow',
            'Profil Lembaga & Pengaturan',
          ];

    final screens = [
      DashboardScreen(onNavigateToTab: _onDestinationSelected),
      const JobCatalogScreen(),
      const CreateJobScreen(),
      ActiveJobScreen(onNavigateToTab: _onDestinationSelected),
      const ProfileScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppConstants.compactBreakpoint;

        if (isCompact) {
          // ================= MOBILE LAYOUT (< 600dp) =================
          return Scaffold(
            appBar: AppBar(
              title: Text(tabTitles[_selectedIndex]),
              actions: [
                IconButton(
                  tooltip: 'Status Escrow Aman',
                  icon: const Icon(Icons.shield_outlined, color: AppColors.secondary),
                  onPressed: () => _showEscrowInfoBottomSheet(context),
                ),
              ],
            ),
            body: IndexedStack(
              index: _selectedIndex,
              children: screens,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: isWorker
                  ? const [
                      NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: 'Beranda',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.search_outlined),
                        selectedIcon: Icon(Icons.search),
                        label: 'Cari Job',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.add_circle_outline),
                        selectedIcon: Icon(Icons.add_circle),
                        label: 'Posting',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.assignment_outlined),
                        selectedIcon: Icon(Icons.assignment),
                        label: 'Tugas',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: 'Profil',
                      ),
                    ]
                  : const [
                      NavigationDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard),
                        label: 'Beranda',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.list_alt_outlined),
                        selectedIcon: Icon(Icons.list_alt),
                        label: 'Lowongan',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.add_circle_outline),
                        selectedIcon: Icon(Icons.add_circle),
                        label: 'Posting',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.fact_check_outlined),
                        selectedIcon: Icon(Icons.fact_check),
                        label: 'Verifikasi',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.business_outlined),
                        selectedIcon: Icon(Icons.business),
                        label: 'Profil Usaha',
                      ),
                    ],
            ),
          );
        } else {
          // ================= DESKTOP / EXPANDED LAYOUT (>= 600dp) =================
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'KS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'KaryaSetara',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: isWorker ? AppColors.primaryLight : AppColors.secondaryLight,
                              child: Text(
                                isWorker ? 'MS' : 'EM',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isWorker ? AppColors.primary : AppColors.secondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isWorker ? 'Pekerja' : 'Employer',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isWorker ? AppColors.primary : AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  destinations: isWorker
                      ? const [
                          NavigationRailDestination(
                            icon: Icon(Icons.home_outlined),
                            selectedIcon: Icon(Icons.home),
                            label: Text('Beranda'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.search_outlined),
                            selectedIcon: Icon(Icons.search),
                            label: Text('Cari Job'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.add_circle_outline),
                            selectedIcon: Icon(Icons.add_circle),
                            label: Text('Posting'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.assignment_outlined),
                            selectedIcon: Icon(Icons.assignment),
                            label: Text('Tugas'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.person_outline),
                            selectedIcon: Icon(Icons.person),
                            label: Text('Profil'),
                          ),
                        ]
                      : const [
                          NavigationRailDestination(
                            icon: Icon(Icons.dashboard_outlined),
                            selectedIcon: Icon(Icons.dashboard),
                            label: Text('Beranda'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.list_alt_outlined),
                            selectedIcon: Icon(Icons.list_alt),
                            label: Text('Lowongan'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.add_circle_outline),
                            selectedIcon: Icon(Icons.add_circle),
                            label: Text('Posting'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.fact_check_outlined),
                            selectedIcon: Icon(Icons.fact_check),
                            label: Text('Verifikasi'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.business_outlined),
                            selectedIcon: Icon(Icons.business),
                            label: Text('Profil'),
                          ),
                        ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: AppColors.border),
                Expanded(
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(tabTitles[_selectedIndex]),
                      elevation: 0,
                      actions: [
                        InkWell(
                          onTap: () => _showEscrowInfoBottomSheet(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.shield, color: AppColors.secondary, size: 16),
                                SizedBox(width: 6),
                                Text('Escrow Guard Active', style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Notifikasi',
                          icon: const Icon(Icons.notifications_none),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    body: IndexedStack(
                      index: _selectedIndex,
                      children: screens,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
