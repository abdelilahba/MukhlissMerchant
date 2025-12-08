import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:mukhlissmagasin/core/di/injection_container.dart';
import 'package:mukhlissmagasin/core/services/app_logger.dart';
import 'package:mukhlissmagasin/core/widgets/app_drawer.dart';
import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_cubit.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_state.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/screens/recompenses_disponibles_screen.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/screens/scan_client_screen.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/utils/audio_player_helper.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/widgets/widgets.dart';
import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

class CaissierHomeScreen extends StatefulWidget {
  const CaissierHomeScreen({super.key});

  @override
  State<CaissierHomeScreen> createState() => _CaissierHomeScreenState();
}

class _CaissierHomeScreenState extends State<CaissierHomeScreen> {
  // ═══════════════════════════════════════════════════════════════
  // CONTROLLERS
  // ═══════════════════════════════════════════════════════════════
  final _montantController = TextEditingController();
  final _codeController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // ═══════════════════════════════════════════════════════════════
  // AUDIO - Utilise AudioPlayerHelper refactorisé
  // ═══════════════════════════════════════════════════════════════
  late final AudioPlayerHelper _audioHelper;

  // ═══════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════
  bool _isScanning = false;
  bool _showManualInput = false;
  bool _showCodeInputInLeft = false;
  bool _showFelicitationInRight = false;
  bool _showRewardsInRight = false;
  ScanMode _currentScanMode = ScanMode.balance;

  MagasinModel? _currentMagasin;
  String? _selectedClientId;
  String? _selectedMagasinId;
  int _clientPoints = 0;
  dynamic currentUser;

