/// Helper pour la gestion audio dans l'application.
///
/// Centralise la lecture des sons (succès, erreur, notification)
/// avec gestion des erreurs et logging.
library;

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:mukhlissmagasin/core/services/app_logger.dart';

/// Helper pour jouer des sons dans l'application.
///
/// Utilise AudioPlayer avec configuration optimisée pour
/// une latence faible et une fiabilité maximale.
///
/// ### Exemple d'utilisation:
/// ```dart
/// final audioHelper = AudioPlayerHelper();
/// await audioHelper.playSuccess();
///
/// // Ne pas oublier de dispose
/// audioHelper.dispose();
/// ```
class AudioPlayerHelper {
  /// Player audio interne
  late final AudioPlayer _audioPlayer;

  /// Indique si le player est initialisé
  bool _isInitialized = false;

  /// Tag pour le logging
  static const String _tag = 'AudioPlayerHelper';

  /// Crée une nouvelle instance de [AudioPlayerHelper].
  AudioPlayerHelper() {
    _audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _initialize();
  }

  /// Initialise le player audio.
  Future<void> _initialize() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      _isInitialized = true;
      AppLogger.debug('Audio player initialisé', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erreur initialisation audio player',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }

  /// Joue le son de succès.
  ///
  /// Utilisé après une transaction réussie ou action positive.
  Future<void> playSuccess() async {
    await _playSound('audio/success.mp3');
  }

  /// Joue le son d'erreur.
  ///
  /// Utilisé pour signaler une erreur à l'utilisateur.
  Future<void> playError() async {
    await _playSound('audio/error.mp3');
  }

  /// Joue le son de notification.
  ///
  /// Utilisé pour les alertes et notifications.
  Future<void> playNotification() async {
    await _playSound('audio/notification.mp3');
  }

  /// Joue le son de scan.
  ///
  /// Utilisé lors du scan d'un QR code.
  Future<void> playScan() async {
    await _playSound('audio/scan.mp3');
  }

  /// Joue un son spécifique.
  ///
  /// [assetPath] - Chemin du fichier audio dans les assets
  Future<void> _playSound(String assetPath) async {
    if (!_isInitialized) {
      AppLogger.warning('Audio player non initialisé', tag: _tag);
      await _initialize();
    }

    try {
      AppLogger.debug('Lecture: $assetPath', tag: _tag);

      // Jouer directement sans stop/seek pour éviter les problèmes
      unawaited(_audioPlayer.play(
        AssetSource(assetPath),
        volume: 1.0,
        mode: PlayerMode.lowLatency,
      ));

      AppLogger.debug('Son lancé en arrière-plan', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erreur lecture audio: $assetPath',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }

  /// Libère les ressources du player.
  ///
  /// Doit être appelé dans le dispose() du widget.
  void dispose() {
    try {
      _audioPlayer.dispose();
      AppLogger.debug('Audio player disposed', tag: _tag);
    } catch (e) {
      AppLogger.warning('Erreur dispose audio: $e', tag: _tag);
    }
  }
}
