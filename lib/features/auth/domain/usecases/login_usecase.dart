import 'package:mukhlissmagasin/features/auth/domain/entities/user.dart';
import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AppUser?> call(String email, String password) async {
    return await repository.login(email, password);
  }
}