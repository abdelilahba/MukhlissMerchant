import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/core/di/injection_container.dart';
import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_cubit.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_state.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/screens/success_screen.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

enum ScanMode { balance, rewards }

/// Screen for scanning client QR codes to add balance or view offers
class ScanClientScreen extends StatefulWidget {
  final double? montant; // Nullable for offers mode
  final ScanMode mode;

  const ScanClientScreen.balance(this.montant) : mode = ScanMode.balance;

  const ScanClientScreen.rewards() : mode = ScanMode.rewards, montant = null;

  @override
  State<ScanClientScreen> createState() => _ScanClientScreenState();
}

class _ScanClientScreenState extends State<ScanClientScreen> {
  // Constants
  static const _qrDebugLabel = 'QR';
  static const _cutOutSize = 250.0;
  static const _borderWidth = 10.0;
  static const _borderLength = 30.0;
  static const _borderRadius = 10.0;

  // Controllers and state
  final GlobalKey _qrKey = GlobalKey(debugLabel: _qrDebugLabel);
  QRViewController? _controller;
  final CaissierCubit _cubit = getIt<CaissierCubit>();
  bool _isProcessing = false;

  // Store client data for navigation
  String? _lastClientId;
  String? _lastMagasinId;

  // Check if we're in balance mode (montant is provided) or offers mode
  bool get _isBalanceMode => widget.montant != null;
  final AudioPlayer _audioPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  Future<void> _playSuccessSound() async {
    try {
      await _audioPlayer.stop(); // au cas où un son joue déjà
      await _audioPlayer.play(AssetSource('audio/success.mp3'));
    } catch (_) {
      // en production vous pourriez logger l’erreur
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<CaissierCubit, CaissierState>(
        listener: _handleStateChanges,
        child: BlocBuilder<CaissierCubit, CaissierState>(
          builder: (context, state) => _buildScaffold(state),
        ),
      ),
    );
  }

