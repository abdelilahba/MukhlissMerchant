import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/screens/scan_client_screen.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

/// Widget pour la saisie manuelle du code client avec toggle.
///
/// Permet à l'utilisateur de saisir manuellement un code
/// quand le scan QR ne fonctionne pas. Gère l'état show/hide.
///
/// ### Exemple:
/// ```dart
/// ManualCodeInputSection(
///   showInput: _showManualInput,
///   scanMode: _currentScanMode,
///   onToggle: () => setState(() => _showManualInput = !_showManualInput),
///   onSubmit: (code, mode) => _handleManualCodeSubmit(code, mode),
///   onBack: () => setState(() => _showManualInput = false),
/// )
/// ```
class ManualCodeInputSection extends StatefulWidget {
  /// Affiche le champ de saisie ou le bouton
  final bool showInput;

  /// Mode de scan actuel
  final ScanMode scanMode;

  /// Callback quand on toggle le mode
  final VoidCallback onToggle;

  /// Callback quand on soumet le code
  final void Function(String code, ScanMode mode) onSubmit;

  /// Callback quand on appuie sur retour
  final VoidCallback onBack;

  const ManualCodeInputSection({
    super.key,
    required this.showInput,
    required this.scanMode,
    required this.onToggle,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  State<ManualCodeInputSection> createState() => _ManualCodeInputSectionState();
}

class _ManualCodeInputSectionState extends State<ManualCodeInputSection> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!widget.showInput) ...[
            _buildToggleButton(l10n),
            const SizedBox(height: 8),
            _buildHelpText(l10n),
          ],
          if (widget.showInput) ...[
            _buildInputHeader(l10n),
            _buildCodeInput(l10n),
            const SizedBox(height: 12),
            _buildValidateButton(l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onToggle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.keyboard_alt_rounded,
                color: Color(0xFF6B7280),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.codemanuelle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpText(AppLocalizations l10n) {
    return Text(
      l10n.scannefonctionnepas,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[500],
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildInputHeader(AppLocalizations l10n) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: Color(0xFF6B7280),
          ),
          onPressed: () {
            _codeController.clear();
            widget.onBack();
          },
        ),
        Text(
          l10n.saisimanuelle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInput(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: _codeController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(8),
        ],
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 8,
          color: Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: '000000',
          hintStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            letterSpacing: 8,
            color: Colors.grey[300],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: const Icon(
            Icons.person_outline_rounded,
            color: Color(0xFF6366F1),
          ),
        ),
        onSubmitted: (code) {
          if (code.length == 8) {
            widget.onSubmit(code, widget.scanMode);
          }
        },
      ),
    );
  }

  Widget _buildValidateButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            final code = _codeController.text;
            if (code.length == 6) {
              widget.onSubmit(code, widget.scanMode);
            }
            else {
              // Optionally show an error message if the code is invalid
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("ghhrehyf"),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.validercode,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
