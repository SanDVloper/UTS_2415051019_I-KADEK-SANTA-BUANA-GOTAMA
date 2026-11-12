import 'package:flutter/material.dart';
import '../models/job_model.dart';

enum ViewState { initial, loading, loaded, error, empty }

class JobProvider extends ChangeNotifier {
  ViewState _state = ViewState.initial;
  String? _errorMessage;

  final List<JobModel> _jobs = [
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
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
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
      status: 'Available',
      paymentStatus: 'Locked',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
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
      status: 'Available',
      paymentStatus: 'Locked',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
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
      status: 'Available',
      paymentStatus: 'Locked',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // Shared State: Favorit / Bookmark
  final Set<String> _bookmarkedJobIds = {'job-001'};

  // Search & Filter State
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String? _activeJobId = 'job-001';

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

  // Fetch Jobs dengan penanganan loading state, empty state, dan error state
  Future<void> fetchJobs() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Simulasi network delay
      if (_jobs.isEmpty) {
        _state = ViewState.empty;
      } else {
        _state = ViewState.loaded;
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

  // Tambah Lowongan (Create)
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
