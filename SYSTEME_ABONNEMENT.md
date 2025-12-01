# 🔐 SYSTÈME D'ABONNEMENT ET CONTRÔLE D'ACCÈS

## 📋 ARCHITECTURE COMPLÈTE

---

# 🎯 VUE D'ENSEMBLE

## Fonctionnalités
1. ✅ Abonnements mensuels/annuels
2. ✅ Vérification automatique à chaque connexion
3. ✅ Blocage automatique si abonnement expiré
4. ✅ Suspension manuelle d'un magasin
5. ✅ Dashboard admin pour gérer les abonnements
6. ✅ Notifications avant expiration

---

# 📊 ÉTAPE 1 : MODÈLE DE DONNÉES (SQL)

## Fichier : `supabase_functions/subscriptions_schema.sql`

```sql
-- ================================================================================
-- SYSTÈME D'ABONNEMENT
-- ================================================================================

-- 1. Table des plans d'abonnement
CREATE TABLE IF NOT EXISTS subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price_monthly DECIMAL(10, 2) NOT NULL,
    price_yearly DECIMAL(10, 2) NOT NULL,
    max_staff_users INTEGER DEFAULT 5,
    max_clients INTEGER DEFAULT 10000,
    max_transactions_per_month INTEGER DEFAULT 100000,
    features JSONB, -- Features incluses (JSON)
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Table des abonnements des magasins
CREATE TABLE IF NOT EXISTS magasin_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    magasin_id UUID NOT NULL REFERENCES magasins(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id),
    
    -- Statut
    status VARCHAR(20) NOT NULL DEFAULT 'active', 
    -- 'active', 'expired', 'suspended', 'cancelled'
    
    -- Dates
    start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_date TIMESTAMPTZ NOT NULL,
    next_billing_date TIMESTAMPTZ,
    
    -- Paiement
    payment_method VARCHAR(50), -- 'credit_card', 'bank_transfer', etc.
    last_payment_date TIMESTAMPTZ,
    last_payment_amount DECIMAL(10, 2),
    
    -- Raisons de suspension
    suspension_reason TEXT,
    suspended_at TIMESTAMPTZ,
    suspended_by UUID, -- Admin user ID
    
    -- Métadonnées
    auto_renew BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Index
    UNIQUE(magasin_id)
);

-- 3. Table historique des paiements
CREATE TABLE IF NOT EXISTS subscription_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL REFERENCES magasin_subscriptions(id),
    magasin_id UUID NOT NULL REFERENCES magasins(id),
    
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'MAD',
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) NOT NULL, -- 'pending', 'completed', 'failed'
    
    transaction_id VARCHAR(255), -- ID de la transaction externe
    payment_date TIMESTAMPTZ DEFAULT NOW(),
    
    -- Période couverte
    period_start TIMESTAMPTZ NOT NULL,
    period_end TIMESTAMPTZ NOT NULL,
    
    -- Métadonnées
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Table des logs d'accès
CREATE TABLE IF NOT EXISTS access_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    magasin_id UUID NOT NULL REFERENCES magasins(id),
    user_id UUID NOT NULL,
    
    action VARCHAR(50) NOT NULL, -- 'login_attempt', 'access_granted', 'access_denied'
    reason VARCHAR(255), -- Raison du refus si access_denied
    
    ip_address INET,
    user_agent TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================================================
-- INDEX POUR PERFORMANCE
-- ================================================================================

CREATE INDEX idx_magasin_subscriptions_magasin ON magasin_subscriptions(magasin_id);
CREATE INDEX idx_magasin_subscriptions_status ON magasin_subscriptions(status);
CREATE INDEX idx_magasin_subscriptions_end_date ON magasin_subscriptions(end_date);
CREATE INDEX idx_subscription_payments_magasin ON subscription_payments(magasin_id);
CREATE INDEX idx_access_logs_magasin ON access_logs(magasin_id, created_at DESC);

-- ================================================================================
-- FONCTION : Vérifier l'accès d'un magasin
-- ================================================================================

CREATE OR REPLACE FUNCTION check_magasin_access(p_magasin_id UUID)
RETURNS TABLE (
    has_access BOOLEAN,
    status VARCHAR(20),
    reason TEXT,
    end_date TIMESTAMPTZ
) AS $$
DECLARE
    v_subscription RECORD;
BEGIN
    -- Récupérer l'abonnement actif
    SELECT * INTO v_subscription
    FROM magasin_subscriptions
    WHERE magasin_id = p_magasin_id
    LIMIT 1;
    
    -- Pas d'abonnement trouvé
    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            false, 
            'no_subscription'::VARCHAR(20), 
            'Aucun abonnement trouvé'::TEXT,
            NULL::TIMESTAMPTZ;
        RETURN;
    END IF;
    
    -- Vérifier si suspendu
    IF v_subscription.status = 'suspended' THEN
        RETURN QUERY SELECT 
            false, 
            'suspended'::VARCHAR(20),
            COALESCE(v_subscription.suspension_reason, 'Abonnement suspendu')::TEXT,
            v_subscription.end_date;
        RETURN;
    END IF;
    
    -- Vérifier si expiré
    IF v_subscription.end_date < NOW() THEN
        -- Mettre à jour le statut automatiquement
        UPDATE magasin_subscriptions
        SET status = 'expired'
        WHERE id = v_subscription.id;
        
        RETURN QUERY SELECT 
            false, 
            'expired'::VARCHAR(20),
            'Abonnement expiré le ' || v_subscription.end_date::TEXT,
            v_subscription.end_date;
        RETURN;
    END IF;
    
    -- Tout est OK
    RETURN QUERY SELECT 
        true, 
        v_subscription.status::VARCHAR(20),
        'Accès autorisé'::TEXT,
        v_subscription.end_date;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================================
-- FONCTION : Suspendre un magasin
-- ================================================================================

CREATE OR REPLACE FUNCTION suspend_magasin(
    p_magasin_id UUID,
    p_reason TEXT,
    p_admin_user_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE magasin_subscriptions
    SET 
        status = 'suspended',
        suspension_reason = p_reason,
        suspended_at = NOW(),
        suspended_by = p_admin_user_id,
        updated_at = NOW()
    WHERE magasin_id = p_magasin_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================================
-- FONCTION : Réactiver un magasin
-- ================================================================================

CREATE OR REPLACE FUNCTION reactivate_magasin(p_magasin_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE magasin_subscriptions
    SET 
        status = 'active',
        suspension_reason = NULL,
        suspended_at = NULL,
        suspended_by = NULL,
        updated_at = NOW()
    WHERE magasin_id = p_magasin_id
      AND end_date > NOW(); -- Seulement si pas expiré
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================================
-- FONCTION : Renouveler l'abonnement
-- ================================================================================

CREATE OR REPLACE FUNCTION renew_subscription(
    p_magasin_id UUID,
    p_months INTEGER DEFAULT 1,
    p_payment_amount DECIMAL DEFAULT 0
)
RETURNS BOOLEAN AS $$
DECLARE
    v_subscription_id UUID;
    v_current_end_date TIMESTAMPTZ;
    v_new_end_date TIMESTAMPTZ;
BEGIN
    -- Récupérer l'abonnement
    SELECT id, end_date INTO v_subscription_id, v_current_end_date
    FROM magasin_subscriptions
    WHERE magasin_id = p_magasin_id;
    
    IF NOT FOUND THEN
        RETURN false;
    END IF;
    
    -- Calculer la nouvelle date de fin
    IF v_current_end_date > NOW() THEN
        v_new_end_date := v_current_end_date + (p_months || ' months')::INTERVAL;
    ELSE
        v_new_end_date := NOW() + (p_months || ' months')::INTERVAL;
    END IF;
    
    -- Mettre à jour l'abonnement
    UPDATE magasin_subscriptions
    SET 
        end_date = v_new_end_date,
        next_billing_date = v_new_end_date,
        status = 'active',
        last_payment_date = NOW(),
        last_payment_amount = p_payment_amount,
        updated_at = NOW()
    WHERE id = v_subscription_id;
    
    -- Enregistrer le paiement
    INSERT INTO subscription_payments (
        subscription_id,
        magasin_id,
        amount,
        payment_status,
        period_start,
        period_end
    ) VALUES (
        v_subscription_id,
        p_magasin_id,
        p_payment_amount,
        'completed',
        GREATEST(v_current_end_date, NOW()),
        v_new_end_date
    );
    
    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================================
-- TRIGGER : Mise à jour automatique du timestamp
-- ================================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_magasin_subscriptions_updated_at
    BEFORE UPDATE ON magasin_subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ================================================================================
-- DONNÉES INITIALES : Plans d'abonnement
-- ================================================================================

INSERT INTO subscription_plans (name, description, price_monthly, price_yearly, max_staff_users, features)
VALUES 
(
    'Starter',
    'Parfait pour les petits commerces',
    199.00,
    1990.00,
    3,
    '{"features": ["3 utilisateurs", "1000 clients", "Support email"]}'::JSONB
),
(
    'Professional',
    'Pour les commerces en croissance',
    499.00,
    4990.00,
    10,
    '{"features": ["10 utilisateurs", "10000 clients", "Support prioritaire", "Analytics"]}'::JSONB
),
(
    'Enterprise',
    'Pour les grandes chaînes',
    999.00,
    9990.00,
    999,
    '{"features": ["Utilisateurs illimités", "Clients illimités", "Support 24/7", "API access"]}'::JSONB
);

-- ================================================================================
-- PERMISSIONS
-- ================================================================================

GRANT SELECT ON subscription_plans TO authenticated;
GRANT ALL ON magasin_subscriptions TO authenticated;
GRANT ALL ON subscription_payments TO authenticated;
GRANT ALL ON access_logs TO authenticated;

GRANT EXECUTE ON FUNCTION check_magasin_access TO authenticated;
GRANT EXECUTE ON FUNCTION suspend_magasin TO authenticated;
GRANT EXECUTE ON FUNCTION reactivate_magasin TO authenticated;
GRANT EXECUTE ON FUNCTION renew_subscription TO authenticated;
```

