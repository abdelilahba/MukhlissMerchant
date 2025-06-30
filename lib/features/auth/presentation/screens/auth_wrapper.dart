import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mukhlissmagasin/features/auth/presentation/cubit/auth_state.dart';
import 'package:mukhlissmagasin/features/auth/presentation/screens/login_screen.dart';




  class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if(state is AuthInitial){

          print('AuthCubit is in initial state');
        }
        print('Current Auth State: $state'); 
        // Vérification immédiate de l'état d'authentification
        if (state is AuthAuthenticated) {
          // Utilisez Future.delayed pour éviter les problèmes de contexte
          Future.delayed(Duration.zero, () {
            Navigator.pushNamedAndRemoveUntil(
              // ignore: use_build_context_synchronously
              context,
              '/offers',
              (route) => false,
            );
          });
          return const Scaffold( // Écran de chargement temporaire
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Si non authentifié, affichez LoginScreen
        return  LoginScreen();
      },
    );
  }
}