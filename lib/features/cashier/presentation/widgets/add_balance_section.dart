/// Widget pour la section d'ajout de solde.
///
/// Contient le champ de saisie du montant et le bouton de scan.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget pour saisir un montant et scanner un client.
///
/// Composants:
/// - Champ de texte pour le montant (en DH)
/// - Bouton de scan QR
///
/// ### Exemple:
/// ```dart
/// AddBalanceSection(
///   controller: _montantController,
///   onScanPressed: () => _handleScan(),
///   onSubmit: (value) => _handleAddBalance(),
/// )
/// ```
class AddBalanceSection extends StatelessWidget {
  /// Controller pour le champ de montant
  final TextEditingController controller;

  /// Callback pour le bouton scan
  final VoidCallback onScanPressed;

  /// Callback pour la soumission du montant
  final ValueChanged<String>? onSubmit;

  /// Devise à afficher (défaut: DH)
  final String currency;

  /// Placeholder du champ montant
  final String placeholder;

  /// Crée une section d'ajout de solde.
  const AddBalanceSection({
    super.key,
    required this.controller,
    required this.onScanPressed,
    this.onSubmit,
    this.currency = 'DH',
    this.placeholder = '0.00',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Champ de montant
        Expanded(
          child: _buildAmountField(context),
        ),
        const SizedBox(width: 10),
        // Bouton scanner
        _buildScanButton(),
      ],
    );
  }

  /// Construit le champ de saisie du montant.
  Widget _buildAmountField(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // Icône prefix
          const Padding(
            padding: EdgeInsets.only(left: 10, right: 6),
            child: Icon(
              Icons.attach_money_rounded,
              color: Color(0xFF10B981),
              size: 22,
            ),
          ),

          // TextField
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty && onSubmit != null) {
                  onSubmit!(value);
                }
              },
            ),
          ),

          // Suffixe devise
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              currency,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit le bouton de scan.
  Widget _buildScanButton() {
    return Container(
      width: 60,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onScanPressed,
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Bouton de scan QR code stylisé.
///
/// Version standalone du bouton de scan.
class QRScanButton extends StatelessWidget {
  /// Callback au clic
  final VoidCallback onPressed;

  /// Taille du bouton
  final double size;

  /// Texte optionnel sous l'icône
  final String? label;

  /// Crée un bouton de scan.
  const QRScanButton({
    super.key,
    required this.onPressed,
    this.size = 60,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(size * 0.25),
              onTap: onPressed,
              child: Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: size * 0.4,
              ),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ],
    );
  }
}

/// Section de saisie manuelle du code client.
///
/// Alternative au scan QR pour saisir le code manuellement.
class ManualCodeInput extends StatelessWidget {
  /// Controller pour le code
  final TextEditingController controller;

  /// Callback à la soumission
  final ValueChanged<String> onSubmit;

  /// Placeholder
  final String placeholder;

  /// Label du bouton
  final String buttonLabel;

  /// Crée une section de saisie manuelle.
  const ManualCodeInput({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.placeholder = 'Entrez le code client',
    this.buttonLabel = 'Valider',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          const Text(
            'Saisie manuelle',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),

          // Input + Bouton
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: placeholder,
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF10B981),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      onSubmit(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  final value = controller.text.trim();
                  if (value.isNotEmpty) {
                    onSubmit(value);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
