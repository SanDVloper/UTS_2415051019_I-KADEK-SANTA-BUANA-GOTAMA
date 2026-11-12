import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../repositories/job_repository.dart';

enum ViewState { initial, loading, loaded, error, empty }

class JobProvider extends ChangeNotifier {
  final JobRepository _repository;

  JobProvider({JobRepository? repository}) : _repository = repository ?? JobRepository();

  ViewState _state = ViewState.initial;
  String? _errorMessage;

  final List<JobModel> _jobs = [];

  // Shared State: Favorit / Bookmark
  final Set<String> _bookmarkedJobIds = {'job-api-1'};

  bool _isCreatingJob = false;
  bool get isCreatingJob => _isCreatingJob;

  // Search & Filter State
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _selectedSourceFilter = 'Semua';
  String? _activeJobId = 'job-api-1';

  // Getters
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  Set<String> get bookmarkedJobIds => _bookmarkedJobIds;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedSourceFilter => _selectedSourceFilter;

  List<JobModel> get allJobs => _jobs;

  int get databaseJobCount => _jobs.where((j) => j.isFromDatabase).length;
  int get apiJobCount => _jobs.where((j) => !j.isFromDatabase).length;

  // Filtered Jobs Getter (Sesuai search query, kategori, dan sumber data)
  List<JobModel> get filteredJobs {
    return _jobs.where((job) {
      final matchesQuery = job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.requiredSkills.any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          job.employerName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'Semua' || job.category == _selectedCategory;

      final matchesSource = _selectedSourceFilter == 'Semua' ||
          (_selectedSourceFilter == 'Supabase Cloud' && job.isFromDatabase) ||
          (_selectedSourceFilter == 'REST API' && !job.isFromDatabase);

      return matchesQuery && matchesCategory && matchesSource;
    }).toList();
  }

  // Active Job Getter (Pekerjaan aktif yang sedang dikerjakan)
  JobModel? get activeJob {
    try {
      return _jobs.firstWhere((j) => j.id == _activeJobId);
    } catch (_) {
      return _jobs.isNotEmpty ? _jobs.first : null;
    }
  }

  // READ: Sinkronisasi data dari Database Supabase dan REST API
  Future<void> fetchJobs() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      // 1. Read data dari Database Supabase
      final dbJobs = await _repository.fetchJobsFromDatabase();

      // 2. Read data dari REST API Server
      final apiJobs = await _repository.fetchJobs();

      // Gabungkan hasil read (Data Supabase diprioritaskan di atas)
      final existingIds = <String>{};
      final combined = <JobModel>[];

      for (final j in dbJobs) {
        if (existingIds.add(j.id)) combined.add(j);
      }
      for (final j in apiJobs) {
        if (existingIds.add(j.id)) combined.add(j);
      }

      _jobs.clear();
      _jobs.addAll(combined);

      if (_jobs.isEmpty) {
        _state = ViewState.empty;
      } else {
        _state = ViewState.loaded;
        if (_activeJobId == null || !_jobs.any((j) => j.id == _activeJobId)) {
          _activeJobId = _jobs.first.id;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  // READ Khusus: Membaca murni dari Database Supabase
  Future<void> fetchDatabaseOnly() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      final dbJobs = await _repository.fetchJobsFromDatabase();
      if (dbJobs.isEmpty) {
        _state = ViewState.empty;
      } else {
        _jobs.clear();
        _jobs.addAll(dbJobs);
        _selectedSourceFilter = 'Supabase Cloud';
        _state = ViewState.loaded;
      }
    } catch (e) {
      _errorMessage = 'Gagal membaca records dari Supabase: $e';
      _state = ViewState.error;
    }
    notifyListeners();
  }

  // Shared State: Toggle Bookmark / Favorit
  void toggleBookmark(String jobId) {
    if (_bookmarkedJobIds.contains(jobId)) {
      _bookmarkedJobIds.remove(jobId);
    } else {
      _bookmarkedJobIds.add(jobId);
    }
    notifyListeners();
  }

