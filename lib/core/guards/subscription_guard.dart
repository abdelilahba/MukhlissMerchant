import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mukhlissmagasin/core/config/app_config.dart';
import 'package:mukhlissmagasin/core/services/subscription_service.dart';
import 'package:mukhlissmagasin/core/services/periodic_subscription_checker.dart';

/// 🎨 DESIGN MODERNE - Interface élégante et professionnelle
class SubscriptionGuardModern extends StatefulWidget {
  final Widget child;
  final String magasinId;

  const SubscriptionGuardModern({
    super.key,
    required this.child,
    required this.magasinId,
  });

  @override
  State<SubscriptionGuardModern> createState() => _SubscriptionGuardModernState();
}

class _SubscriptionGuardModernState extends State<SubscriptionGuardModern> {
  final _subscriptionService = SubscriptionService();
  final _periodicChecker = PeriodicSubscriptionChecker();

  bool _isChecking = true;
  AccessResult? _accessResult;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  @override
  void dispose() {
    _periodicChecker.dispose();
    super.dispose();
  }

  Future<void> _checkAccess() async {
    setState(() => _isChecking = true);
    final result = await _subscriptionService.checkAccess(widget.magasinId);
    if (mounted) {
      setState(() {
        _accessResult = result;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return _buildLoadingScreen();
    }

    if (_accessResult?.canAccess != true) {
      return _ModernAccessDeniedScreen(
        result: _accessResult!,
        onRetry: _checkAccess,
      );
    }

    return widget.child;
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation de chargement avec gradient
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade600,
                    Colors.purple.shade600,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.8)),
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'VÉRIFICATION DE L\'ABONNEMENT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Veuillez patienter...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🎨 Écran moderne d'accès refusé
class _ModernAccessDeniedScreen extends StatelessWidget {
  final AccessResult result;
  final VoidCallback onRetry;

  const _ModernAccessDeniedScreen({
    required this.result,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Illustration
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.red.shade100,
                        Colors.orange.shade100,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lock_clock_rounded,
                      size: 80,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Titre
                Text(
                  result.blockTitle.toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                          Colors.red.shade600,
                          Colors.orange.shade600,
                        ],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 15),

                // Sous-titre
                Text(
                  'Accès temporairement suspendu',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),

              

          

                // Date d'expiration
                if (result.expiresOn != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.blue.shade50,
                          Colors.purple.shade50,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.shade100,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DATE D\'EXPIRATION',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _formatDate(result.expiresOn!),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Design Option 1: Cartes de contact modernes
                ModernContactCards(),

                const SizedBox(height: 15),

         
                if (result.status == 'error')
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                            shadowColor: Colors.blue.withOpacity(0.3),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh_rounded, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'RÉESSAYER LA CONNEXION',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// 🎨 OPTION 1: Cartes de contact modernes avec icônes
class ModernContactCards extends StatelessWidget {
  ModernContactCards({super.key});

  final List<ContactMethod> contactMethods = [
    ContactMethod(
      icon: Icons.phone_in_talk_rounded,
      title: 'Appelez-nous',
      subtitle: 'Réponse immédiate',
      contact: '+212 666-570303',
      color: Colors.green.shade600,
    
    ),

    ContactMethod(
      icon: Icons.email_rounded,
      title: 'Email',
      subtitle: 'Réponse sous 24h',
      contact: 'mukhlissfidelite@gmail.com',
      color: Colors.blue.shade600,
     
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // En-tête
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade600,
                      Colors.purple.shade600,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONTACTEZ-NOUS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plusieurs façons de nous joindre',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Cartes de contact
          Column(
            children: contactMethods
                .map((method) => _buildContactCard(method, context))
                .toList(),
          ),

          const SizedBox(height: 5),

          // Indicateur de disponibilité
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green.shade500,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Support disponible 24h/24, 7j/7',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(ContactMethod method, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: InkWell(
        onTap: () => _handleContact(method, context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icône avec background
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      method.color.withOpacity(0.1),
                      method.color.withOpacity(0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    method.icon,
                    color: method.color,
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      method.contact,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: method.color,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 15),

      
            ],
          ),
        ),
      ),
    );
  }

  void _handleContact(ContactMethod method, BuildContext context) {
    // TODO: Implémenter les actions de contact
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture de ${method.title}...'),
        backgroundColor: method.color,
      ),
    );
  }
}

