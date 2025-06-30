// features/auth/domain/repositories/auth_repository.dart
import 'package:mukhlissmagasin/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<AppUser?> login(String email, String password);
  Future<AppUser?> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? siret,
  });
  Future<void> logout();
  AppUser? getCurrentUser();
}