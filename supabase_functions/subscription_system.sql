-- ================================================================================
-- SYSTÈME D'ABONNEMENT MANUEL (Paiements espèces/virement RIB)
-- ================================================================================
-- Ce système permet de gérer les abonnements des magasins de manière manuelle.
-- Vous activez/désactivez les comptes, enregistrez les paiements manuellement.
-- L'app vérifie l'accès en temps réel via Supabase.
-- ================================================================================

-- 1. Table des abonnements des magasins
CREATE TABLE IF NOT EXISTS magasin_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    magasin_id UUID NOT NULL REFERENCES magasins(id) ON DELETE CASCADE,
    
    -- Informations du magasin (pour faciliter la gestion)
    magasin_name VARCHAR(255),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),
    
    -- Statut d'accès
    is_active BOOLEAN DEFAULT true,
    status VARCHAR(20) NOT NULL DEFAULT 'active', 
    -- Valeurs possibles:
    --   'active'    = Abonnement actif, accès OK
    --   'expired'   = Abonnement expiré automatiquement
    --   'suspended' = Suspendu manuellement (impayé, fraude, etc.)
    --   'trial'     = Période d'essai gratuite
    
    -- Dates
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE NOT NULL,
    
    -- Informations paiement manuel
    payment_method VARCHAR(50), -- 'espèces', 'virement_bancaire', 'cheque'
    last_payment_date DATE,
    last_payment_amount DECIMAL(10, 2),
    payment_reference VARCHAR(100), -- Numéro de reçu, référence virement
    
    -- Notes administratives
    admin_notes TEXT,
    suspension_reason TEXT,
    
    -- Plan (pour vos statistiques)
    plan_type VARCHAR(50), -- 'mensuel', 'trimestriel', 'semestriel', 'annuel'
    plan_price DECIMAL(10, 2),
    
    -- Métadonnées
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID,
    
    CONSTRAINT unique_magasin_subscription UNIQUE(magasin_id)
);

-- 2. Table historique des paiements manuels
CREATE TABLE IF NOT EXISTS subscription_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    magasin_id UUID NOT NULL REFERENCES magasins(id) ON DELETE CASCADE,
    subscription_id UUID REFERENCES magasin_subscriptions(id) ON DELETE SET NULL,
    
    -- Détails du paiement
    amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_reference VARCHAR(100),
    
    -- Période couverte par ce paiement
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    
    -- Notes
    notes TEXT,
    
    -- Qui a enregistré ce paiement
    recorded_by UUID,
    recorded_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Table des logs d'accès (pour tracking)
CREATE TABLE IF NOT EXISTS app_access_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    magasin_id UUID NOT NULL REFERENCES magasins(id) ON DELETE CASCADE,
    
    -- Type d'événement
    event_type VARCHAR(50) NOT NULL,
    -- 'app_opened', 'access_granted', 'access_denied', 'login_success', 'login_failed'
    
    -- Détails utilisateur
    user_id UUID,
    user_email VARCHAR(255),
    
    -- Détails appareil
    device_info TEXT,
    app_version VARCHAR(20),
    
    -- Raison si accès refusé
    denial_reason TEXT,
    
    -- Timestamp
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================================================
-- INDEX POUR PERFORMANCE
-- ================================================================================

CREATE INDEX IF NOT EXISTS idx_subscription_magasin 
    ON magasin_subscriptions(magasin_id);
    
CREATE INDEX IF NOT EXISTS idx_subscription_status 
    ON magasin_subscriptions(status, is_active);
    
CREATE INDEX IF NOT EXISTS idx_subscription_end_date 
    ON magasin_subscriptions(end_date);
    
CREATE INDEX IF NOT EXISTS idx_payments_magasin 
    ON subscription_payments(magasin_id, payment_date DESC);
    
CREATE INDEX IF NOT EXISTS idx_access_logs_magasin 
    ON app_access_logs(magasin_id, created_at DESC);
    
CREATE INDEX IF NOT EXISTS idx_access_logs_event 
    ON app_access_logs(event_type, created_at DESC);