---

# 📱 ÉTAPE 2 : MIDDLEWARE DANS FLUTTER

## Fichier : `lib/core/middleware/subscription_middleware.dart`

```dart
import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/core/services/supabase_service.dart';

class SubscriptionMiddleware {
  final supabase = SupabaseService.client;

  /// Vérifie si le magasin a accès à l'app
  Future<SubscriptionStatus> checkAccess(String magasinId) async {
    try {
      final response = await supabase.rpc('check_magasin_access', params: {
        'p_magasin_id': magasinId,
      }).single();

      return SubscriptionStatus.fromJson(response);
    } catch (e) {
      print('Erreur vérification accès: $e');
      return SubscriptionStatus(
        hasAccess: false,
        status: 'error',
        reason: 'Erreur de connexion',
      );
    }
  }

  /// Log une tentative d'accès
  Future<void> logAccess({
    required String magasinId,
    required String userId,
    required String action,
    String? reason,
  }) async {
    try {
      await supabase.from('access_logs').insert({
        'magasin_id': magasinId,
        'user_id': userId,
        'action': action,
        'reason': reason,
      });
    } catch (e) {
      print('Erreur log accès: $e');
    }
  }
}

class SubscriptionStatus {
  final bool hasAccess;
  final String status;
  final String? reason;
  final DateTime? endDate;

  SubscriptionStatus({
    required this.hasAccess,
    required this.status,
    this.reason,
    this.endDate,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      hasAccess: json['has_access'] as bool,
      status: json['status'] as String,
      reason: json['reason'] as String?,
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : null,
    );
  }

  String get userMessage {
    switch (status) {
      case 'no_subscription':
        return 'Aucun abonnement actif. Contactez votre administrateur.';
      case 'suspended':
        return 'Compte suspendu. Raison : $reason';
      case 'expired':
        return 'Abonnement expiré. Veuillez renouveler votre abonnement.';
      default:
        return reason ?? 'Accès refusé';
    }
  }
}
```

