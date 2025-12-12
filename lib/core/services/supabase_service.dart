// core/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mukhlissmagasin/core/services/app_logger.dart';

class SupabaseService {
  static late final SupabaseClient client;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      AppLogger.info('Supabase already initialized', tag: 'Supabase');
      return;
    }

    try {
      AppLogger.info('🔄 Initializing Supabase connection...', tag: 'Supabase');
      
      await Supabase.initialize(
        url: 'https://cowhadlafnxrrwnfuwdi.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvd2hhZGxhZm54cnJ3bmZ1d2RpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2NTQ1NjcsImV4cCI6MjA2MzIzMDU2N30.oqmSTplkiqY1Shi48l6TOEC5pM1jHv6JZuIZQE3SyIs',
      );
      
      client = Supabase.instance.client;
      _initialized = true;
      
      AppLogger.lifecycle('✅ Supabase initialized successfully');
      
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ Failed to initialize Supabase',
        error: e,
        stackTrace: stackTrace,
        tag: 'Supabase',
      );
      
      // Messages d'erreur clairs selon le type d'erreur
      final errorMessage = e.toString().toLowerCase();
      
      if (errorMessage.contains('failed host lookup') || 
          errorMessage.contains('no address associated')) {
        throw Exception(
          '🌐 Impossible de se connecter à Supabase.\n\n'
          'Vérifiez que vous êtes connecté à Internet et réessayez.\n\n'
          'Si le problème persiste, contactez le support.'
        );
      } else if (errorMessage.contains('socketexception') || 
                 errorMessage.contains('network')) {
        throw Exception(
          '📡 Erreur réseau détectée.\n\n'
          'Assurez-vous d\'être connecté à Internet (WiFi ou données mobiles).\n\n'
          'Essayez de :\n'
          '• Vérifier votre connexion Internet\n'
          '• Désactiver le VPN si actif\n'
          '• Redémarrer l\'application'
        );
      } else if (errorMessage.contains('timeout')) {
        throw Exception(
          '⏱️ La connexion a pris trop de temps.\n\n'
          'Votre connexion Internet semble lente.\n'
          'Réessayez avec une meilleure connexion.'
        );
      }
      
      // Erreur générique si type inconnu
      throw Exception(
        '⚠️ Erreur d\'initialisation:\n\n$e\n\n'
        'Contactez le support technique.'
      );
    }
  }
  
  /// Teste la connexion Supabase en effectuant une requête simple
  /// 
  /// Returns true si la connexion fonctionne, false sinon
  static Future<bool> testConnection() async {
    try {
      AppLogger.info('🧪 Testing Supabase connection...', tag: 'Supabase');
      
      // Requête minimale pour tester la connexion
      // Utilise une limite de 0 pour ne récupérer aucune donnée
      await client
          .from('magasins')
          .select('id')
          .limit(1)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              AppLogger.warning('⏱️ Connection test timed out', tag: 'Supabase');
              throw Exception('Connection timeout');
            },
          );
      
      AppLogger.info('✅ Connection test successful', tag: 'Supabase');
      return true;
      
    } catch (e) {
      AppLogger.error('❌ Connection test failed', error: e, tag: 'Supabase');
      return false;
    }
  }
  
  /// Vérifie si Supabase est initialisé et la connexion fonctionne
  /// 
  /// Returns true si tout est OK, false sinon
  static Future<bool> isHealthy() async {
    if (!_initialized) {
      AppLogger.warning('⚠️ Supabase not initialized', tag: 'Supabase');
      return false;
    }
    
    return await testConnection();
  }
}