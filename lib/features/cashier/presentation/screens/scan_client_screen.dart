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
import 'package:mukhlissmagasin/l10n/app_localizations.dart';
import 'package:mukhlissmagasin/l10n/l10n.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

enum ScanMode { balance, rewards }

/// Screen for scanning client QR codes to add balance or view offers
class ScanClientScreen extends StatefulWidget {
  final double? montant;
  final ScanMode mode;

  const ScanClientScreen.balance(this.montant, {super.key}) : mode = ScanMode.balance;
  const ScanClientScreen.rewards({super.key}) : mode = ScanMode.rewards, montant = null;

  @override
  State<ScanClientScreen> createState() => _ScanClientScreenState();
}

class _ScanClientScreenState extends State<ScanClientScreen> with TickerProviderStateMixin {
  // Constants
  static const _qrDebugLabel = 'QR';
  static const _cutOutSize = 850.0;
  static const _borderWidth = 16.0;
  static const _borderLength = 80.0;
  static const _borderRadius = 40.0;


  // Controllers and state
  final GlobalKey _qrKey = GlobalKey(debugLabel: _qrDebugLabel);
  QRViewController? _controller;
  final CaissierCubit _cubit = getIt<CaissierCubit>();
  bool _isProcessing = false;

  // Animation controllers
  late AnimationController _scanLineController;
  late AnimationController _cornerController;
  late AnimationController _pulseController;
  late Animation<double> _scanLineAnimation;
  late Animation<double> _cornerAnimation;
  late Animation<double> _pulseAnimation;

  // Store client data for navigation
  String? _lastClientId;
  String? _lastMagasinId;

