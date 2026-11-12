import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

/// Custom Exception class for network and API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => statusCode != null ? 'ApiException [$statusCode]: $message' : 'ApiException: $message';
}

/// Service layer responsible for executing raw HTTP network requests
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Execute HTTP GET to retrieve remote posts/jobs
  Future<List<dynamic>> getJobsRaw() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.jobsEndpoint}');

    try {
      final response = await _client.get(
        url,
        headers: ApiConstants.defaultHeaders,
      ).timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        if (decodedData is List) {
          return decodedData;
        } else {
          throw ApiException('Format respons API tidak valid: diharapkan tipe List.');
        }
      } else {
        throw ApiException(
          'Gagal mengambil data dari server (Status: ${response.statusCode})',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on TimeoutException {
      throw ApiException('Waktu permintaan habis (Request Timeout).');
    } on FormatException {
      throw ApiException('Gagal memproses format data respons JSON.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan jaringan yang tidak terduga: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
