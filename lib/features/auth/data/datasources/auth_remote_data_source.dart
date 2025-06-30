// features/auth/data/datasources/auth_remote_data_source.dart

import 'package:mukhlissmagasin/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? siret,
  });
  
  Future<User?> loginWithEmail(String email, String password);
  Future<void> logout();
  User? getCurrentUser();
}
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<User?> loginWithEmail(String email, String password) async {
    final response = await SupabaseService.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }

  @override
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? siret,
  }) async {
    // 1. Création du compte utilisateur
    final authResponse = await SupabaseService.client.auth.signUp(
      email: email,
      password: password,
    );

    // 2. Si l'inscription réussit et qu'on a un utilisateur
    if (authResponse.user != null) {
      final userId = authResponse.user!.id;
      
      // 3. Création du profil magasin associé
      await _createMagasinProfile(
        userId: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        address: address,
        siret: siret,
      );
    }

    return authResponse.user;
  }



  Future<void> _createMagasinProfile({
    required String userId,
    required String email,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? siret,
  }) async {
    await SupabaseService.client.from('magasins').insert({
      'id': userId,
      'email': email,
      'nom_enseigne': lastName,
      'telephone': phone,
      'adresse': address,
      'created_at': DateTime.now().toIso8601String(),
      'siret': siret,
    });
    print('Client profile created for user $userId');
  }

  @override
  Future<void> logout() async {
    await SupabaseService.client.auth.signOut();
  }

  @override
  User? getCurrentUser() {
    return SupabaseService.client.auth.currentUser;
  }
}