-- ================================================================================
-- FONCTION : Vérifier l'accès d'un magasin (appelée par l'app)
-- ================================================================================

CREATE OR REPLACE FUNCTION check_app_access(p_magasin_id UUID)
RETURNS TABLE (
    can_access BOOLEAN,
    status VARCHAR(20),
    message TEXT,
    expires_on DATE,
    days_remaining INTEGER
) AS $$
DECLARE
    v_sub RECORD;
BEGIN
    -- Récupérer l'abonnement du magasin
    SELECT * INTO v_sub
    FROM magasin_subscriptions
    WHERE magasin_id = p_magasin_id;
    
    -- Cas 1: Aucun abonnement trouvé
    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            false,
            'no_subscription'::VARCHAR(20),
            'Aucun abonnement trouvé. Contactez votre fournisseur.'::TEXT,
            NULL::DATE,
            NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Cas 2: Compte désactivé manuellement
    IF NOT v_sub.is_active THEN
        RETURN QUERY SELECT 
            false,
            'inactive'::VARCHAR(20),
            'Compte désactivé. Contactez le support.'::TEXT,
            v_sub.end_date,
            NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Cas 3: Compte suspendu
    IF v_sub.status = 'suspended' THEN
        RETURN QUERY SELECT 
            false,
            'suspended'::VARCHAR(20),
            COALESCE(
                'Compte suspendu : ' || v_sub.suspension_reason,
                'Compte suspendu. Contactez le support.'
            )::TEXT,
            v_sub.end_date,
            NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Cas 4: Abonnement expiré
    IF v_sub.end_date < CURRENT_DATE THEN
        -- Mise à jour automatique du statut
        UPDATE magasin_subscriptions 
        SET status = 'expired', is_active = false, updated_at = NOW()
        WHERE id = v_sub.id;
        
        RETURN QUERY SELECT 
            false,
            'expired'::VARCHAR(20),
            ('Abonnement expiré le ' || to_char(v_sub.end_date, 'DD/MM/YYYY') || '. Veuillez renouveler.')::TEXT,
            v_sub.end_date,
            (v_sub.end_date - CURRENT_DATE)::INTEGER;
        RETURN;
    END IF;
    
    -- Cas 5: Expire bientôt (dans 7 jours)
    IF v_sub.end_date <= CURRENT_DATE + INTERVAL '7 days' THEN
        RETURN QUERY SELECT 
            true,
            'expiring_soon'::VARCHAR(20),
            ('Abonnement expire le ' || to_char(v_sub.end_date, 'DD/MM/YYYY'))::TEXT,
            v_sub.end_date,
            (v_sub.end_date - CURRENT_DATE)::INTEGER;
        RETURN;
    END IF;
    
    -- Cas 6: Tout est OK
    RETURN QUERY SELECT 
        true,
        v_sub.status::VARCHAR(20),
        'Accès autorisé'::TEXT,
        v_sub.end_date,
        (v_sub.end_date - CURRENT_DATE)::INTEGER;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================================
-- FONCTION : Activer un nouveau magasin
-- ================================================================================

CREATE OR REPLACE FUNCTION activate_magasin(
    p_magasin_id UUID,
    p_end_date DATE,
    p_plan_type VARCHAR DEFAULT 'mensuel',
    p_plan_price DECIMAL DEFAULT 0,
    p_admin_user_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_subscription_id UUID;
    v_magasin_name VARCHAR(255);
BEGIN
    -- Récupérer le nom du magasin
    SELECT nom_enseigne INTO v_magasin_name
    FROM magasins
    WHERE id = p_magasin_id;
    
    -- Insérer ou mettre à jour l'abonnement
    INSERT INTO magasin_subscriptions (
        magasin_id,
        magasin_name,
        start_date,
        end_date,
        status,
        is_active,
        plan_type,
        plan_price,
        created_by
    )
    VALUES (
        p_magasin_id,
        v_magasin_name,
        CURRENT_DATE,
        p_end_date,
        'active',
        true,
        p_plan_type,
        p_plan_price,
        p_admin_user_id
    )
    ON CONFLICT (magasin_id) DO UPDATE
    SET 
        end_date = p_end_date,
        status = 'active',
        is_active = true,
        plan_type = p_plan_type,
        plan_price = p_plan_price,
        updated_at = NOW()
    RETURNING id INTO v_subscription_id;
    
    RETURN v_subscription_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================================
-- FONCTION : Suspendre un magasin
-- ================================================================================

CREATE OR REPLACE FUNCTION suspend_magasin(
    p_magasin_id UUID,
    p_reason TEXT DEFAULT 'Non spécifié'
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE magasin_subscriptions
    SET 
        status = 'suspended',
        is_active = false,
        suspension_reason = p_reason,
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
        is_active = true,
        suspension_reason = NULL,
        updated_at = NOW()
    WHERE magasin_id = p_magasin_id
      AND end_date >= CURRENT_DATE;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================================
-- FONCTION : Enregistrer un paiement et prolonger l'abonnement
-- ================================================================================

CREATE OR REPLACE FUNCTION record_payment_and_renew(
    p_magasin_id UUID,
    p_amount DECIMAL,
    p_payment_method VARCHAR,
    p_months INTEGER DEFAULT 1,
    p_payment_reference VARCHAR DEFAULT NULL,
    p_notes TEXT DEFAULT NULL,
    p_admin_user_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_payment_id UUID;
    v_subscription_id UUID;
    v_current_end_date DATE;
    v_new_end_date DATE;
BEGIN
    -- Récupérer l'abonnement
    SELECT id, end_date INTO v_subscription_id, v_current_end_date
    FROM magasin_subscriptions
    WHERE magasin_id = p_magasin_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Aucun abonnement trouvé pour ce magasin';
    END IF;
    
    -- Calculer la nouvelle date de fin
    IF v_current_end_date > CURRENT_DATE THEN
        v_new_end_date := v_current_end_date + (p_months || ' months')::INTERVAL;
    ELSE
        v_new_end_date := CURRENT_DATE + (p_months || ' months')::INTERVAL;
    END IF;
    
    -- Enregistrer le paiement
    INSERT INTO subscription_payments (
        magasin_id,
        subscription_id,
        amount,
        payment_method,
        payment_reference,
        period_start,
        period_end,
        notes,
        recorded_by
    )
    VALUES (
        p_magasin_id,
        v_subscription_id,
        p_amount,
        p_payment_method,
        p_payment_reference,
        GREATEST(v_current_end_date, CURRENT_DATE),
        v_new_end_date,
        p_notes,
        p_admin_user_id
    )
    RETURNING id INTO v_payment_id;
    
    -- Mettre à jour l'abonnement
    UPDATE magasin_subscriptions
    SET 
        end_date = v_new_end_date,
        last_payment_date = CURRENT_DATE,
        last_payment_amount = p_amount,
        payment_method = p_payment_method,
        payment_reference = p_payment_reference,
        status = 'active',
        is_active = true,
        updated_at = NOW()
    WHERE id = v_subscription_id;
    
    RETURN v_payment_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================================
-- TRIGGER : Mise à jour automatique du timestamp
-- ================================================================================

CREATE OR REPLACE FUNCTION update_subscription_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_subscription_timestamp ON magasin_subscriptions;

CREATE TRIGGER trigger_update_subscription_timestamp
    BEFORE UPDATE ON magasin_subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION update_subscription_timestamp();

-- ================================================================================
-- VUE : Liste des magasins avec statut d'abonnement
-- ================================================================================

CREATE OR REPLACE VIEW v_magasins_subscription_status AS
SELECT 
    m.id as magasin_id,
    m.nom_enseigne as magasin_name,
    m.adresse,
    m.email,
    ms.status,
    ms.is_active,
    ms.start_date,
    ms.end_date,
    ms.plan_type,
    ms.plan_price,
    ms.last_payment_date,
    ms.last_payment_amount,
    (ms.end_date - CURRENT_DATE) as days_remaining,
    CASE 
        WHEN ms.end_date < CURRENT_DATE THEN 'Expiré'
        WHEN ms.end_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'Expire bientôt'
        ELSE 'OK'
    END as alert_status
FROM magasins m
LEFT JOIN magasin_subscriptions ms ON m.id = ms.magasin_id
ORDER BY ms.end_date ASC NULLS FIRST;

-- ================================================================================
-- PERMISSIONS
-- ================================================================================

GRANT SELECT ON magasin_subscriptions TO authenticated;
GRANT SELECT ON subscription_payments TO authenticated;
GRANT ALL ON app_access_logs TO authenticated;
GRANT SELECT ON v_magasins_subscription_status TO authenticated;

GRANT EXECUTE ON FUNCTION check_app_access TO authenticated;
GRANT EXECUTE ON FUNCTION activate_magasin TO authenticated;
GRANT EXECUTE ON FUNCTION suspend_magasin TO authenticated;
GRANT EXECUTE ON FUNCTION reactivate_magasin TO authenticated;
GRANT EXECUTE ON FUNCTION record_payment_and_renew TO authenticated;

-- ================================================================================
-- COMMENTAIRES
-- ================================================================================

COMMENT ON TABLE magasin_subscriptions IS 'Abonnements des magasins (gestion manuelle)';
COMMENT ON TABLE subscription_payments IS 'Historique des paiements manuels (espèces/virement)';
COMMENT ON TABLE app_access_logs IS 'Logs d''accès à l''application';

COMMENT ON FUNCTION check_app_access IS 'Vérifie si un magasin peut accéder à l''app (appelée au démarrage)';
COMMENT ON FUNCTION activate_magasin IS 'Active ou prolonge l''abonnement d''un magasin';
COMMENT ON FUNCTION suspend_magasin IS 'Suspend l''accès d''un magasin';
COMMENT ON FUNCTION reactivate_magasin IS 'Réactive un magasin suspendu';
COMMENT ON FUNCTION record_payment_and_renew IS 'Enregistre un paiement et prolonge l''abonnement';
