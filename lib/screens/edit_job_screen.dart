import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';

/// Screen untuk mengedit data lowongan pekerjaan (Database UPDATE Operation)
class EditJobScreen extends StatefulWidget {
  final JobModel job;

  const EditJobScreen({super.key, required this.job});

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _wageController;
  late String _selectedCategory;
  late String _selectedStatus;
  bool _isSaving = false;

  final List<String> _categories = [
    'Transkripsi & Pengetikan',
    'Entri Data & Spreadsheet',
    'Desain Grafis',
    'Desain Grafis Sederhana',
    'Pemeriksaan Teks',
    'Pemeriksaan Teks & Ejaan',
  ];

  final List<String> _statuses = [
    'Available',
    'Active',
    'Waiting Confirmation',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.job.title);
    _descController = TextEditingController(text: widget.job.description);
    _wageController = TextEditingController(text: widget.job.wage.toString());
    _selectedCategory = _categories.contains(widget.job.category)
        ? widget.job.category
        : _categories.first;
    _selectedStatus = _statuses.contains(widget.job.status)
        ? widget.job.status
        : 'Available';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _wageController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final wage = int.tryParse(_wageController.text.trim()) ?? widget.job.wage;
    final updates = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'category': _selectedCategory,
      'wage': wage,
      'status': _selectedStatus,
      'payment_status': _selectedStatus == 'Completed' ? 'Released' : widget.job.paymentStatus,
    };

    final success = await context.read<JobProvider>().updateJob(widget.job.id, updates);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Data lowongan berhasil diperbarui di Database Supabase!'),
              ),
            ],
          ),
          backgroundColor: AppColors.secondary,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui data lowongan ke database.'),
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
          appBar: AppBar(
            title: const Text('Edit Lowongan Pekerjaan'),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    'Database UPDATE',
                    style: TextStyle(color: Color(0xFF0369A1), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.secondary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Mengedit data lowongan ID: ${widget.job.id} (${widget.job.dataSourceLabel})',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMain, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Judul
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Pekerjaan *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Judul pekerjaan tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),

                  // Kategori & Status Row
                  isCompact
                      ? Column(
                          children: [
                            _buildCategoryDropdown(),
                            const SizedBox(height: 16),
                            _buildStatusDropdown(),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: _buildCategoryDropdown()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatusDropdown()),
                          ],
                        ),
                  const SizedBox(height: 16),

                  // Nominal Upah
                  TextFormField(
                    controller: _wageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nominal Upah (Rp) *',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                      helperText: '🔒 Dana otomatis terproteksi pada sistem Escrow',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Nominal upah wajib diisi';
                      final val = int.tryParse(v);
                      if (val == null || val < 10000) return 'Minimal upah adalah Rp 10.000';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Deskripsi
                  TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi & Instruksi Tugas *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Deskripsi pekerjaan wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _submitUpdate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Perubahan ke Database'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Kategori Pekerjaan *',
        border: OutlineInputBorder(),
      ),
      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedCategory = val);
      },
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedStatus,
      decoration: const InputDecoration(
        labelText: 'Status Pengerjaan *',
        border: OutlineInputBorder(),
      ),
      items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedStatus = val);
      },
    );
  }
}