---

# 🔒 ÉTAPE 3 : GUARD DANS L'APP

## Fichier : `lib/core/guards/subscription_guard.dart`

```dart
import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/core/middleware/subscription_middleware.dart';
import 'package:mukhlissmagasin/core/services/supabase_service.dart';

class SubscriptionGuard extends StatefulWidget {
  final Widget child;
  final String magasinId;

  const SubscriptionGuard({
    super.key,
    required this.child,
    required this.magasinId,
  });

  @override
  State<SubscriptionGuard> createState() => _SubscriptionGuardState();
}

class _SubscriptionGuardState extends State<SubscriptionGuard> {
  final _middleware = SubscriptionMiddleware();
  bool _isChecking = true;
  SubscriptionStatus? _status;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final status = await _middleware.checkAccess(widget.magasinId);
    
    final user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      await _middleware.logAccess(
        magasinId: widget.magasinId,
        userId: user.id,
        action: status.hasAccess ? 'access_granted' : 'access_denied',
        reason: status.reason,
      );
    }

    setState(() {
      _status = status;
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Vérification de l\'abonnement...'),
            ],
          ),
        ),
      );
    }

    if (_status?.hasAccess != true) {
      return _buildAccessDeniedScreen();
    }

    return widget.child;
  }

  Widget _buildAccessDeniedScreen() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.block,
                size: 80,
                color: Colors.red[300],
              ),
              const SizedBox(height: 24),
              Text(
                'Accès Refusé',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _status?.userMessage ?? 'Accès non autorisé',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              if (_status?.endDate != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Date d\'expiration : ${_formatDate(_status!.endDate!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Contact support
                },
                icon: const Icon(Icons.phone),
                label: const Text('Contacter le Support'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  setState(() => _isChecking = true);
                  await _checkAccess();
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
```

