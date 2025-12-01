-- ================================================================================
-- FONCTION POSTGRESQL POUR RÉCLAMATION ATOMIQUE DE RÉCOMPENSES
-- ================================================================================
-- Cette fonction garantit qu'aucune condition de course (race condition) ne peut
-- se produire lorsque plusieurs utilisateurs réclament des récompenses en même temps.
--
-- Elle utilise des transactions PostgreSQL et des verrous pour s'assurer que :
-- 1. Les points sont vérifiés et déduits de manière atomique
-- 2. Aucun utilisateur ne peut réclamer une récompense avec des points insuffisants
-- 3. Les opérations simultanées ne causent pas de données incohérentes
-- ================================================================================

CREATE OR REPLACE FUNCTION claim_reward_atomic(
    p_client_id UUID,
    p_magasin_id UUID,
    p_reward_id UUID,
    p_points_required INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_current_points INTEGER;
    v_new_points INTEGER;
    v_affected_rows INTEGER;
BEGIN
    -- ✅ ÉTAPE 1 : Verrouiller la ligne du client pour éviter les race conditions
    -- FOR UPDATE verrouille la ligne jusqu'à la fin de la transaction
    SELECT cumulpoint INTO v_current_points
    FROM clientmagasin
    WHERE client_id = p_client_id 
      AND magasin_id = p_magasin_id
    FOR UPDATE;
    
    -- ✅ ÉTAPE 2 : Vérifier si le client existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'client_not_found: Client non trouvé pour ce magasin';
    END IF;
    
    -- ✅ ÉTAPE 3 : Vérifier que le client a suffisamment de points
    IF v_current_points < p_points_required THEN
        RAISE EXCEPTION 'insufficient_points: Points insuffisants (requis: %, disponible: %)', 
            p_points_required, v_current_points;
    END IF;
    
    -- ✅ ÉTAPE 4 : Calculer les nouveaux points
    v_new_points := v_current_points - p_points_required;
    
    -- ✅ ÉTAPE 5 : Mettre à jour les points du client de manière atomique
    UPDATE clientmagasin
    SET cumulpoint = v_new_points
    WHERE client_id = p_client_id 
      AND magasin_id = p_magasin_id;
    
    GET DIAGNOSTICS v_affected_rows = ROW_COUNT;
    
    IF v_affected_rows = 0 THEN
        RAISE EXCEPTION 'update_failed: Échec de la mise à jour des points';
    END IF;
    
    -- ✅ ÉTAPE 6 : Enregistrer la réclamation dans la table reward_claims
    INSERT INTO reward_claims (
        client_id,
        reward_id,
        points_used,
        claimed_at,
        status
    ) VALUES (
        p_client_id,
        p_reward_id,
        p_points_required,
        NOW(),
        'claimed'
    );
    
    -- ✅ ÉTAPE 7 : Retourner le succès
    RETURN TRUE;
    
EXCEPTION
    WHEN OTHERS THEN
        -- En cas d'erreur, la transaction est automatiquement annulée (rollback)
        RAISE;
END;
$$;

-- ================================================================================
-- COMMENTAIRES ET PERMISSIONS
-- ================================================================================
COMMENT ON FUNCTION claim_reward_atomic IS 
'Fonction atomique pour réclamer une récompense. Garantit qu''aucune race condition 
ne peut se produire lors de réclamations simultanées. Utilise FOR UPDATE pour 
verrouiller la ligne pendant la transaction.';

-- ✅ Accorder les permissions nécessaires
-- Remplacez 'anon', 'authenticated' par les rôles appropriés de votre projet
GRANT EXECUTE ON FUNCTION claim_reward_atomic TO authenticated;
GRANT EXECUTE ON FUNCTION claim_reward_atomic TO anon;
