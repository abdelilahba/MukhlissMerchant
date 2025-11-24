

import 'dart:io';

import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';
import 'package:mukhlissmagasin/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileManager {
  final ProfileCubit profilecubit;
  final SupabaseClient supabase;
  ProfileManager (this.profilecubit,{required this.supabase});


  Future<void> profileloading() async {
     await profilecubit.LoasdProfile();
  }
   Future<void> profileUpdate(MagasinModel magasin)async {
    await profilecubit.updateUser(magasin);
   }

Future<String> uploadImage(File imageFile) async {
    try {
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fileBytes = await imageFile.readAsBytes();

      // Upload du fichier - utilisez fileBytes directement sans cast
      await supabase.storage
          .from('store-logo')
          .uploadBinary(fileName,  fileBytes);

      // Récupération de l'URL publique
      final imageUrl = supabase.storage
          .from('store-logo')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      print('Erreur lors de l\'upload: $e');
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

Future<void> changePassword(String newPassword) async {
  try {
    // Validation basique du mot de passe
    if (newPassword.length < 6) {
      throw Exception('Le mot de passe doit contenir au moins 6 caractères');
    }

    // Utiliser l'API Supabase Auth pour mettre à jour le mot de passe
    final response = await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    if (response.user == null) {
      throw Exception('Erreur lors de la mise à jour du mot de passe');
    }

    print('Mot de passe mis à jour avec succès');
  } catch (e) {
    print('Erreur lors du changement de mot de passe: $e');
    throw Exception('Erreur lors du changement de mot de passe: $e');
  }
}

  // Méthode optionnelle pour vérifier l'ancien mot de passe avant de le changer
  Future<bool> verifyCurrentPassword(String currentPassword) async {
    try {
      // Note: Cette méthode nécessiterait l'email de l'utilisateur
      final user = supabase.auth.currentUser;
      if (user?.email == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Tentative de connexion avec l'ancien mot de passe pour vérification
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: user!.email!,
        password: currentPassword,
      );

      return response.user != null;
    } catch (e) {
      print('Erreur lors de la vérification du mot de passe: $e');
      return false;
    }
  }
   
}