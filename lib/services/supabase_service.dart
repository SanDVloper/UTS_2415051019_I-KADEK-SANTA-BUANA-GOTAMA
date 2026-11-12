import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_constants.dart';
import '../models/job_model.dart';

/// Database Service Layer wrapping Supabase client operations with resilient offline caching
class SupabaseService {
  static SupabaseClient? _client;
  static bool _isInitialized = false;

  // Local fallback storage for offline reliability and demo resilience
  final List<JobModel> _localJobs = [];

  static bool get isInitialized => _isInitialized;

  /// Safe initialization of Supabase client with graceful error handling
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: SupabaseConstants.supabaseUrl,
        anonKey: SupabaseConstants.supabaseAnonKey, // ignore: deprecated_member_use
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('SupabaseService: Client initialized successfully.');
    } catch (e) {
      debugPrint('SupabaseService: Offline/Mock mode activated. (Details: $e)');
      _isInitialized = false;
    }
  }

  SupabaseClient? get client => _client;

  /// CREATE: Menambahkan lowongan pekerjaan baru ke database Supabase
  Future<JobModel> insertJob(JobModel job) async {
    try {
      if (_isInitialized && _client != null) {
        final response = await _client!
            .from(SupabaseConstants.jobsTable)
            .insert(job.toJson())
            .select()
            .single();

        return JobModel.fromJson(response);
      }
    } catch (e) {
      debugPrint('SupabaseService.insertJob error ($e). Saving to local in-memory store.');
    }

    // Fallback in-memory
    _localJobs.insert(0, job);
    return job;
  }

  /// READ: Mengambil seluruh daftar lowongan pekerjaan dari Supabase
  Future<List<JobModel>> fetchJobs() async {
    try {
      if (_isInitialized && _client != null) {
        final List<dynamic> response = await _client!
            .from(SupabaseConstants.jobsTable)
            .select()
            .order('created_at', ascending: false);

        return response.map((json) => JobModel.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('SupabaseService.fetchJobs error ($e). Returning local store.');
    }

    return List.unmodifiable(_localJobs);
  }

  /// UPDATE: Memperbarui status, link pengerjaan, atau detail lowongan
  Future<JobModel?> updateJob(String id, Map<String, dynamic> updates) async {
    try {
      if (_isInitialized && _client != null) {
        final response = await _client!
            .from(SupabaseConstants.jobsTable)
            .update(updates)
            .eq('id', id)
            .select()
            .single();

        return JobModel.fromJson(response);
      }
    } catch (e) {
      debugPrint('SupabaseService.updateJob error ($e). Updating local store.');
    }

    final index = _localJobs.indexWhere((j) => j.id == id);
    if (index != -1) {
      final current = _localJobs[index];
      final updated = current.copyWith(
        status: updates['status'] as String? ?? current.status,
        paymentStatus: updates['payment_status'] as String? ?? current.paymentStatus,
        submissionUrl: updates['submission_url'] as String? ?? current.submissionUrl,
      );
      _localJobs[index] = updated;
      return updated;
    }
    return null;
  }

  /// DELETE: Menghapus record pekerjaan dari Supabase
  Future<bool> deleteJob(String id) async {
    try {
      if (_isInitialized && _client != null) {
        await _client!.from(SupabaseConstants.jobsTable).delete().eq('id', id);
        return true;
      }
    } catch (e) {
      debugPrint('SupabaseService.deleteJob error ($e). Removing from local store.');
    }

    _localJobs.removeWhere((j) => j.id == id);
    return true;
  }
}
