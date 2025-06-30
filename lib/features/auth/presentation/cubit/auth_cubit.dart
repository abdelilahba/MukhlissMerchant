import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/auth/domain/usecases/login_usecase.dart';
import 'package:mukhlissmagasin/features/auth/domain/usecases/signup_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignUpUseCase signUpUseCase;
  final LoginUseCase loginUseCase;
  final AuthRepository repository; // Ajoutez cette ligne

  AuthCubit({
    required this.signUpUseCase,
    required this.loginUseCase,
    required this.repository, // Ajoutez ce paramètre
  }) : super(AuthInitial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final currentUser = await repository.getCurrentUser(); // Implémentez cette méthode dans votre repository
      if (currentUser != null) {
        emit(AuthAuthenticated(user: currentUser));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated()); // En cas d'erreur, considérez comme non connecté
    }
  }



  Future<void> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? siret,
  }) async {
    emit(AuthLoading());
    try {
      final user = await signUpUseCase.execute(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        address: address,
        siret: siret,
      );
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthError(message: 'Sign up failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase.call(email, password);
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthError(message: 'Login failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> logout() async {
    await repository.logout();
    emit(AuthUnauthenticated());
  }
}