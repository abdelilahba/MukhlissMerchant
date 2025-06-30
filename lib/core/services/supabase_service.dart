// core/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static late final SupabaseClient client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://cowhadlafnxrrwnfuwdi.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvd2hhZGxhZm54cnJ3bmZ1d2RpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2NTQ1NjcsImV4cCI6MjA2MzIzMDU2N30.oqmSTplkiqY1Shi48l6TOEC5pM1jHv6JZuIZQE3SyIs',
    );
    client = Supabase.instance.client;
  }

  
}