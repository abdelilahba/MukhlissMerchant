import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// 🧪 Écran de test Sentry
/// 
/// Test les différents types d'erreurs capturées par Sentry
class SentryTestScreen extends StatelessWidget {
  const SentryTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Monitoring Sentry'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header
              const Icon(
                Icons.bug_report,
                size: 80,
                color: Color(0xFF6366F1),
              ),
              const SizedBox(height: 24),
              const Text(
                'Test Monitoring Sentry',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cliquez sur un bouton pour envoyer une erreur de test à Sentry',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),

              // Test 1: Message simple
              _buildTestButton(
                context,
                icon: Icons.message,
                title: 'Test 1: Message Simple',
                description: 'Envoie un message de test',
                color: const Color(0xFF10B981),
                onPressed: () {
                  Sentry.captureMessage(
                    'Test Flutter - Message simple 🎉',
                    level: SentryLevel.info,
                  );
                  _showSuccess(context, 'Message envoyé à Sentry!');
                },
              ),

              const SizedBox(height: 16),

              // Test 2: Exception simple
              _buildTestButton(
                context,
                icon: Icons.error_outline,
                title: 'Test 2: Exception',
                description: 'Envoie une exception de test',
                color: const Color(0xFFF59E0B),
                onPressed: () {
                  Sentry.captureException(
                    Exception('Test Flutter - Exception de test! ⚠️'),
                    stackTrace: StackTrace.current,
                  );
                  _showSuccess(context, 'Exception envoyée à Sentry!');
                },
              ),

              const SizedBox(height: 16),

              // Test 3: Erreur avec contexte
              _buildTestButton(
                context,
                icon: Icons.info_outline,
                title: 'Test 3: Erreur avec Contexte',
                description: 'Envoie une erreur avec informations utilisateur',
                color: const Color(0xFF8B5CF6),
                onPressed: () async {
                  // Ajouter contexte utilisateur
                  Sentry.configureScope((scope) {
                    scope.setUser(SentryUser(
                      id: 'test-123',
                      email: 'test@mukhliss.com',
                      username: 'Test User',
                    ));
                    scope.setTag('test_type', 'manual');
                    scope.setExtra('device', 'Flutter Web');
                  });

                  await Sentry.captureException(
                    Exception('Test avec contexte utilisateur 👤'),
                  );

                  if (context.mounted) {
                    _showSuccess(context, 'Erreur avec contexte envoyée!');
                  }
                },
              ),

              const SizedBox(height: 16),

              // Test 4: Crash simulé
              _buildTestButton(
                context,
                icon: Icons.warning,
                title: 'Test 4: Crash Simulé',
                description: 'Déclenche un vrai crash (null error)',
                color: const Color(0xFFEF4444),
                onPressed: () {
                  try {
                    // Déclencher une vraie erreur
                    throw StateError('Test Flutter - Crash simulé! 💥');
                  } catch (error, stackTrace) {
                    Sentry.captureException(
                      error,
                      stackTrace: stackTrace,
                    );
                    _showSuccess(context, 'Crash capturé et envoyé!');
                  }
                },
              ),

              const SizedBox(height: 40),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Cliquez sur un bouton de test\n'
                      '2. Attendez 10-30 secondes\n'
                      '3. Allez sur sentry.io\n'
                      '4. Projet: Mukhliss-Backend\n'
                      '5. Vérifiez Issues → Vous devriez voir l\'erreur!',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
