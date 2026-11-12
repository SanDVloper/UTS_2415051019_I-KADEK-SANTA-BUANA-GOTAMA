import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';
import '../providers/user_provider.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: 'Transkripsi Audio Webinar');
  final _descController = TextEditingController(text: 'Mengetik naskah rekaman webinar 45 menit ke dalam Google Docs.');
  final _wageController = TextEditingController(text: '50000');
  String _selectedCategory = 'Transkripsi & Pengetikan';

  final List<String> _categories = [
    'Transkripsi & Pengetikan',
    'Entri Data & Spreadsheet',
    'Desain Grafis Sederhana',
    'Pemeriksaan Teks & Ejaan',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _wageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final wage = int.tryParse(_wageController.text.trim()) ?? 50000;
    final newJob = JobModel(
      id: 'job-sp-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      wage: wage,
      employerName: 'PT Inovasi Inklusif',
      location: 'Denpasar Barat',
      distanceKm: 1.5,
      requiredSkills: [_selectedCategory.split(' ').first, 'Komunikasi Teks'],
      status: 'Available',
      paymentStatus: 'Locked',
      createdAt: DateTime.now(),
    );

    final success = await context.read<JobProvider>().createJob(newJob);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.cloud_done, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Lowongan "${newJob.title}" berhasil di-insert ke Database Supabase!',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.secondary,
          duration: const Duration(seconds: 3),
        ),
      );

      _titleController.clear();
      _descController.clear();
      _wageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan data ke database. Silakan coba lagi.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppConstants.compactBreakpoint;

        return Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
            child: isCompact ? _buildFormContent(context) : _buildExpandedSplit(context),
          ),
        );
      },
    );
  }

  Widget _buildExpandedSplit(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (60%): Form
        Expanded(
          flex: 6,
          child: _buildFormContent(context),
        ),
        const SizedBox(width: 24),
        // Right Column (40%): Live Candidate Match Preview
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt, color: AppColors.primary, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'Estimasi Matching Real-Time',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Berdasarkan keahlian & upah yang Anda tentukan, sistem menemukan kandidat potensial:',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('4 Kandidat Tersedia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Match > 85%', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '• Made Suardana — 92% Cocok (1.2 km)\n• Ni Putu Ayu — 86% Cocok (2.8 km)',
                  style: TextStyle(fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cloud_sync, color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Database Engine: Supabase PostgreSQL Realtime CRUD',
                          style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent(BuildContext context) {
    final isCreating = context.watch<JobProvider>().isCreatingJob;
    final userRole = context.watch<UserProvider>().worker.role;
    final isWorker = userRole == 'Worker';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Role Contextual
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: isWorker ? AppColors.warningLight : AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isWorker
                    ? AppColors.warning.withValues(alpha: 0.3)
                    : AppColors.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isWorker ? Icons.info_outline : Icons.business_center_outlined,
                  color: isWorker ? AppColors.warning : AppColors.secondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isWorker
                        ? 'Mode Worker aktif. Untuk memposting pekerjaan, Anda dapat beralih ke peran Employer.'
                        : 'Mode Employer aktif. Lowongan akan langsung diposting ke Cloud Database Supabase.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isWorker ? AppColors.warning : AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isWorker)
                  TextButton(
                    onPressed: () => context.read<UserProvider>().switchRole('Employer'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(60, 30)),
                    child: const Text('Beralih', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Posting Lowongan Baru',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Database Create (POST)',
                  style: TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Tentukan kriteria tugas, kebutuhan skill, dan nominal upah terjamin', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 16),

          // Judul
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Judul Pekerjaan *',
              hintText: 'Contoh: Transkripsi Audio Webinar',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Judul pekerjaan wajib diisi' : null,
          ),
          const SizedBox(height: 14),

          // Kategori
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Kategori Pekerjaan *',
              border: OutlineInputBorder(),
            ),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCategory = val);
            },
          ),
          const SizedBox(height: 14),

          // Nominal Upah
          TextFormField(
            controller: _wageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Nominal Upah (Rp) *',
              prefixText: 'Rp ',
              helperText: '🔒 Upah akan dikunci di Escrow saat pekerja menerima tugas',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Nominal upah wajib diisi';
              final val = int.tryParse(v);
              if (val == null || val < 10000) return 'Minimal upah adalah Rp 10.000';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Deskripsi
          TextFormField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Deskripsi & Instruksi Pengerjaan *',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Deskripsi pekerjaan wajib diisi' : null,
          ),
          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isCreating ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: isCreating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Publikasikan Lowongan ke Database Supabase'),
            ),
          ),
        ],
      ),
    );
  }
}