  bool isBookmarked(String jobId) => _bookmarkedJobIds.contains(jobId);

  // Set Filter Pencarian & Sumber Data
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSourceFilter(String source) {
    _selectedSourceFilter = source;
    notifyListeners();
  }

  // Helper untuk demonstrasi/evaluasi UTS: Simulasi Error State
  void simulateError([String? message]) {
    _errorMessage = message ?? 'Koneksi ke endpoint REST API terputus (SocketException: Connection refused).';
    _state = ViewState.error;
    notifyListeners();
  }

  // Helper untuk demonstrasi/evaluasi UTS: Simulasi Empty State
  void simulateEmpty() {
    _jobs.clear();
    _state = ViewState.empty;
    notifyListeners();
  }

  // Tambah Lowongan (Create) langsung ke Database Supabase & State Lokal
  Future<bool> createJob(JobModel newJob) async {
    _isCreatingJob = true;
    notifyListeners();

    try {
      final savedJob = await _repository.createJob(newJob);
      _jobs.insert(0, savedJob);
      _isCreatingJob = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyimpan ke database: $e';
      _isCreatingJob = false;
      notifyListeners();
      return false;
    }
  }

  void addJob(JobModel newJob) {
    _jobs.insert(0, newJob);
    notifyListeners();
  }

  // UPDATE: Memperbarui lowongan di Database Supabase & state lokal
  Future<bool> updateJob(String id, Map<String, dynamic> updates) async {
    try {
      final updated = await _repository.updateJobInDatabase(id, updates);
      final index = _jobs.indexWhere((j) => j.id == id);
      if (index != -1) {
        if (updated != null) {
          _jobs[index] = updated;
        } else {
          final current = _jobs[index];
          _jobs[index] = current.copyWith(
            title: updates['title'] as String? ?? current.title,
            description: updates['description'] as String? ?? current.description,
            category: updates['category'] as String? ?? current.category,
            wage: updates['wage'] as int? ?? current.wage,
            status: updates['status'] as String? ?? current.status,
            paymentStatus: updates['payment_status'] as String? ?? current.paymentStatus,
            submissionUrl: updates['submission_url'] as String? ?? current.submissionUrl,
          );
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui lowongan: $e';
      notifyListeners();
      return false;
    }
  }

  // Terima Pekerjaan (Update State ke Active & Upah Locked)
  void acceptJob(String jobId) {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      _jobs[index] = _jobs[index].copyWith(
        status: 'Active',
        paymentStatus: 'Locked',
      );
      _activeJobId = jobId;
      notifyListeners();
    }
  }

  // Selesaikan Tugas (Update State ke Waiting Confirmation)
  void submitJob(String jobId, String submissionUrl) {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      _jobs[index] = _jobs[index].copyWith(
        status: 'Waiting Confirmation',
        submissionUrl: submissionUrl,
      );
      _repository.updateJobInDatabase(jobId, {
        'status': 'Waiting Confirmation',
        'submission_url': submissionUrl,
      });
      notifyListeners();
    }
  }

  // Konfirmasi Penyelesaian dari Employer (Update State ke Completed & Upah Processing)
  void confirmJobCompletion(String jobId) {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      _jobs[index] = _jobs[index].copyWith(
        status: 'Completed',
        paymentStatus: 'Released',
      );
      _repository.updateJobInDatabase(jobId, {
        'status': 'Completed',
        'payment_status': 'Released',
      });
      notifyListeners();
    }
  }

  // DELETE: Menghapus lowongan dari Database Supabase & state lokal
  Future<bool> deleteJob(String jobId) async {
    try {
      final success = await _repository.deleteJobFromDatabase(jobId);
      _jobs.removeWhere((j) => j.id == jobId);
      _bookmarkedJobIds.remove(jobId);
      if (_activeJobId == jobId) {
        _activeJobId = _jobs.isNotEmpty ? _jobs.first.id : null;
      }
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Gagal menghapus lowongan dari database: $e';
      notifyListeners();
      return false;
    }
  }
}
