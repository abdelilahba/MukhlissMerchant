import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/core/services/supabase_service.dart';
import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/auth/domain/usecases/login_usecase.dart';
import 'package:mukhlissmagasin/features/auth/domain/usecases/signup_usecase.dart';
import 'package:mukhlissmagasin/core/services/subscription_service.dart';
import 'package:mukhlissmagasin/core/services/magasin_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignUpUseCase signUpUseCase;
  final LoginUseCase loginUseCase;
  final AuthRepository repository;
  StreamSubscription<supa.AuthState>? _authSubscription;

  AuthCubit({
    required this.signUpUseCase,
    required this.loginUseCase,
    required this.repository,
  }) : super(AuthInitial()) {
    _initAuthListener();
    checkAuthStatus();
  }

  void _initAuthListener() {
    try {
      _authSubscription =
          SupabaseService.client.auth.onAuthStateChange.listen((data) {
        if (data.event == supa.AuthChangeEvent.signedOut) {
          if (!isClosed) emit(AuthUnauthenticated());
        } else if (data.event == supa.AuthChangeEvent.tokenRefreshed) {
          final user = repository.getCurrentUser();
          if (user != null && state is! AuthAuthenticated) {
            if (!isClosed) emit(AuthAuthenticated(user: user));
          }
        }
      });
    } catch (_) {}
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      // 1. S'assurer que le token JWT est valide ou renouvelé
      final hasValidSession = await SupabaseService.ensureValidSession();
      if (!hasValidSession) {
        emit(AuthUnauthenticated());
        return;
      }

      final currentUser = repository.getCurrentUser();
      if (currentUser != null) {
        emit(AuthAuthenticated(user: currentUser));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
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
        // ✅ Vérifier l'abonnement AVANT d'autoriser l'accès
        final magasinId = await MagasinService.getCurrentMagasinId();

        if (magasinId != null) {
          final subscriptionService = SubscriptionService();
          final accessResult = await subscriptionService.checkAccess(magasinId);

          // ❌ Si le compte est expiré, suspendu ou inactif → bloquer
          if (!accessResult.canAccess) {
            // Déconnecter l'utilisateur
            await repository.logout();

            // Émettre l'erreur avec le message approprié
            String errorMessage;
            switch (accessResult.status) {
              case 'expired':
                errorMessage =
                    'Votre abonnement a expiré. Veuillez contacter le support pour renouveler.';
                break;
              case 'suspended':
                errorMessage =
                    'Votre compte est suspendu. ${accessResult.message}';
                break;
              case 'inactive':
                errorMessage =
                    'Votre compte est désactivé. Contactez le support.';
                break;
              case 'no_subscription':
                errorMessage =
                    'Aucun abonnement trouvé. Contactez votre fournisseur.';
                break;
              default:
                errorMessage = accessResult.message;
            }

            emit(AuthError(message: errorMessage));
            return;
          }
        }

        // ✅ Abonnement valide → autoriser l'accès
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

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