---

# 🎨 ÉTAPE 4 : UTILISATION DANS L'APP

## Fichier : `lib/main.dart` (modifier)

```dart
// Dans votre MaterialApp, wrapper les routes protégées

MaterialApp(
  home: FutureBuilder(
    future: _getMagasinId(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const CircularProgressIndicator();
      }

      return SubscriptionGuard(
        magasinId: snapshot.data!,
        child: CaissierHomeScreen(), // Votre écran principal
      );
    },
  ),
);
```

---

# 🎛️ ÉTAPE 5 : DASHBOARD ADMIN

## Fonctions à appeler depuis un dashboard admin

```dart
// Suspendre un magasin
Future<void> suspendMagasin(String magasinId, String reason) async {
  await supabase.rpc('suspend_magasin', params: {
    'p_magasin_id': magasinId,
    'p_reason': reason,
    'p_admin_user_id': currentAdminId,
  });
}

// Réactiver un magasin
Future<void> reactivateMagasin(String magasinId) async {
  await supabase.rpc('reactivate_magasin', params: {
    'p_magasin_id': magasinId,
  });
}

// Renouveler l'abonnement
Future<void> renewSubscription(
  String magasinId, 
  int months, 
  double amount
) async {
  await supabase.rpc('renew_subscription', params: {
    'p_magasin_id': magasinId,
    'p_months': months,
    'p_payment_amount': amount,
  });
}
```

---

# 📋 CHECKLIST D'IMPLÉMENTATION

## Phase 1 : Base de données
- [ ] Exécuter `subscriptions_schema.sql` sur Supabase
- [ ] Créer les plans d'abonnement
- [ ] Créer un abonnement test pour votre magasin

## Phase 2 : Flutter
- [ ] Créer `subscription_middleware.dart`
- [ ] Créer `subscription_guard.dart`
- [ ] Wrapper vos écrans avec `SubscriptionGuard`

## Phase 3 : Tests
- [ ] Tester avec abonnement actif
- [ ] Tester avec abonnement expiré
- [ ] Tester avec compte suspendu

## Phase 4 : Dashboard Admin (optionnel)
- [ ] Créer interface pour voir tous les magasins
- [ ] Boutons suspendre/réactiver
- [ ] Bouton renouveler abonnement

---

# 🎯 RÉSULTAT FINAL

**Vous pourrez :**
1. ✅ Bloquer automatiquement les magasins avec abonnement expiré
2. ✅ Suspendre manuellement un magasin (impayé, fraude, etc.)
3. ✅ Réactiver un magasin en un clic
4. ✅ Voir l'historique des accès
5. ✅ Gérer les renouvellements

**Voulez-vous que je crée aussi le dashboard admin pour gérer tout ça ?**
