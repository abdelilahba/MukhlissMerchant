import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

/// 🎉 Bottom Sheet élégant pour célébrer les points et proposer les récompenses
class RewardsCelebrationSheet extends StatefulWidget {
  final int pointsAdded;
  final int totalPoints;
  final List<Reward> availableRewards;
  final VoidCallback? onExchangeRewards;
  final VoidCallback? onSaveLater;

  const RewardsCelebrationSheet({
    super.key,
    required this.pointsAdded,
    required this.totalPoints,
    required this.availableRewards,
    this.onExchangeRewards,
    this.onSaveLater,
  });

  @override
  State<RewardsCelebrationSheet> createState() => _RewardsCelebrationSheetState();
}

class _RewardsCelebrationSheetState extends State<RewardsCelebrationSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  Timer? _autoCloseTimer;
  int _remainingSeconds = 10;

  @override
  void initState() {
    super.initState();
    
    // Animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
    
    // Auto-fermeture uniquement si des récompenses sont disponibles
    if (widget.availableRewards.isNotEmpty) {
      _startAutoCloseTimer();
    } else {
      // Si pas de récompenses, fermer automatiquement après 3 secondes
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _startAutoCloseTimer() {
    _autoCloseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  void _cancelAutoClose() {
    _autoCloseTimer?.cancel();
    setState(() {
      _remainingSeconds = 0; // Cache le compteur
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: PopScope(
          canPop: false,
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 340, // Largeur maximale augmentée pour plus de confort
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Célébration des points
                _buildPointsCelebration(l10n),
                
                // Récompenses disponibles ou message d'encouragement
                widget.availableRewards.isNotEmpty
                    ? _buildAvailableRewards(l10n)
                    : _buildEncouragementMessage(l10n),
                
                // Boutons d'action
                if (widget.availableRewards.isNotEmpty)
                  _buildActionButtons(l10n),
                
                // Compteur auto-fermeture - Discret en bas
                if (_remainingSeconds > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: _remainingSeconds / 10,
                            color: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ferme dans $_remainingSeconds s',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPointsCelebration(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: Color(0xFF10B981), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Félicitations !',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF065F46),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '+${widget.pointsAdded}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF059669),
                      ),
                    ),
                    Text(
                      ' ${l10n.pts}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF059669),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Total: ${widget.totalPoints}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableRewards(AppLocalizations l10n) {
    // Version ultra-compacte : juste un résumé
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE047)),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard_rounded, color: Color(0xFFD97706), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.availableRewards.length} récompenses dispo !',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                Text(
                  widget.availableRewards.first.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFFB45309).withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFD97706)),
        ],
      ),
    );
  }

  Widget _buildEncouragementMessage(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.savings_outlined, color: Colors.grey[400], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Continuez à économiser pour des cadeaux !',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          // Bouton "Plus tard" compact
          Expanded(
            child: TextButton(
              onPressed: () {
                _cancelAutoClose();
                widget.onSaveLater?.call();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: Colors.grey[600],
              ),
              child: const Text('Plus tard', style: TextStyle(fontSize: 14)),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Bouton "Voir" compact
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                _cancelAutoClose();
                widget.onExchangeRewards?.call();
                // Navigator.pop retiré : géré dans le callback parent
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'VOIR CADEAUX',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
