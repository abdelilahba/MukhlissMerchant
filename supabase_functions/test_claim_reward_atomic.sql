-- ================================================================================
-- SCRIPT DE VÉRIFICATION DE LA FONCTION claim_reward_atomic
-- ================================================================================
-- Utilisez ce script dans l'éditeur SQL de Supabase pour vérifier que la fonction
-- a été correctement déployée et qu'elle fonctionne comme prévu.
-- ================================================================================

-- ==============================================================================
-- ÉTAPE 1 : Vérifier que la fonction existe
-- ==============================================================================
SELECT 
    p.proname as function_name,
    pg_catalog.pg_get_function_arguments(p.oid) as arguments,
    pg_catalog.pg_get_function_result(p.oid) as return_type,
    l.lanname as language
FROM pg_proc p
LEFT JOIN pg_language l ON p.prolang = l.oid
WHERE p.proname = 'claim_reward_atomic';

-- ✅ Résultat attendu : Une ligne avec function_name = 'claim_reward_atomic'
-- Si aucune ligne n'apparaît, la fonction n'a pas été créée


-- ==============================================================================
-- ÉTAPE 2 : Vérifier les données de test (optionnel)
-- ==============================================================================
-- Afficher un client de test et ses points
SELECT 
    cm.client_id,
    cm.magasin_id,
    cm.cumulpoint as points_actuels,
    c.nom,
    c.prenom
FROM clientmagasin cm
JOIN clients c ON c.id = cm.client_id
LIMIT 1;

-- Afficher une récompense de test
SELECT 
    id as reward_id,
    name as nom_recompense,
    points_required as points_requis,
    magasin_id
FROM rewards
LIMIT 1;


-- ==============================================================================
-- ÉTAPE 3 : Test de la fonction (À ADAPTER avec de vraies valeurs)
-- ==============================================================================
-- ⚠️  IMPORTANT : Remplacez 'CLIENT_UUID', 'MAGASIN_UUID' et 'REWARD_UUID' 
--    par de vraies valeurs de votre base de données
--
-- Exemple de test :
/*
DO $$
DECLARE
    v_client_id UUID := 'REMPLACER_PAR_VRAI_CLIENT_ID';
    v_magasin_id UUID := 'REMPLACER_PAR_VRAI_MAGASIN_ID';
    v_reward_id UUID := 'REMPLACER_PAR_VRAI_REWARD_ID';
    v_points_required INTEGER := 50;  -- Ajustez selon la récompense
    v_result BOOLEAN;
BEGIN
    -- Afficher les points AVANT
    RAISE NOTICE 'Points avant: %', (
        SELECT cumulpoint 
        FROM clientmagasin 
        WHERE client_id = v_client_id AND magasin_id = v_magasin_id
    );
    
    -- Tester la fonction
    v_result := claim_reward_atomic(
        v_client_id,
        v_magasin_id,
        v_reward_id,
        v_points_required
    );
    
    RAISE NOTICE 'Résultat: %', v_result;
    
    -- Afficher les points APRÈS
    RAISE NOTICE 'Points après: %', (
        SELECT cumulpoint 
        FROM clientmagasin 
        WHERE client_id = v_client_id AND magasin_id = v_magasin_id
    );
END $$;
*/


-- ==============================================================================
-- ÉTAPE 4 : Vérifier les réclamations enregistrées
-- ==============================================================================
SELECT 
    rc.claimed_at,
    rc.points_used,
    rc.status,
    r.name as reward_name,
    c.nom || ' ' || c.prenom as client_name
FROM reward_claims rc
JOIN rewards r ON r.id = rc.reward_id
JOIN clients c ON c.id = rc.client_id
ORDER BY rc.claimed_at DESC
LIMIT 10;

-- ✅ Après avoir testé avec l'application, vous devriez voir vos réclamations ici


-- ==============================================================================
-- ÉTAPE 5 : Test de concurrence (Avancé)
-- ==============================================================================
-- Ce test vérifie que la fonction empêche les race conditions
/*
-- Exécutez ce script dans 2 fenêtres SQL différentes EN MÊME TEMPS

BEGIN;
SELECT claim_reward_atomic(
    'CLIENT_UUID'::UUID,
    'MAGASIN_UUID'::UUID,
    'REWARD_UUID'::UUID,
    50
);
-- Attendez quelques secondes avant de continuer
COMMIT;

-- ✅ Une seule des deux transactions devrait réussir
-- ❌ L'autre devrait échouer avec "insufficient_points"
*/


-- ==============================================================================
-- ÉTAPE 6 : Nettoyage (si besoin de réinitialiser)
-- ==============================================================================
/*
-- ⚠️  ATTENTION : Ceci supprime toutes les réclamations de test
-- Décommentez seulement si nécessaire

DELETE FROM reward_claims 
WHERE claimed_at > NOW() - INTERVAL '1 hour';  -- Dernière heure seulement

-- Pour restaurer les points d'un client :
UPDATE clientmagasin
SET cumulpoint = 1000  -- Ajustez la valeur
WHERE client_id = 'CLIENT_UUID' AND magasin_id = 'MAGASIN_UUID';
*/


-- ==============================================================================
-- RÉSUMÉ DES VÉRIFICATIONS
-- ==============================================================================
/*
✅ Checklist :
   [ ] La fonction claim_reward_atomic existe (ÉTAPE 1)
   [ ] Des données de test sont disponibles (ÉTAPE 2)
   [ ] La fonction peut être appelée sans erreur (ÉTAPE 3)
   [ ] Les réclamations sont enregistrées dans reward_claims (ÉTAPE 4)
   [ ] Les points sont correctement déduits
   [ ] Les race conditions sont impossibles (ÉTAPE 5)

Si toutes les vérifications passent, votre fonction est prête ! 🎉
*/