  bool get _isBalanceMode => widget.montant != null;
  final AudioPlayer _audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Scan line animation (vertical movement)
    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _scanLineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    // Corner pulse animation
    _cornerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _cornerAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _cornerController, curve: Curves.easeInOut),
    );

    // Outer pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  Future<void> _playSuccessSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/success.mp3'));
    } catch (_) {}
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

  PreferredSizeWidget _buildAppBar() {
    final L10n = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(
        _isBalanceMode ? L10n.scannerajoutersolde : L10n.scannervoiroffre,
      ),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.flip_camera_ios),
          onPressed: _flipCamera,
          tooltip: L10n.chnangercamera,
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    final L10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              QRView(
                key: _qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.transparent,
                  borderRadius: _borderRadius,
                  borderLength: 0,
                  borderWidth: 0,
                  cutOutSize: _cutOutSize,
                ),
                cameraFacing: CameraFacing.front,
                formatsAllowed: const [BarcodeFormat.qrcode],
              ),
              // Custom animated overlay
              _buildAnimatedOverlay(),
            ],
          ),
        ),
        Container(
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
                    ? L10n.scannerpourajoutersolde
                    : L10n.scannerpourvoiroffre,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (_isBalanceMode) _buildAmountDisplay(),
              if (_isBalanceMode) ...[
                const SizedBox(height: 12),
                Text(
                  L10n.vousserezrederigervers,
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
      ],
    );
  }

  Widget _buildAnimatedOverlay() {
    return Center(
      child: SizedBox(
        width: _cutOutSize,
        height: _cutOutSize,
        child: Stack(
          children: [
            // Outer pulse effect
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: 1 - _pulseAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: _borderWidth * (1 + _pulseAnimation.value * 0.5),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Main border with gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_borderRadius),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: _borderWidth,
                ),
              ),
            ),
            // Animated corners
            _buildAnimatedCorners(),
            // Scan line animation
            AnimatedBuilder(
              animation: _scanLineAnimation,
              builder: (context, child) {
                return Positioned(
                  top: _cutOutSize * _scanLineAnimation.value - 2,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Grid pattern
            _buildGridPattern(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCorners() {
    return AnimatedBuilder(
      animation: _cornerAnimation,
      builder: (context, child) {
        final color = Theme.of(context).primaryColor;
        return Stack(
          children: [
            // Top-left corner
            Positioned(
              top: 0,
              left: 0,
              child: Transform.scale(
                scale: _cornerAnimation.value,
                alignment: Alignment.topLeft,
                child: _buildCorner(color, true, true),
              ),
            ),
            // Top-right corner
            Positioned(
              top: 0,
              right: 0,
              child: Transform.scale(
                scale: _cornerAnimation.value,
                alignment: Alignment.topRight,
                child: _buildCorner(color, true, false),
              ),
            ),
            // Bottom-left corner
            Positioned(
              bottom: 0,
              left: 0,
              child: Transform.scale(
                scale: _cornerAnimation.value,
                alignment: Alignment.bottomLeft,
                child: _buildCorner(color, false, true),
              ),
            ),
            // Bottom-right corner
            Positioned(
              bottom: 0,
              right: 0,
              child: Transform.scale(
                scale: _cornerAnimation.value,
                alignment: Alignment.bottomRight,
                child: _buildCorner(color, false, false),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCorner(Color color, bool isTop, bool isLeft) {
    return SizedBox(
      width: _borderLength,
      height: _borderLength,
      child: CustomPaint(
        painter: CornerPainter(
          color: color,
          isTop: isTop,
          isLeft: isLeft,
          borderWidth: _borderWidth * 1.5,
        ),
      ),
    );
  }

  Widget _buildGridPattern() {
    return Opacity(
      opacity: 0.1,
      child: CustomPaint(
        size: const Size(_cutOutSize, _cutOutSize),
        painter: GridPainter(color: Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _buildAmountDisplay() {
    final L10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        L10n.mantant + ': ${widget.montant!.toStringAsFixed(2)}' + L10n.dh,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    final L10n = AppLocalizations.of(context)!;
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
              _isBalanceMode ? L10n.ajoutencour : L10n.traitementencouor,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (_isBalanceMode) ...[
              const SizedBox(height: 8),
              Text(
                L10n.redirectionversoffres,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, CaissierState state) {
    switch (state) {
      case SoldeAjoute():
        final pointsGagnes = state.clientMagasin.cumulePoint;
        final soldeRestant = state.clientMagasin.solde;
        _handleBalanceAdded(pointsGagnes, soldeRestant);
        break;
      case CaissierError():
        _handleError(state.message);
        break;
      default:
        break;
    }
  }

  Future<void> _handleBalanceAdded(double pointsGagnes, double soldeRestant) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FelicitationScreen(
          pointsGagnes: pointsGagnes.toInt(),
          soldeRestant: soldeRestant,
        ),
      ),
    );
    if (mounted) Navigator.pop(context, true);
  }

  void _handleError(String message) {
    _setProcessing(false);
    _showSnackBar(message: 'Erreur: $message', backgroundColor: Colors.red);
    _resumeCamera();
  }

  void _showSnackBar({required String message, required Color backgroundColor}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen(_handleQRScan);
  }

  Future<void> _flipCamera() async {
    await _controller?.flipCamera();
  }

  Future<void> _handleQRScan(Barcode scanData) async {
    final L10n = AppLocalizations.of(context)!;
    if (!_canProcessScan(scanData)) return;

    _setProcessing(true);
    await _pauseCamera();

    try {
      await _processQRCode(scanData.code!);
    } on FormatException catch (e) {
      _handleScanError(L10n.qrcodeinvalide, e);
    } catch (e) {
      _handleScanError(L10n.erreurtraitement + ': ${e.toString()}', e);
    }
  }

  bool _canProcessScan(Barcode scanData) {
    return scanData.code != null && mounted && !_isProcessing;
  }

  Future<void> _processQRCode(String qrCode) async {
    final L10n = AppLocalizations.of(context)!;
    final clientData = _parseQRCode(qrCode);
    final currentUser = _getCurrentUser();
    _validateData(clientData, currentUser);

    _lastClientId = clientData['user_id'].toString();
    _lastMagasinId = currentUser.id;

    if (widget.mode == ScanMode.balance) {
      await _cubit.ajouterSoldeClient(
        clientId: _lastClientId!,
        magasinId: _lastMagasinId!,
        montant: widget.montant!,
      );
      return;
    }

    final points = await getIt<CaissierRepository>().getClientPoints(
      clientId: _lastClientId!,
      magasinId: _lastMagasinId!,
    );

    await _playSuccessSound();
    _showSnackBar(message: L10n.qrreconu + '✔️', backgroundColor: Colors.green);
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      Navigator.pop(context, {
        'clientId': _lastClientId!,
        'magasinId': _lastMagasinId!,
        'clientPoints': points.toString(),
      });
    }
  }

  Map<String, dynamic> _parseQRCode(String qrCode) {
    debugPrint('QR Data: $qrCode');
    return jsonDecode(qrCode) as Map<String, dynamic>;
  }

  dynamic _getCurrentUser() {
    final currentUser = getIt<AuthRepository>().getCurrentUser();
    debugPrint('Current User: ${currentUser?.id}');
    return currentUser;
  }

  void _validateData(Map<String, dynamic> clientData, dynamic currentUser) {
    if (currentUser == null) {
      throw Exception('Aucun magasin connecté');
    }
    final userId = clientData['user_id'];
    if (userId == null || userId.toString().isEmpty) {
      throw const FormatException('Le QR code ne contient pas de user_id valide');
    }
  }

  void _handleScanError(String message, dynamic error) {
    debugPrint('Scan Error: $error');
    _setProcessing(false);
    _showSnackBar(message: message, backgroundColor: Colors.red);
    _resumeCamera();
  }

  void _setProcessing(bool processing) {
    if (mounted) {
      setState(() => _isProcessing = processing);
    }
  }

  Future<void> _pauseCamera() async {
    await _controller?.pauseCamera();
  }

  Future<void> _resumeCamera() async {
    await _controller?.resumeCamera();
  }

  bool _shouldShowLoading(CaissierState state) {
    return state is CaissierLoading || _isProcessing;
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _cornerController.dispose();
    _pulseController.dispose();
    _controller?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}

// Custom painter for animated corners
class CornerPainter extends CustomPainter {
  final Color color;
  final bool isTop;
  final bool isLeft;
  final double borderWidth;

  CornerPainter({
    required this.color,
    required this.isTop,
    required this.isLeft,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (isTop && isLeft) {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CornerPainter oldDelegate) => false;
}

// Custom painter for grid pattern
class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSize = 20.0;

    // Vertical lines
    for (double i = gridSize; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Horizontal lines
    for (double i = gridSize; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}