  @override
  void initState() {
    super.initState();
    _audioHelper = AudioPlayerHelper();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  /// Joue le son de succès
  void _playSuccessSound() {
    _audioHelper.playSuccess();
  }

  Future<void> _initializeScreen() async {
    currentUser = getIt<AuthRepository>().getCurrentUser();

    if (currentUser == null) {
      // Handle no user - maybe redirect to login
      if (mounted) {
        _showErrorSnackBar(context, 'Veuillez vous connecter');
        // Optionally navigate to login screen
        // Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }

    // User exists, proceed to load magasin
    if (mounted) {
      context.read<CaissierCubit>().getCurrentMagasin();
    }
  }

  @override
  void dispose() {
    _montantController.dispose();
    _codeController.dispose();
    _audioHelper.dispose();
    super.dispose();
  }

  // caissier_home_screen.dart
  @override
  Widget build(BuildContext context) {
    AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return BlocListener<CaissierCubit, CaissierState>(
      listener: (context, state) {
        // ✅ Écouter l'état d'authentification requise
        if (state is CaissierAuthenticationRequired) {
          // Afficher un message
          _showErrorSnackBar(context, state.message);

          // Rediriger vers la page de connexion après un court délai
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          });
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF5F7FA),
        // appBar: _buildModernAppBar(context, l10n),
        drawer: const AppDrawer(),
        body: isTablet
            ? _buildTabletSplitLayout(context)
            : _buildMobileLayout(context),

        // ✅ Bouton de test Sentry (à supprimer en production)
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Test Sentry
            Sentry.captureMessage('Test Flutter - Monitoring fonctionne! 🎉');
            Sentry.captureException(
              Exception('Test exception Flutter'),
              stackTrace: StackTrace.current,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                          'Erreur de test envoyée à Sentry!\nAllez voir sur sentry.io'),
                    ),
                  ],
                ),
                backgroundColor: Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 5),
              ),
            );
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.bug_report, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildScannerSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header simplifié avec uniquement le bouton retour
          Container(
            height: 60,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: Container(
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                  onPressed: () {
                    // ✅ UTILISER _completeScanReset() au lieu de _stopScanning()
                    _completeScanReset();
                    _montantController.clear();
                  },
                ),
              ],
            ),
          ),

          // Contenu principal
          Expanded(
            child: _showManualInput
                ? _buildAppLogoSection() // Saisie manuelle
                : _buildEmbeddedScanner(), // Scanner intégré
          ),
        ],
      ),
    );
  }

  Widget _buildEmbeddedScanner() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: _currentScanMode == ScanMode.balance
          ? ScanClientScreen.balance(
              double.tryParse(_montantController.text.replaceAll(',', '.')) ??
                  0.0,
              onScanSuccess: (data) async {
                // ✅ Remettre async pour await
                AppLogger.info('🎉 Scan balance réussi: $data', tag: 'Scanner');

                // ✅ JOUER LE SON SANS ATTENDRE
                _playSuccessSound();

                if (mounted) {
                  // ⚡ NOUVEAU : Afficher le bottom sheet de célébration
                  // On doit récupérer le clientId depuis le scan
                  // Pour l'instant, on utilise les données disponibles
                  await _showRewardsCelebration(
                    clientId: data['clientId'] ??
                        '', // Le scan devrait retourner le clientId
                    magasinId: data['magasinId'] ?? '',
                    pointsAdded: data['pointsGagnes'] ?? 0,
                    totalPoints: data['pointsGagnes'] ??
                        0, // Si on a les points totaux, sinon faire une requête
                  );

                  _completeScanReset();
                  _montantController.clear();
                }
              },
            )
          : ScanClientScreen.rewards(
              onScanSuccess: (data) {
                // ✅ SUPPRIMER async
                AppLogger.info('🎉 Scan récompense réussi: $data',
                    tag: 'Scanner');

                // ✅ JOUER LE SON SANS ATTENDRE
                _playSuccessSound(); // SUPPRIMER await

                if (mounted) {
                  _completeScanReset();

                  setState(() {
                    _showRewardsInRight = true;
                    _selectedClientId = data['clientId'];
                    _selectedMagasinId = data['magasinId'];
                    _clientPoints = data['clientPoints'];
                  });
                }
              },
            ),
    );
  }

  void _toggleInputMode() {
    setState(() {
      _showManualInput = !_showManualInput;
      // Optionnel : réinitialiser aussi _showCodeInputInLeft si nécessaire
      if (!_showManualInput) {
        _showCodeInputInLeft = false;
      }
    });
  }

  Future<void> _handleManualCodeSubmit(String code, ScanMode mode) async {
    final l10n = AppLocalizations.of(context);

    if (code.isEmpty) {
      _showErrorSnackBar(context, 'Veuillez saisir un code');
      return;
    }

    final uniqueCode = int.tryParse(code);
    if (uniqueCode == null) {
      _showErrorSnackBar(
        context,
        'Code invalide. Veuillez saisir un code numérique.',
      );
      return;
    }

    final currentUser = getIt<AuthRepository>().getCurrentUser();

    if (mode == ScanMode.balance) {
      final montantTxt = _montantController.text.replaceAll(',', '.');
      final montant = double.tryParse(montantTxt);

      if (montant == null || montant <= 0) {
        _showErrorSnackBar(context, l10n.veuillez);
        return;
      }

      try {
        if (currentUser == null) {
          _showErrorSnackBar(context, 'Aucun magasin connecté');
          return;
        }
        final client = await context
            .read<CaissierCubit>()
            .getClientByUniqueCode(uniqueCode);

        // Récupérer les points AVANT l'ajout
        final pointsAvant = await getIt<CaissierRepository>().getClientPoints(
          clientId: client.id,
          magasinId: currentUser.id,
        );

        // Ajouter le solde via code unique
        await context.read<CaissierCubit>().ajouterSoldeViaCodeUnique(
              uniqueCode: uniqueCode,
              magasinId: currentUser.id,
              montant: montant,
            );

        // Récupérer les points APRÈS l'ajout
        final totalPointsClient =
            await getIt<CaissierRepository>().getClientPoints(
          clientId: client.id,
          magasinId: currentUser.id,
        );

        // Calculer les points ajoutés
        final pointsAjoutes = totalPointsClient - pointsAvant;

        // ✅ JOUER LE SON SANS ATTENDRE
        _playSuccessSound(); // SUPPRIMER await

        // ⚡ NOUVEAU : Afficher le bottom sheet de célébration avec les récompenses
        await _showRewardsCelebration(
          clientId: client.id,
          magasinId: currentUser.id,
          pointsAdded: pointsAjoutes,
          totalPoints: totalPointsClient,
        );

        // ✅ RÉINITIALISATION COMPLÈTE SANS DÉLAI
        if (mounted) {
          setState(() {
            _isScanning = false;
            _showManualInput = false;
            _showCodeInputInLeft = false;
            _codeController.clear();
            _montantController.clear();

            // Ne plus afficher la félicitation dans le panneau de droite
            // car le bottom sheet s'en occupe déjà
            _showFelicitationInRight = false;
          });
        }
      } catch (e) {
        _showErrorSnackBar(context, 'Erreur: $e');
      }
    } else {
      // MODE REWARDS
      AppLogger.debug('=========================appel rewards', tag: 'Rewards');
      try {
        final client = await context
            .read<CaissierCubit>()
            .getClientByUniqueCode(uniqueCode);

        if (!mounted) return;

        // Récupérer les points du client
        final points = await getIt<CaissierRepository>().getClientPoints(
          clientId: client.id,
          magasinId: currentUser!.id,
        );

        // ✅ JOUER LE SON SANS ATTENDRE
        _playSuccessSound(); // SUPPRIMER await

        if (mounted) {
          setState(() {
            _isScanning = false;
            _showManualInput = false;
            _showCodeInputInLeft = false;
            _codeController.clear();

            _showRewardsInRight = true;
            _selectedClientId = client.id;
            _selectedMagasinId = currentUser.id;
            _clientPoints = points;
          });
        }
      } catch (e) {
        if (!mounted) return;
        _showErrorSnackBar(context, 'Erreur: $e');
      }
    }
  }

  /// 🎉 Affiche le bottom sheet de célébration avec les récompenses disponibles
  Future<void> _showRewardsCelebration({
    required String clientId,
    required String magasinId,
    required int pointsAdded,
    required int totalPoints,
  }) async {
    try {
      // Récupérer les récompenses disponibles
      final availableRewards =
          await getIt<CaissierRepository>().getAvailableRewards(
        clientId: clientId,
        magasinId: magasinId,
      );

      if (!mounted) return;

      // AFFICHER LE DIALOGUE CENTRÉ
      await showDialog(
        context: context,
        barrierDismissible: false, // Oblige à cliquer sur un bouton
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 60, // Augmenté de 20 à 60 pour un dialogue plus étroit
            vertical: 24,
          ),
          child: RewardsCelebrationSheet(
            pointsAdded: pointsAdded,
            totalPoints: totalPoints,
            availableRewards: availableRewards,
            onExchangeRewards: () {
              // Fermer d'abord le dialogue
              Navigator.of(context).pop();

              // Afficher les récompenses dans le panneau de droite (comme avant)
              setState(() {
                _showRewardsInRight = true;
                _selectedClientId = clientId;
                _selectedMagasinId = magasinId;
                _clientPoints = totalPoints;
              });
            },
            onSaveLater: () {
              // Juste fermer (déjà géré par le pop du dialog)
            },
          ),
        ),
      );
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération des récompenses: $e',
          tag: 'Rewards', error: e);
      // En cas d'erreur, afficher quand même le bottom sheet sans récompenses
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => RewardsCelebrationSheet(
          pointsAdded: pointsAdded,
          totalPoints: totalPoints,
          availableRewards: [],
        ),
      );
    }
  }

  Widget _buildTabletSplitLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Carte principale (50%)
          Expanded(flex: 50, child: _buildMainCard(context)),
          const SizedBox(width: 24),
          // Section droite - Scanner OU Logo (50%)
          Expanded(flex: 50, child: _buildRightSection()),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Expanded(flex: 70, child: _buildMainCard(context)),
          const SizedBox(height: 20),
          Expanded(
            flex: 30,
            child: _buildRightSection(),
          ), // Utilisez _buildRightSection ici aussi
        ],
      ),
    );
  }

  // ========== CARTE PRINCIPALE UNIQUE ==========
  Widget _buildMainCard(BuildContext context) {
    AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: BlocConsumer<CaissierCubit, CaissierState>(
        // ✅ Utiliser BlocConsumer au lieu de BlocBuilder
        listener: (context, state) {
          // Stocker le magasin quand il est chargé
          if (state is CurrentMagasinLoaded) {
            _currentMagasin = state.magasin;
          }
          // Optionnel: gérer le succès de l'ajout de solde
          if (state is SoldeCodeUniqueAjoute) {
            AppLogger.info('✅ Solde ajouté avec succès via code unique',
                tag: 'Balance');
          }
        },
        // ✅ Ne pas reconstruire si on a déjà le magasin
        buildWhen: (previous, current) {
          // Si on a déjà un magasin stocké, ne pas reconstruire pour
          // les états qui ne concernent pas le magasin
          if (_currentMagasin != null) {
            // Reconstruire seulement pour ces états:
            return current is CurrentMagasinLoaded ||
                current is CaissierError ||
                current is CaissierAuthenticationRequired;
          }
          return true; // Premier chargement: reconstruire normalement
        },
        builder: (context, state) {
          // ✅ Si on a déjà un magasin stocké, l'utiliser
          if (_currentMagasin != null) {
            return _buildMagasinContent(_currentMagasin!);
          }

          // Premier chargement - pas encore de magasin stocké
          if (state is CaissierLoading) {
            return _buildLoadingState();
          } else if (state is CurrentMagasinLoaded) {
            return _buildMagasinContent(state.magasin);
          } else if (state is CaissierError) {
            // Vérifier si c'est une erreur de connexion
            if (state.message.contains('Failed host lookup') ||
                state.message.contains('SocketException') ||
                state.message.contains('No address associated with hostname')) {
              return _buildConnectionErrorState();
            }

            // Check if it's an authentication error
            if (state.message.contains('Aucun utilisateur connecté')) {
              return _buildAuthenticationErrorState();
            }
            return _buildErrorState(state.message);
          } else {
            return _buildLoadingState();
          }
        },
      ),
    );
  }

  /// Construit l'état d'erreur d'authentification.
  ///
  /// Utilise le widget refactorisé [AuthenticationErrorState].
  Widget _buildAuthenticationErrorState() {
    return AuthenticationErrorState(
      onLoginPressed: () {
        Navigator.of(context).pushReplacementNamed('/login');
      },
    );
  }

  Widget _buildMagasinContent(MagasinModel magasin) {
    return Column(
      children: [
        // Logo du magasin - Taille fixe ou flexible mais pas trop grand
        Expanded(flex: 60, child: _buildMagasinLogo(magasin)),

        // ✅ Supprimer Expanded ici et utiliser une taille automatique
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: _showCodeInputInLeft
              ? _buildAppLogoSection()
              : _buildNormalInputSection(
                  context,
                  AppLocalizations.of(context),
                ),
        ),
      ],
    );
  }

  // Ajoutez un état d'erreur
  /// Construit l'état d'erreur générique.
  ///
  /// Utilise le widget refactorisé [GenericErrorState].
  Widget _buildErrorState(String message) {
    return GenericErrorState(
      message: message,
      onRetry: () {
        context.read<CaissierCubit>().getCurrentMagasin();
      },
    );
  }

  Widget _buildRightSection() {
    // ⚠️ Ordre de priorité corrigé :
    // 1. Scanner en cours (priorité maximale quand on clique sur scan)
    // 2. Récompenses (si client sélectionné)
    // 3. Félicitation
    // 4. Logo par défaut

    if (_isScanning) {
      return _buildScannerSection();
    }

    // Afficher rewards si flag activé OU si client sélectionné
    if (_showRewardsInRight ||
        (_selectedClientId != null && _selectedMagasinId != null)) {
      return _buildRewardsContainer();
    }

    if (_showFelicitationInRight) {
      return _buildAppLogoSection();
    }

    return _buildAppLogoSection();
  }

  Widget _buildRewardsContainer() {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header avec bouton retour
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Bouton retour à gauche
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                  onPressed: () {
                    // ✅ APPELER LA MÉTHODE SPÉCIALE POUR LE BACK
                    _handleRewardsBackButton();
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.soldepoints,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                // Espace flexible pour pousser les points vers la droite
                const Spacer(),

                // Container des points à droite
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_clientPoints ${l10n.pts}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // RewardSelectionScreen intégré
          // Dans _buildRewardsContainer(), modifiez l'appel à RewardSelectionScreen :
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: RewardSelectionScreen(
                clientId: _selectedClientId!,
                magasinId: _selectedMagasinId!,
                clientPoints: _clientPoints,
                onRewardsCompleted: _handleRewardsCompleted,
                onRewardClaimed: (pointsRestants) {
                  AppLogger.info(
                      '🎉 Récompense réclamée ! Points restants: $pointsRestants',
                      tag: 'Rewards');

                  // ✅ UTILISER LES POINTS RESTANTS DIRECTEMENT POUR LE TOAST
                  if (mounted) {
                    setState(() {
                      _showRewardsInRight = false;
                      _selectedClientId = null;
                      _selectedMagasinId = null;
                      _clientPoints = 0;
                    });

                    // ✅ AFFICHER LE TOAST AVEC LES POINTS RESTANTS DIRECTEMENT
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        _showRewardsSuccessToast(pointsRestants);
                      }
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRewardsBackButton() {
    // ✅ FERMER LA SECTION DES RÉCOMPENSES SANS AFFICHER LE TOAST
    setState(() {
      _showRewardsInRight = false;
      _selectedClientId = null;
      _selectedMagasinId = null;
      _clientPoints = 0;
    });

    // ✅ NE PAS APPELER _handleRewardsCompleted() QUI AFFICHE LE TOAST
    // Le toast ne s'affichera pas quand l'utilisateur quitte avec le bouton back
  }

  void _handleRewardsCompleted() async {
    final savedClientId = _selectedClientId;
    final savedMagasinId = _selectedMagasinId;

    // ✅ D'ABORD fermer la section des récompenses
    setState(() {
      _showRewardsInRight = false;
      _selectedClientId = null;
      _selectedMagasinId = null;
      _clientPoints = 0;
    });

    AppLogger.debug(
        '=========================fermeture rewards,$savedClientId,$savedMagasinId',
        tag: 'Rewards');

    // ✅ AJOUTER UN DÉLAI POUR LAISSER LE TEMPS AUX DÉDUCTIONS DE POINTS D'ÊTRE TRAITÉES
    // Surtout important quand plusieurs récompenses sont échangées
    await Future.delayed(const Duration(seconds: 2));

    // ✅ RÉCUPÉRER LE TOTAL DES POINTS (avec await car maintenant async)
    if (savedClientId != null && savedMagasinId != null) {
      try {
        final totalPointsClient =
            await getIt<CaissierRepository>().getClientPoints(
          clientId: savedClientId,
          magasinId: savedMagasinId,
        );

        AppLogger.debug(
            '=========================totalPointsClient: $totalPointsClient',
            tag: 'Points');

        // ✅ ENSUITE, après un court délai pour la transition, afficher le toast AVEC LE TOTAL
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _showRewardsSuccessToast(totalPointsClient);
          }
        });
      } catch (e) {
        AppLogger.error(
            '=========================Erreur récupération points: $e',
            tag: 'Points',
            error: e);
        // En cas d'erreur, afficher le toast avec 0 points
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _showRewardsSuccessToast(0);
          }
        });
      }
    } else {
      // Si pas de client/magasin, afficher le toast avec 0 points
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _showRewardsSuccessToast(0);
        }
      });
    }
  }

  void _showRewardsSuccessToast(int nouveauTotalPoints) {
    final l10n = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.felicitation,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.recompenceechange,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    // ✅ Afficher le total des points
                    Text(
                      '${"Total points"}: $nouveauTotalPoints ${l10n.pts}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 4),
        elevation: 12,
      ),
    );
  }

  /// Construit l'état d'erreur de connexion.
  ///
  /// Utilise le widget refactorisé [ConnectionErrorState].
  Widget _buildConnectionErrorState() {
    return ConnectionErrorState(
      onRetry: () {
        context.read<CaissierCubit>().getCurrentMagasin();
      },
    );
  }

  Widget _buildNormalInputSection(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Si mode scan actif
          if (_isScanning)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildManualCodeInputSection(),
              ),
            ),

          // Si mode scan inactif

          if (!_isScanning) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: _buildAddBalanceSection(context, l10n),
            ),

            // const SizedBox(height: 16), // Espacement réduit

            // // ✅ UN SEUL BOUTON DE SCAN AVEC LOGIQUE CONDITIONNELLE
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 24),
            //   child: _buildUniversalScanButton(context, l10n),
            // ),
          ],
        ],
      ),
    );
  }

  void _handleUniversalScan(BuildContext context) {
    final bool isMontantRempli = _montantController.text.trim().isNotEmpty;
    final double? montant =
        double.tryParse(_montantController.text.replaceAll(',', '.'));
    final bool montantValide = montant != null && montant > 0;

    if (isMontantRempli && !montantValide) {
      // Montant invalide
      _showErrorSnackBar(context, 'Veuillez saisir un montant valide');
      return;
    }

    // ✅ Réinitialisation COMPLÈTE avant de lancer le scan
    if (mounted) {
      setState(() {
        _isScanning = false;
        _showManualInput = false;
        _showCodeInputInLeft = false;
        _showFelicitationInRight = false;
        _showRewardsInRight = false;
      });
    }

    // ✅ Délai pour laisser Flutter tout réinitialiser
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isScanning = true;
          // ✅ CHOIX DU MODE DE SCAN SELON LE MONTANT
          _currentScanMode = (isMontantRempli && montantValide)
              ? ScanMode.balance // Mode ajout de points
              : ScanMode.rewards; // Mode récompenses
          _showCodeInputInLeft = false;
        });
      }
    });
  }

  /// Construit la section de saisie manuelle du code.
  ///
  /// Utilise le widget refactorisé [ManualCodeInputSection].
  Widget _buildManualCodeInputSection() {
    return ManualCodeInputSection(
      showInput: _showManualInput,
      scanMode: _currentScanMode,
      onToggle: _toggleInputMode,
      onSubmit: _handleManualCodeSubmit,
      onBack: () {
        setState(() {
          _showManualInput = false;
          _codeController.clear();
        });
      },
    );
  }

  /// Construit le logo du magasin.
  ///
  /// Utilise le widget refactorisé [MagasinLogoWidget].
  Widget _buildMagasinLogo(MagasinModel magasin) {
    return MagasinLogoWidget(
      magasin: magasin,
      size: MagasinLogoSize.medium,
    );
  }

  /// Construit la section d'ajout de solde.
  ///
  /// Utilise le widget refactorisé [AddBalanceSection].
  Widget _buildAddBalanceSection(BuildContext context, AppLocalizations l10n) {
    return AddBalanceSection(
      controller: _montantController,
      onScanPressed: () => _handleUniversalScan(context),
      onSubmit: (value) {
        if (value.isNotEmpty) {
          _handleAddBalance(context);
        }
      },
    );
  }

  Widget _buildAppLogoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/aps (8).png',
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFF9FAFB),
              child: const Center(
                child: Icon(
                  Icons.image_not_supported_rounded,
                  size: 64,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Construit l'état de chargement.
  ///
  /// Utilise le widget refactorisé [CaissierLoadingState].
  Widget _buildLoadingState() {
    return const CaissierLoadingState(
      message: 'Chargement...',
      size: 40,
    );
  }

  // ========== GESTION DES ACTIONS ==========
  Future<void> _handleAddBalance(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final montantTxt = _montantController.text.replaceAll(',', '.');
    final montant = double.tryParse(montantTxt);

    if (montant == null || montant <= 0) {
      _showErrorSnackBar(context, l10n.veuillez);
      return;
    }

    // ✅ Réinitialisation COMPLÈTE incluant la félicitation
    if (mounted) {
      setState(() {
        _isScanning = false;
        _showManualInput = false;
        _showCodeInputInLeft = false;
        _showFelicitationInRight = false; // ⚠️ Réinitialiser la félicitation
        _showRewardsInRight = false;
      });
    }

    // ✅ Délai pour laisser Flutter tout réinitialiser
    await Future.delayed(const Duration(milliseconds: 200));

    // ✅ Lancer le nouveau scan
    if (mounted) {
      setState(() {
        _isScanning = true;
        _currentScanMode = ScanMode.balance;
        _showCodeInputInLeft = false;
      });
    }
  }

// ✅ NOUVELLE MÉTHODE pour réinitialiser complètement l'état de scan
  void _completeScanReset() {
    if (mounted) {
      setState(() {
        _isScanning = false;
        _showManualInput = false;
        _showCodeInputInLeft = false;
        _showFelicitationInRight = false;
        _showRewardsInRight = false;
        _codeController.clear();
      });
    }
  }

  // ========== SNACKBARS ==========
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Color(0xFFEF4444), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF991B1B),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFEE2E2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
