-- ================================================================================
-- EXEMPLES SQL PRATIQUES - Système d'Abonnement
-- ================================================================================
-- Copiez-collez ces requêtes dans Supabase SQL Editor
-- Remplacez les UUID par vos vraies valeurs
-- ================================================================================

-- ================================================================================
-- 1. ACTIVATION D'UN NOUVEAU MAGASIN
-- ================================================================================

-- Exemple 1 : Abonnement mensuel de 500 DH
SELECT activate_magasin(
    '00000000-0000-0000-0000-000000000000'::UUID,  -- ← Remplacez par l'UUID réel du magasin
    CURRENT_DATE + INTERVAL '1 month',
    'mensuel',
    500.00,
    NULL  -- Ou votre UUID admin
);

-- Exemple 2 : Abonnement annuel de 5000 DH
SELECT activate_magasin(
    '00000000-0000-0000-0000-000000000000'::UUID,
    CURRENT_DATE + INTERVAL '1 year',
    'annuel',
    5000.00,
    NULL
);

-- Exemple 3 : Période d'essai gratuite de 15 jours
SELECT activate_magasin(
    '00000000-0000-0000-0000-000000000000'::UUID,
    CURRENT_DATE + INTERVAL '15 days',
    'essai_gratuit',
    0.00,
    NULL
);

-- ================================================================================
-- 2. ENREGISTREMENT DE PAIEMENTS
-- ================================================================================

-- Exemple 1 : Paiement en espèces pour 1 mois
SELECT record_payment_and_renew(
    '00000000-0000-0000-0000-000000000000'::UUID,
    500.00,
    'espèces',
    1,  -- 1 mois
    'RECU-2024-12-001',
    'Payé en espèces le 01/12/2024',
    NULL
);

-- Exemple 2 : Virement bancaire pour 3 mois
SELECT record_payment_and_renew(
    '00000000-0000-0000-0000-000000000000'::UUID,
    1400.00,
    'virement_bancaire',
    3,  -- 3 mois
    'VIRT-2024-12-001',
    'Virement reçu le 01/12/2024 - Réf: ABC123',
    NULL
);

-- Exemple 3 : Paiement annuel avec réduction
SELECT record_payment_and_renew(
    '00000000-0000-0000-0000-000000000000'::UUID,
    5000.00,
    'virement_bancaire',
    12,  -- 12 mois
    'VIRT-2024-12-002',
    'Abonnement annuel avec 15% de réduction',
    NULL
);

-- ================================================================================
-- 3. GESTION DES ACCÈS
-- ================================================================================

-- Suspendre un magasin (impayé)
SELECT suspend_magasin(
    '00000000-0000-0000-0000-000000000000'::UUID,
    'Facture impayée depuis 30 jours'
);

-- Réactiver un magasin
SELECT reactivate_magasin(
    '00000000-0000-0000-0000-000000000000'::UUID
);

-- Vérifier l'accès (comme le fait l'app)
SELECT * FROM check_app_access(
    '00000000-0000-0000-0000-000000000000'::UUID
);

-- ================================================================================
-- 4. CONSULTATIONS ET RAPPORTS
-- ================================================================================

-- Liste de TOUS les magasins avec leur statut
SELECT 
    magasin_name,
    status,
    is_active,
    end_date,
    days_remaining,
    alert_status,
    plan_type,
    last_payment_amount
FROM v_magasins_subscription_status
ORDER BY end_date ASC;

-- Magasins qui expirent dans les 7 prochains jours
SELECT 
    magasin_name,
    end_date,
    days_remaining,
    contact_phone
FROM v_magasins_subscription_status
WHERE days_remaining IS NOT NULL
  AND days_remaining <= 7
  AND days_remaining >= 0
ORDER BY days_remaining ASC;

-- Magasins déjà expirés
SELECT 
    magasin_name,
    end_date,
    days_remaining,
    last_payment_date,
    contact_phone
FROM v_magasins_subscription_status
WHERE alert_status = 'Expiré'
ORDER BY end_date DESC;

-- Magasins suspendus
SELECT 
    m.nom as magasin_name,
    ms.suspension_reason,
    ms.end_date,
    ms.contact_phone
FROM magasin_subscriptions ms
JOIN magasins m ON m.id = ms.magasin_id
WHERE ms.status = 'suspended';

-- ================================================================================
-- 5. HISTORIQUES
-- ================================================================================

-- Historique des paiements d'un magasin spécifique
SELECT 
    payment_date,
    amount,
    payment_method,
    payment_reference,
    period_start,
    period_end,
    notes
FROM subscription_payments
WHERE magasin_id = '00000000-0000-0000-0000-000000000000'::UUID
ORDER BY payment_date DESC;

-- Total des revenus par mois
SELECT 
    DATE_TRUNC('month', payment_date) as mois,
    COUNT(*) as nombre_paiements,
    SUM(amount) as total_revenus
FROM subscription_payments
GROUP BY DATE_TRUNC('month', payment_date)
ORDER BY mois DESC;

-- Total des revenus par méthode de paiement
SELECT 
    payment_method,
    COUNT(*) as nombre_paiements,
    SUM(amount) as total
FROM subscription_payments
GROUP BY payment_method
ORDER BY total DESC;

