// features/auth/data/repositories/auth_repository_impl.dart
import 'package:mukhlissmagasin/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mukhlissmagasin/features/auth/domain/entities/user.dart';
import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AppUser?> login(String email, String password) async {
    final user = await remoteDataSource.loginWithEmail(email, password);
    return user != null ? AppUser.fromSupabaseUser(user) : null;
  }

  @override
  Future<AppUser?> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? siret,
  }) async {
    final user = await remoteDataSource.signUpWithEmail(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      address: address,
      siret: siret,
    );
    return user != null ? AppUser.fromSupabaseUser(user) : null;
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  AppUser? getCurrentUser() {
    final user = remoteDataSource.getCurrentUser();
    return user != null ? AppUser.fromSupabaseUser(user) : null;
  }
}