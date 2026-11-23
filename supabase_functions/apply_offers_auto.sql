-- ================================================================================
-- FONCTION POSTGRESQL : APPLICATION AUTOMATIQUE DES OFFRES LORS DE L'AJOUT DE SOLDE
-- ================================================================================
-- Cette fonction :
-- 1. Ajoute le montant au solde du client pour le magasin donné.
-- 2. Recherche si une offre active correspond strictement (montant >= min_amount).
-- 3. Si le montant est inférieur au min_amount de l'offre (ex: 25 DH < 32 DH),
--    AUCUN point n'est attribué (0 point).
-- 4. Si le montant atteint ou dépasse le min_amount (ex: >= 32 DH),
--    les points_given de la meilleure offre éligible sont crédités.
-- 5. Retourne l'enregistrement clientmagasin mis à jour.
-- ================================================================================

CREATE OR REPLACE FUNCTION apply_offers_auto(
    p_client_id UUID,
    p_magasin_id UUID,
    p_montant NUMERIC
)
RETURNS TABLE (
    id BIGINT,
    client_id UUID,
    magasin_id UUID,
    solde NUMERIC,
    cumulpoint NUMERIC,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_points_to_add NUMERIC := 0;
    v_record RECORD;
BEGIN
    -- 1. Validation du montant
    IF p_montant <= 0 THEN
        RAISE EXCEPTION 'Le montant doit être supérieur à 0';
    END IF;

    -- 2. Recherche de la meilleure offre active éligible
    -- Condition stricte : p_montant >= min_amount (min_amount <= p_montant)
    SELECT points_given
    INTO v_points_to_add
    FROM offers
    WHERE offers.magasin_id = p_magasin_id
      AND offers.is_active = true
      AND offers.min_amount <= p_montant
    ORDER BY offers.min_amount DESC, offers.points_given DESC
    LIMIT 1;

    -- Si aucune offre n'est éligible (ex: 25 DH < 32 DH), 0 point attribué !
    IF v_points_to_add IS NULL THEN
        v_points_to_add := 0;
    END IF;

    -- 3. Mise à jour ou insertion atomique dans clientmagasin
    SELECT * INTO v_record
    FROM clientmagasin cm
    WHERE cm.client_id = p_client_id 
      AND cm.magasin_id = p_magasin_id
    FOR UPDATE;

    IF FOUND THEN
        UPDATE clientmagasin cm
        SET solde = COALESCE(cm.solde, 0) + p_montant,
            cumulpoint = COALESCE(cm.cumulpoint, 0) + v_points_to_add
        WHERE cm.id = v_record.id;
    ELSE
        INSERT INTO clientmagasin (client_id, magasin_id, solde, cumulpoint)
        VALUES (p_client_id, p_magasin_id, p_montant, v_points_to_add);
    END IF;

    -- 4. Retourner l'enregistrement à jour
    RETURN QUERY
    SELECT cm.id, cm.client_id, cm.magasin_id, cm.solde, cm.cumulpoint, cm.created_at
    FROM clientmagasin cm
    WHERE cm.client_id = p_client_id 
      AND cm.magasin_id = p_magasin_id;
END;
$$;
