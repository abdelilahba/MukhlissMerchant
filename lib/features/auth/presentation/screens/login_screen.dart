import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mukhlissmagasin/features/auth/presentation/cubit/auth_state.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
   
    final L10n=AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:  [
                    Colors.blue.shade50,
                    Colors.white,
                    Colors.indigo.shade50,
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animé avec effet de profondeur
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade600,
                          Colors.indigo.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200.withOpacity(0.5),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.store_mall_directory_rounded,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Titres avec animation subtile
                  Column(
                    children: [
                   AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                   style: TextStyle(
                   color: Colors.grey.shade800,
                     fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                       ),
                     child: Text(L10n.welcome),
                     ),
                      const SizedBox(height: 8),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          color:  Colors.grey.shade600,
                        ),
                        child:  Text(L10n.connecterpourcontinuer),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  
                  // Carte du formulaire avec effet de verre
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color:  Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Champ Email amélioré
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  color:  Colors.black ,
                                ),
                                decoration: InputDecoration(
                                  labelText:L10n.email,
                                  labelStyle: TextStyle(
                                    color:  Colors.grey.shade400 ,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Colors.blue.shade600,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: 
                                           Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.blue.shade600, 
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor:   Colors.grey.shade50,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, 
                                    horizontal: 20,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return  L10n.veuillezsaisiremail;
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return L10n.formatinvalid;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              
                              // Champ Mot de passe amélioré
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                style: TextStyle(
                                  color:  Colors.black ,
                                ),
                                decoration: InputDecoration(
                                  labelText: L10n.motpasse,
                                  labelStyle: TextStyle(
                                    color:  Colors.grey.shade400 
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: Colors.blue.shade600,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.visibility_outlined,
                                      color: Colors.grey.shade500,
                                    ),
                                    onPressed: () {
                                      // Ajouter la logique pour afficher/masquer le mot de passe
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color:  Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.blue.shade600, 
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor:  Colors.grey.shade50,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, 
                                    horizontal: 20,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return L10n.veuillezsaisirpassword;
                                  }
                                  if (value.length < 6) {
                                    return L10n.motpassecotenir ;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              
                              
                              
                              // Bouton de connexion amélioré
                              BlocConsumer<AuthCubit, AuthState>(
                                listener: (context, state) {
                                  if (state is AuthAuthenticated) {
                                    Navigator.pushReplacementNamed(context, '/caissiers');
                                  }
                                  if (state is AuthError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(state.message),
                                        backgroundColor: Colors.red.shade600,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        margin: const EdgeInsets.all(16),
                                      ),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: state is AuthLoading
                                          ? null
                                          : LinearGradient(
                                              colors: [
                                                Colors.blue.shade600,
                                                Colors.indigo.shade400,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                      boxShadow: state is AuthLoading
                                          ? null
                                          : [
                                              BoxShadow(
                                                color: Colors.blue.shade300.withOpacity(0.5),
                                                blurRadius: 10,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                    ),
                                    child: Material(
                                      color: state is AuthLoading
                                          ? Colors.grey.shade400
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: state is AuthLoading
                                            ? null
                                            : () {
                                                if (_formKey.currentState!.validate()) {
                                                  context.read<AuthCubit>().login(
                                                    _emailController.text.trim(),
                                                    _passwordController.text.trim(),
                                                  );
                                                }
                                              },
                                        child: Center(
                                          child: state is AuthLoading
                                              ? Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation<Color>(
                                                          Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                     Text(
                                                     L10n.connexion ,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Text(
                                                L10n.seconnecter ,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black.withOpacity(0.1),
                                                        blurRadius: 2,
                                                        offset: const Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ), 
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}