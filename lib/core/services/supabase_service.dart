import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized configuration and constants for the Supabase backend.
class SupabaseConstants {
  SupabaseConstants._();

  static const String url = 'https://jwotitqnioaibeapqjgi.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp3b3RpdHFuaW9haWJlYXBxamdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI1MDY1NDksImV4cCI6MjEwODA4MjU0OX0.zMAT0XSMoEl1i0ynLcsJF43rzy0ziiEdZ4F_1pl8ehs';

  static const String storageBucket = 'Photos';
  static const String tableInventoryLogs = 'food_inventory_logs';
  static const String viewCurrentInventory = 'current_fridge_inventory';

  /// Generates the public CDN URL for an image stored in the Photos bucket.
  static String getPublicPhotoUrl(String filename) {
    if (filename.isEmpty) return '';
    if (filename.startsWith('http://') || filename.startsWith('https://')) {
      return filename;
    }
    return '$url/storage/v1/object/public/$storageBucket/$filename';
  }
}

/// Helper getter returning the active SupabaseClient.
/// Returns null if Supabase has not been initialized (e.g. in standalone unit test environments).
SupabaseClient? get supabaseClient {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}

