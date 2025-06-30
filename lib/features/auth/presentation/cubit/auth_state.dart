

import 'package:mukhlissmagasin/features/auth/domain/entities/user.dart';



sealed class  AuthState {
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  AuthAuthenticated({required this.user});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
 AuthError({required this.message});
}