/// 🎨 OPTION 2: Design avec boutons d'action rapides
class ContactActionButtons extends StatelessWidget {
  const ContactActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.purple.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'CONTACT RAPIDE',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cliquez pour nous contacter directement',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.phone_rounded,
                  label: 'Appeler',
                  color: Colors.green.shade400,
                  onTap: () => _makePhoneCall(context),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.phone,
                  label: 'WhatsApp',
                  color: Colors.green.shade300,
                  onTap: () => _openWhatsApp(context),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.email_rounded,
                  label: 'Email',
                  color: Colors.blue.shade300,
                  onTap: () => _sendEmail(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Détails des contacts
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                _buildContactDetail(
                  Icons.phone_rounded,
                  '+212 666-570303',
                ),
                const SizedBox(height: 12),
                _buildContactDetail(
                  Icons.email_rounded,
                  'mukhlissfidelite@gmail.com',
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Indicateur de disponibilité
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time_rounded,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Support 24/7 • Réponse rapide',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _makePhoneCall(BuildContext context) {
    // TODO: Implémenter l'appel
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appel du support...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _openWhatsApp(BuildContext context) {
    // TODO: Implémenter WhatsApp
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ouverture de WhatsApp...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendEmail(BuildContext context) {
    // TODO: Implémenter l'email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ouverture de l\'application email...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

/// 🎨 OPTION 3: Design minimaliste élégant
class ElegantContactDesign extends StatelessWidget {
  const ElegantContactDesign({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.contact_support_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'SUPPORT CLIENT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Contactez-nous pour renouveler votre abonnement',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Liste des contacts
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                _buildElegantContactItem(
                  icon: Icons.phone_iphone_rounded,
                  title: 'Support Téléphonique',
                  value: '+212 666-570303',
                  color: Colors.green.shade600,
                ),
                const SizedBox(height: 20),
                _buildElegantContactItem(
                  icon: Icons.phone,
                  title: 'WhatsApp Business',
                  value: '+212 666-570303',
                  color: Colors.green.shade500,
                ),
                const SizedBox(height: 20),
                _buildElegantContactItem(
                  icon: Icons.email_rounded,
                  title: 'Email de Support',
                  value: 'mukhlissfidelite@gmail.com',
                  color: Colors.blue.shade600,
                ),
              ],
            ),
          ),

          // Pied de page
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border(
                top: BorderSide(color: Colors.orange.shade100),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_filled_rounded,
                  color: Colors.orange.shade600,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Disponibilité',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      Text(
                        '24 heures / 7 jours',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'RAPIDE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.orange.shade700,
                      letterSpacing: 1,
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

  Widget _buildElegantContactItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2), width: 2),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey.shade400,
            size: 18,
          ),
        ],
      ),
    );
  }
}

/// 🎨 OPTION 4: Design avec icônes circulaires
class CircularContactDesign extends StatelessWidget {
  const CircularContactDesign({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'CHOISISSEZ UN MODE DE CONTACT',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.grey.shade900,
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Cliquez sur une icône pour nous contacter',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Icônes circulaires
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircularContactIcon(
                icon: Icons.phone_rounded,
                label: 'Appel',
                color: Colors.green.shade600,
                value: '+212 666-570303',
                context: context,
              ),
              _buildCircularContactIcon(
                icon: Icons.phone,
                label: 'WhatsApp',
                color: Colors.green.shade500,
                value: '+212 666-570303',
                context: context,
              ),
              _buildCircularContactIcon(
                icon: Icons.email_rounded,
                label: 'Email',
                color: Colors.blue.shade600,
                value: 'mukhlissfidelite@gmail.com',
                context: context,
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Coordonnées détaillées
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.phone_rounded,
                  'Téléphone',
                  '+212 666-570303',
                  Colors.green.shade600,
                ),
                const SizedBox(height: 15),
                _buildDetailRow(
                  Icons.email_rounded,
                  'Email',
                  'mukhlissfidelite@gmail.com',
                  Colors.blue.shade600,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Badge de disponibilité
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'SUPPORT ACTIF 24/7',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularContactIcon({
    required IconData icon,
    required String label,
    required Color color,
    required String value,
    required BuildContext context,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Contact via $label...'),
                backgroundColor: color,
              ),
            );
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
      IconData icon, String title, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 🎨 Classe d'assistance pour les méthodes de contact
class ContactMethod {
  final IconData icon;
  final String title;
  final String subtitle;
  final String contact;
  final Color color;


  ContactMethod({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.contact,
    required this.color,

  });
}