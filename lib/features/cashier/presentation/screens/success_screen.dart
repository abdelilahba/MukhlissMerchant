import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/screens/caissier_home_screen.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

class FelicitationScreen extends StatelessWidget {
  final int pointsGagnes;
  final int? totalPoints;
  final bool isEmbedded;
  final VoidCallback? onCompleted;
  final double? soldeRestant;
  final bool isForRewards;

  const FelicitationScreen({
    super.key,
    required this.pointsGagnes,
    this.totalPoints,
    this.soldeRestant,
    this.isEmbedded = false,
    this.onCompleted,
    this.isForRewards = false,
  });

  @override
  Widget build(BuildContext context) {
    final L10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF10B981).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Transaction réussie',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.add_circle_rounded,
                            iconColor: Color(0xFFF59E0B),
                            iconBg: Color(0xFFFEF3C7),
                            label: 'Gagnés',
                            value: '+$pointsGagnes',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.stars_rounded,
                            iconColor: Color(0xFF3B82F6),
                            iconBg: Color(0xFFDBEAFE),
                            label: 'Total',
                            value: '$totalPoints',
                          ),
                        ),
                        if (soldeRestant != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.account_balance_wallet_rounded,
                              iconColor: Color(0xFF10B981),
                              iconBg: Color(0xFFD1FAE5),
                              label: 'Solde',
                              value: '${soldeRestant!.toStringAsFixed(0)}',
                              suffix: 'DH',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Scannez pour échanger vos points',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isEmbedded) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (onCompleted != null) onCompleted!();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Scanner',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    if (onCompleted != null) {
                      onCompleted!();
                    } else {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const CaissierHomeScreen(),
                        ),
                      );
                    }
                  },
                  child: Text(
                    L10n.terminer,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    String? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: iconBg.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          if (suffix != null)
            Text(
              suffix,
              style: TextStyle(
                fontSize: 10,
                color: iconColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
