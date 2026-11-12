/// API Configuration Constants for KaryaSetara
class ApiConstants {
  ApiConstants._();

  /// Public REST API Base URL (JSONPlaceholder Mock REST Server)
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  /// Endpoint to fetch micro-job post listings
  static const String jobsEndpoint = '/posts?_limit=8';

  /// Network request timeout duration
  static const Duration connectTimeout = Duration(seconds: 10);

  /// Custom User-Agent header
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };
}