  /// Builds the main scaffold with QR scanner
  Widget _buildScaffold(CaissierState state) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildMainContent(),
          if (_shouldShowLoading(state)) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  /// Builds the app bar with camera switch button
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _isBalanceMode
            ? 'Scanner Client - Ajouter Solde'
            : 'Scanner Client - Voir Offres',
      ),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.flip_camera_ios),
          onPressed: _flipCamera,
          tooltip: 'Changer de caméra',
        ),
      ],
    );
  }

  /// Builds the main content with QR scanner and info
  Widget _buildMainContent() {
    return Column(children: [_buildQRScanner(), _buildInfoSection()]);
  }

  /// Builds the QR scanner section
  Widget _buildQRScanner() {
    return Expanded(
      flex: 5,
      child: QRView(
        key: _qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: _buildScannerOverlay(),
        cameraFacing: CameraFacing.front,
        formatsAllowed: const [BarcodeFormat.qrcode],
      ),
    );
  }

  /// Builds the scanner overlay
  QrScannerOverlayShape _buildScannerOverlay() {
    return QrScannerOverlayShape(
      borderColor: Theme.of(context).primaryColor,
      borderRadius: _borderRadius,
      borderLength: _borderLength,
      borderWidth: _borderWidth,
      cutOutSize: _cutOutSize,
    );
  }

  /// Builds the information section below the scanner
  Widget _buildInfoSection() {
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isBalanceMode ? Icons.add_circle : Icons.local_offer,
              size: 32,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              _isBalanceMode
                  ? 'Scannez le QR code du client pour ajouter du solde'
                  : 'Scannez le QR code du client pour voir les offres',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (_isBalanceMode) _buildAmountDisplay(),
            if (_isBalanceMode) ...[
              const SizedBox(height: 12),
              Text(
                'Après ajout du solde, vous serez redirigé vers les offres disponibles',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the amount display (only shown in balance mode)
  Widget _buildAmountDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Montant: ${widget.montant!.toStringAsFixed(2)} DH',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  /// Builds the loading overlay
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              _isBalanceMode
                  ? 'Ajout du solde en cours...'
                  : 'Traitement en cours...',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (_isBalanceMode) ...[
              const SizedBox(height: 8),
              const Text(
                'Redirection vers les offres après ajout...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Handles cubit state changes
  void _handleStateChanges(BuildContext context, CaissierState state) {
    switch (state) {
      case SoldeAjoute():
        final pointsGagnes =
            state.clientMagasin.cumulePoint; // Adjust property name as needed
        final soldeRestant =
            state.clientMagasin.solde; // Adjust property name as needed
        _handleBalanceAdded(pointsGagnes, soldeRestant);
        break;
      case CaissierError():
        _handleError(state.message);
        break;
      default:
        break;
    }
  }

  /// Handles successful balance addition - automatically redirects to offers
  /// Handles successful balance addition - automatically redirects to offers and rewards
  Future<void> _handleBalanceAdded(
    double pointsGagnes,
    double soldeRestant,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => FelicitationScreen(
              pointsGagnes: pointsGagnes,
              soldeRestant: soldeRestant,
            ),
      ),
    );
    if (mounted) Navigator.pop(context, true); // retour à la Home
  }

  /// Handles errors
  void _handleError(String message) {
    _setProcessing(false);
    _showSnackBar(message: 'Erreur: $message', backgroundColor: Colors.red);
    _resumeCamera();
  }

  /// Shows a snack bar with the given message
  void _showSnackBar({
    required String message,
    required Color backgroundColor,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Called when QR view is created
  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen(_handleQRScan);
  }

  /// Flips between front and back camera
  Future<void> _flipCamera() async {
    await _controller?.flipCamera();
  }

  /// Handles QR code scanning
  Future<void> _handleQRScan(Barcode scanData) async {
    if (!_canProcessScan(scanData)) return;

    _setProcessing(true);
    await _pauseCamera();

    try {
      await _processQRCode(scanData.code!);
    } on FormatException catch (e) {
      _handleScanError('QR code invalide: Format incorrect', e);
    } catch (e) {
      _handleScanError('Erreur lors du traitement: ${e.toString()}', e);
    }
  }

  /// Checks if scan can be processed
  bool _canProcessScan(Barcode scanData) {
    return scanData.code != null && mounted && !_isProcessing;
  }

  /// Processes the QR code data
  Future<void> _processQRCode(String qrCode) async {
    final clientData = _parseQRCode(qrCode);
    final currentUser = _getCurrentUser();
    _validateData(clientData, currentUser);

    // mémos
    _lastClientId = clientData['user_id'].toString();
    _lastMagasinId = currentUser.id;

    //--------------------------------------------------------
    // 1️⃣  MODE « BALANCE » : on crédite et on laisse
    //     _handleStateChanges gérer la suite
    //--------------------------------------------------------
    if (widget.mode == ScanMode.balance) {
      await _cubit.ajouterSoldeClient(
        clientId: _lastClientId!,
        magasinId: _lastMagasinId!,
        montant: widget.montant!,
      );
      return; // on s’arrête là
    }

    //--------------------------------------------------------
    // 2️⃣  MODE « REWARDS » : on renvoie les infos vers la Home
    //--------------------------------------------------------
    final points = await getIt<CaissierRepository>().getClientPoints(
      clientId: _lastClientId!,
      magasinId: _lastMagasinId!,
    );

    await _playSuccessSound();
    _showSnackBar(message: 'QR reconnu ✔️', backgroundColor: Colors.green);

    // petite pause esthétique
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      Navigator.pop(context, {
        'clientId': _lastClientId!,
        'magasinId': _lastMagasinId!,
        'clientPoints': points.toString(),
      });
    }
  }

  /// Parses QR code JSON data
  Map<String, dynamic> _parseQRCode(String qrCode) {
    debugPrint('QR Data: $qrCode');
    return jsonDecode(qrCode) as Map<String, dynamic>;
  }

  /// Gets current authenticated user
  dynamic _getCurrentUser() {
    final currentUser = getIt<AuthRepository>().getCurrentUser();
    debugPrint('Current User: ${currentUser?.id}');
    return currentUser;
  }

  /// Validates QR data and user
  void _validateData(Map<String, dynamic> clientData, dynamic currentUser) {
    if (currentUser == null) {
      throw Exception('Aucun magasin connecté');
    }

    final userId = clientData['user_id'];
    if (userId == null || userId.toString().isEmpty) {
      throw const FormatException(
        'Le QR code ne contient pas de user_id valide',
      );
    }
  }

  /// Handles scan errors
  void _handleScanError(String message, dynamic error) {
    debugPrint('Scan Error: $error');
    _setProcessing(false);
    _showSnackBar(message: message, backgroundColor: Colors.red);
    _resumeCamera();
  }

  /// Sets processing state
  void _setProcessing(bool processing) {
    if (mounted) {
      setState(() => _isProcessing = processing);
    }
  }

  /// Pauses the camera
  Future<void> _pauseCamera() async {
    await _controller?.pauseCamera();
  }

  /// Resumes the camera
  Future<void> _resumeCamera() async {
    await _controller?.resumeCamera();
  }

  /// Determines if loading should be shown
  bool _shouldShowLoading(CaissierState state) {
    return state is CaissierLoading || _isProcessing;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
