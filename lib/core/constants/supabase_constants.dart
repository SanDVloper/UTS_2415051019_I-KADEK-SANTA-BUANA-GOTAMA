/// Supabase Configuration & Table Constants for KaryaSetara
class SupabaseConstants {
  SupabaseConstants._();

  /// Project Supabase URL endpoint
  static const String supabaseUrl = 'https://kpedhmtfxytzuoadrulm.supabase.co';

  /// Supabase Anonymous Public API Key
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtwZWRobXRmeHl0enVvYWRydWxtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ0NzI1NTYsImV4cCI6MjExMDA0ODU1Nn0.ntaQ-dPeE_WV4copIBtyFrpBQ4Ffw84mF6NGzWsbi8Y';

  /// Database Table Names
  static const String jobsTable = 'jobs';
  static const String workersTable = 'workers';
  static const String transactionsTable = 'transactions';
}
