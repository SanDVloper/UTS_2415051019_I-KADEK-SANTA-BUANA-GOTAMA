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
  String? _activeJobId = 'job-api-1';

  // Getters
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  Set<String> get bookmarkedJobIds => _bookmarkedJobIds;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<JobModel> get allJobs => _jobs;

  // Filtered Jobs Getter (Sesuai search query & kategori)
  List<JobModel> get filteredJobs {
    return _jobs.where((job) {
      final matchesQuery = job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.requiredSkills.any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          job.employerName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'Semua' || job.category == _selectedCategory;

      return matchesQuery && matchesCategory;
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

  // Fetch Jobs dari REST API via JobRepository
  Future<void> fetchJobs() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      final fetchedJobs = await _repository.fetchJobs();
      _jobs.clear();
      _jobs.addAll(fetchedJobs);

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

  // Set Filter Pencarian
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
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
      notifyListeners();
    }
  }

  // Konfirmasi Penyelesaian dari Employer (Update State ke Completed & Upah Processing)
  void confirmJobCompletion(String jobId) {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      _jobs[index] = _jobs[index].copyWith(
        status: 'Completed',
        paymentStatus: 'Processing',
      );
      notifyListeners();
    }
  }

  // Hapus Lowongan (Delete)
  void deleteJob(String jobId) {
    _jobs.removeWhere((j) => j.id == jobId);
    if (_activeJobId == jobId) {
      _activeJobId = null;
    }
    notifyListeners();
  }
}
