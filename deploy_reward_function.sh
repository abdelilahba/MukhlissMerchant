#!/bin/bash

# ==============================================================================
# Script de déploiement de la fonction claim_reward_atomic sur Supabase
# ==============================================================================
# Ce script facilite le déploiement de la fonction PostgreSQL qui résout
# le problème de concurrence lors de la réclamation de récompenses.
#
# Usage:
#   chmod +x deploy_reward_function.sh
#   ./deploy_reward_function.sh
# ==============================================================================

set -e  # Arrêter en cas d'erreur

echo "🚀 Déploiement de la fonction claim_reward_atomic"
echo "=================================================="
echo ""

# Vérifier que le fichier SQL existe
if [ ! -f "supabase_functions/claim_reward_atomic.sql" ]; then
    echo "❌ Erreur : Le fichier claim_reward_atomic.sql est introuvable"
    echo "   Assurez-vous d'être dans le répertoire racine du projet"
    exit 1
fi

echo "✅ Fichier SQL trouvé"
echo ""

# Vérifier si le CLI Supabase est installé
if ! command -v supabase &> /dev/null; then
    echo "⚠️  Le CLI Supabase n'est pas installé"
    echo ""
    echo "Options de déploiement :"
    echo ""
    echo "Option 1 : Installer le CLI Supabase (Recommandé)"
    echo "   macOS:   brew install supabase/tap/supabase"
    echo "   Windows: scoop bucket add supabase https://github.com/supabase/scoop-bucket.git"
    echo "            scoop install supabase"
    echo "   Linux:   https://supabase.com/docs/guides/cli/getting-started"
    echo ""
    echo "Option 2 : Déploiement manuel via l'interface Supabase"
    echo "   1. Allez sur https://supabase.com"
    echo "   2. Ouvrez votre projet"
    echo "   3. Cliquez sur 'SQL Editor'"
    echo "   4. Copiez-collez le contenu de supabase_functions/claim_reward_atomic.sql"
    echo "   5. Cliquez sur 'Run'"
    echo ""
    exit 1
fi

echo "✅ CLI Supabase installé"
echo ""

# Vérifier si le projet est lié
if [ ! -f ".supabase/config.toml" ]; then
    echo "⚠️  Projet Supabase non lié"
    echo ""
    echo "Pour lier votre projet :"
    echo "   supabase link --project-ref VOTRE_PROJECT_REF"
    echo ""
    echo "Pour trouver votre PROJECT_REF :"
    echo "   1. Allez sur https://supabase.com"
    echo "   2. Ouvrez votre projet"
    echo "   3. Allez dans Settings > General"
    echo "   4. Copiez le 'Reference ID'"
    echo ""
    exit 1
fi

echo "✅ Projet Supabase lié"
echo ""

# Demander confirmation
echo "⚠️  Cette opération va créer/remplacer la fonction claim_reward_atomic"
echo "   dans votre base de données Supabase."
echo ""
read -p "Voulez-vous continuer ? (o/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Oo]$ ]]; then
    echo "❌ Déploiement annulé"
    exit 1
fi

echo ""
echo "📦 Déploiement en cours..."
echo ""

# Déployer la fonction
if supabase db push --include-all supabase_functions/claim_reward_atomic.sql; then
    echo ""
    echo "✅ Déploiement réussi !"
    echo ""
    echo "La fonction claim_reward_atomic est maintenant disponible dans votre base de données."
    echo ""
    echo "Prochaines étapes :"
    echo "   1. Testez la fonction avec votre application Flutter"
    echo "   2. Vérifiez les logs pour confirmer le bon fonctionnement"
    echo "   3. Consultez CORRECTION_RECOMPENSES.md pour plus d'informations"
    echo ""
else
    echo ""
    echo "❌ Erreur lors du déploiement"
    echo ""
    echo "Solutions possibles :"
    echo "   1. Vérifiez vos credentials Supabase"
    echo "   2. Assurez-vous d'avoir les permissions nécessaires"
    echo "   3. Utilisez le déploiement manuel via l'interface web"
    echo ""
    exit 1
fi
