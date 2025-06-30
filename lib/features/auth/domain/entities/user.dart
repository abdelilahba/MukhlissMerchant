// features/auth/domain/entities/user.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AppUser {  // Renommez pour éviter le conflit
  final String id;
  final String? email;
  final String? name;

  AppUser({required this.id, this.email, this.name});

  factory AppUser.fromSupabaseUser(User supabaseUser) {
    return AppUser(
      id: supabaseUser.id,
      email: supabaseUser.email,
      name: supabaseUser.userMetadata?['name'] as String?,
    );
  }
}