-- ================================================================================
-- 6. LOGS D'ACCÈS
-- ================================================================================

-- Derniers accès d'un magasin
SELECT 
    created_at,
    event_type,
    user_email,
    denial_reason
FROM app_access_logs
WHERE magasin_id = '00000000-0000-0000-0000-000000000000'::UUID
ORDER BY created_at DESC
LIMIT 50;

-- Tentatives d'accès refusées aujourd'hui
SELECT 
    m.nom as magasin_name,
    l.event_type,
    l.denial_reason,
    l.created_at
FROM app_access_logs l
JOIN magasins m ON m.id = l.magasin_id
WHERE l.event_type = 'access_denied'
  AND l.created_at >= CURRENT_DATE
ORDER BY l.created_at DESC;

-- Statistiques d'utilisation (apps ouvertes par jour)
SELECT 
    DATE(created_at) as date,
    COUNT(DISTINCT magasin_id) as magasins_actifs,
    COUNT(*) as total_ouvertures
FROM app_access_logs
WHERE event_type = 'app_opened'
  AND created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- ================================================================================
-- 7. RECHERCHES UTILES
-- ================================================================================

-- Trouver un magasin par nom
SELECT 
    id,
    nom,
    adresse,
    ville,
    telephone
FROM magasins
WHERE nom ILIKE '%recherche%'  -- ← Remplacez 'recherche' par le nom
ORDER BY nom;

-- Voir l'abonnement d'un magasin spécifique
SELECT 
    ms.status,
    ms.is_active,
    ms.start_date,
    ms.end_date,
    ms.plan_type,
    ms.plan_price,
    ms.last_payment_date,
    ms.last_payment_amount,
    ms.payment_method,
    ms.contact_phone,
    ms.admin_notes
FROM magasin_subscriptions ms
WHERE ms.magasin_id = '00000000-0000-0000-0000-000000000000'::UUID;

-- ================================================================================
-- 8. MODIFICATIONS EN MASSE
-- ================================================================================

-- Prolonger TOUS les abonnements actifs de 1 mois (bonus)
UPDATE magasin_subscriptions
SET 
    end_date = end_date + INTERVAL '1 month',
    updated_at = NOW(),
    admin_notes = COALESCE(admin_notes, '') || ' | Bonus: +1 mois offert le ' || CURRENT_DATE
WHERE status = 'active'
  AND is_active = true;

-- Passer tous les essais gratuits en abonnements payants
UPDATE magasin_subscriptions
SET 
    plan_type = 'mensuel',
    plan_price = 500.00,
    updated_at = NOW()
WHERE plan_type = 'essai_gratuit';

-- ================================================================================
-- 9. NETTOYAGE ET MAINTENANCE
-- ================================================================================

-- Supprimer les logs d'accès de plus de 90 jours
DELETE FROM app_access_logs
WHERE created_at < CURRENT_DATE - INTERVAL '90 days';

-- Mettre à jour les statuts expirés (normalement automatique)
UPDATE magasin_subscriptions
SET 
    status = 'expired',
    is_active = false,
    updated_at = NOW()
WHERE end_date < CURRENT_DATE
  AND status != 'expired';

-- ================================================================================
-- 10. STATISTIQUES BUSINESS
-- ================================================================================

-- Nombre de magasins par statut
SELECT 
    status,
    COUNT(*) as nombre
FROM magasin_subscriptions
GROUP BY status
ORDER BY nombre DESC;

-- Revenus prévus ce mois (si tous renouvellent)
SELECT 
    SUM(plan_price) as revenus_prevus_mensuels
FROM magasin_subscriptions
WHERE status = 'active'
  AND plan_type = 'mensuel';

-- Taux de renouvellement (dernier mois)
SELECT 
    COUNT(DISTINCT magasin_id) as renouvellements
FROM subscription_payments
WHERE payment_date >= CURRENT_DATE - INTERVAL '1 month';

-- Magasins les plus rentables
SELECT 
    m.nom as magasin_name,
    COUNT(sp.id) as nombre_paiements,
    SUM(sp.amount) as total_paye
FROM subscription_payments sp
JOIN magasins m ON m.id = sp.magasin_id
GROUP BY m.id, m.nom
ORDER BY total_paye DESC
LIMIT 10;

-- ================================================================================
-- NOTES IMPORTANTES
-- ================================================================================

-- 1. Remplacez TOUJOURS les UUID d'exemple par les vrais UUID
-- 2. Testez d'abord sur UN magasin avant de faire des modifications en masse
-- 3. Les dates sont au format PostgreSQL (CURRENT_DATE, INTERVAL, etc.)
-- 4. Tous les montants sont en DH (ou votre devise)
-- 5. Les fonctions retournent l'UUID de l'enregistrement créé/modifié

-- ================================================================================
-- POUR RÉCUPÉRER UN UUID
-- ================================================================================

-- Si vous connaissez le nom du magasin :
SELECT id FROM magasins WHERE nom = 'Nom Exact Du Magasin';

-- Si vous connaissez l'email de l'utilisateur :
SELECT id FROM magasins WHERE id IN (
    SELECT id FROM auth.users WHERE email = 'email@example.com'
);
