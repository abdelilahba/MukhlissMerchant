import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

/// Écran affiché juste après un scan réussi pour féliciter le client
/// et montrer le nombre de points cumulés.
class FelicitationScreen extends StatefulWidget {
  /// Nombre de points que le client vient de gagner
  final double pointsGagnes;

  /// Solde restant éventuel (facultatif)
  final double? soldeRestant;

  const FelicitationScreen({
    super.key,
    required this.pointsGagnes,
    this.soldeRestant,
  });

  @override
  State<FelicitationScreen> createState() => _FelicitationScreenState();
}

class _FelicitationScreenState extends State<FelicitationScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3))
      ..play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti animation
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            maxBlastForce: 20,
            minBlastForce: 8,
            colors: const [
              Colors.blue,
              Colors.green,
              Colors.purple,
              Colors.orange,
              Colors.pink,
              Colors.yellow,
            ],
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 100,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                Text(
                  'Félicitations !',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Vous venez de gagner',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.pointsGagnes} points',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.green[700],
                  ),
                ),
                if (widget.soldeRestant != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Solde restant : ${widget.soldeRestant!.toStringAsFixed(2)} DH',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, true); // renvoie un bool pour éventuel refresh
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Terminé'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}