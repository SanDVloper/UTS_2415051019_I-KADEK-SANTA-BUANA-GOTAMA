import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../services/api_service.dart';

/// Repository layer that mediates between the API Service and Application Providers
class JobRepository {
  final ApiService _apiService;

  JobRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Curated titles to map JSONPlaceholder posts to realistic inclusive micro-jobs
  static const List<Map<String, dynamic>> _jobTemplates = [
    {
      'title': 'Transkripsi Audio Webinar Bahasa Indonesia',
      'category': 'Transkripsi & Pengetikan',
      'employer': 'PT Inovasi Inklusif',
      'location': 'Denpasar Barat',
      'distance': 1.2,
      'wage': 50000,
      'skills': ['Mengetik Cepat', 'Membaca Teks', 'Komunikasi Teks'],
    },
    {
      'title': 'Input Data Rekam Pasien Klinik Harapan',
      'category': 'Entri Data & Spreadsheet',
      'employer': 'Klinik Harapan Sehat',
      'location': 'Denpasar Selatan',
      'distance': 2.5,
      'wage': 75000,
      'skills': ['Excel', 'Ketelitian', 'Fleksibel'],
    },
    {
      'title': 'Desain Konten Kampanye Aksesibilitas',
      'category': 'Desain Grafis',
      'employer': 'Yayasan Peduli Sesama',
      'location': 'Denpasar Timur',
      'distance': 3.8,
      'wage': 100000,
      'skills': ['Canva', 'Komunikasi Teks'],
    },
    {
      'title': 'Pemeriksaan Ejaan & Koreksi Naskah Cerita',
      'category': 'Pemeriksaan Teks',
      'employer': 'Penerbit Mandiri',
      'location': 'Denpasar Utara',
      'distance': 4.1,
      'wage': 60000,
      'skills': ['Bahasa Indonesia', 'Koreksi Teks'],
    },
    {
      'title': 'Verifikasi Label Produk UMKM Lokal Bali',
      'category': 'Entri Data & Spreadsheet',
      'employer': 'Koperasi Karya Mandiri',
      'location': 'Badung',
      'distance': 5.4,
      'wage': 85000,
      'skills': ['Ketelitian', 'Pemeriksaan Label'],
    },
    {
      'title': 'Pembuatan Subtitle Video Edukasi Bahasa Isyarat',
      'category': 'Transkripsi & Pengetikan',
      'employer': 'Studio Inklusif Bali',
      'location': 'Denpasar Barat',
      'distance': 2.0,
      'wage': 90000,
      'skills': ['Subtitle', 'Mengetik Cepat'],
    },
    {
      'title': 'Audit Aksesibilitas Halaman Web Sederhana',
      'category': 'Pemeriksaan Teks',
      'employer': 'Startup Aksesibilitas ID',
      'location': 'Denpasar Pusat',
      'distance': 3.2,
      'wage': 120000,
      'skills': ['Audit Web', 'Ketelitian'],
    },
    {
      'title': 'Penyusunan Form Survei Kepuasan Pelanggan',
      'category': 'Entri Data & Spreadsheet',
      'employer': 'Dinas Sosial Denpasar',
      'location': 'Renon, Denpasar',
      'distance': 1.8,
      'wage': 65000,
      'skills': ['Google Forms', 'Komunikasi Teks'],
    },
  ];

  /// Fetch jobs from REST API and transform JSON to JobModel objects
  Future<List<JobModel>> fetchJobs() async {
    try {
      final rawList = await _apiService.getJobsRaw();

      final List<JobModel> jobs = [];
      for (var i = 0; i < rawList.length; i++) {
        final item = rawList[i];
        final id = item['id'] ?? (i + 1);
        final template = _jobTemplates[i % _jobTemplates.length];

        jobs.add(
          JobModel(
            id: 'job-api-$id',
            title: template['title'] as String,
            description: item['body'] != null
                ? '${item['body']}\n\nCatatan Tambahan: Tugas ini diakomodasi untuk pekerja disabilitas dengan komunikasi berbasis teks mandiri.'
                : 'Pekerjaan mikro terverifikasi dengan sistem pembayaran aman Escrow.',
            category: template['category'] as String,
            wage: template['wage'] as int,
            employerName: template['employer'] as String,
            location: template['location'] as String,
            distanceKm: (template['distance'] as num).toDouble(),
            requiredSkills: List<String>.from(template['skills'] as List),
            status: i == 0 ? 'Active' : 'Available',
            paymentStatus: 'Locked',
            createdAt: DateTime.now().subtract(Duration(hours: i * 2)),
          ),
        );
      }

      return jobs;
    } on ApiException catch (e) {
      debugPrint('JobRepository: ApiException caught (${e.message}). Falling back to cached data.');
      return _getFallbackJobs();
    } catch (e) {
      debugPrint('JobRepository: Unexpected error ($e). Falling back to cached data.');
      return _getFallbackJobs();
    }
  }

  /// Fallback curated list of jobs in case network is disconnected
  List<JobModel> _getFallbackJobs() {
    return _jobTemplates.asMap().entries.map((entry) {
      final i = entry.key;
      final t = entry.value;
      return JobModel(
        id: 'job-offline-${i + 1}',
        title: t['title'] as String,
        description: 'Pekerjaan mikro terverifikasi dengan instruksi teks mandiri dan upah aman terproteksi Escrow.',
        category: t['category'] as String,
        wage: t['wage'] as int,
        employerName: t['employer'] as String,
        location: t['location'] as String,
        distanceKm: (t['distance'] as num).toDouble(),
        requiredSkills: List<String>.from(t['skills'] as List),
        status: i == 0 ? 'Active' : 'Available',
        paymentStatus: 'Locked',
        createdAt: DateTime.now().subtract(Duration(hours: i + 1)),
      );
    }).toList();
  }
}
