-- ============================================
-- ANALYSE DES KPI - DATALENS
-- Synthèse des indicateurs clefs de performance
-- ============================================

USE DataLens;
GO

-- ============================================
-- 1. MRR (Monthly Recurring Revenue)
-- ============================================
-- Revenu mensuel récurrent provenant des abonnements actifs

SELECT 
    SUM(prix_mensuel) AS mrr_total
FROM ABONNEMENTS
WHERE date_fin IS NULL;

GO

-- Détail par entreprise
SELECT 
    e.nom_entreprise,
    a.prix_mensuel AS mrr,
    p.nom_plan AS plan,
    CASE 
        WHEN a.date_fin IS NULL THEN 'Actif'
        ELSE 'Churné'
    END AS statut
FROM ABONNEMENTS a
INNER JOIN ENTREPRISES e ON a.id_entreprise = e.id_entreprise
INNER JOIN PLANS p ON a.id_plan = p.id_plan
WHERE a.date_fin IS NULL
ORDER BY a.prix_mensuel DESC;

GO

-- ============================================
-- 2. CHURN RATE
-- ============================================
-- Pourcentage d'entreprises qui ont quitté la plateforme

SELECT 
    COUNT(DISTINCT CASE WHEN a.date_fin IS NOT NULL THEN a.id_entreprise END) AS entreprises_churnees,
    COUNT(DISTINCT a.id_entreprise) AS total_entreprises_historique,
    CAST(
        COUNT(DISTINCT CASE WHEN a.date_fin IS NOT NULL THEN a.id_entreprise END) * 100.0 
        / COUNT(DISTINCT a.id_entreprise) 
        AS DECIMAL(5, 2)
    ) AS churn_rate_percent
FROM ABONNEMENTS a;

GO

-- Détail des clients churés
SELECT 
    e.nom_entreprise,
    MAX(a.date_fin) AS date_churn,
    MAX(a.prix_mensuel) AS mrr_avant_churn
FROM ABONNEMENTS a
INNER JOIN ENTREPRISES e ON a.id_entreprise = e.id_entreprise
WHERE a.date_fin IS NOT NULL
GROUP BY e.id_entreprise, e.nom_entreprise
ORDER BY a.date_fin DESC;

GO

-- ============================================
-- 3. ENGAGEMENT
-- ============================================
-- Intensité d'utilisation : requêtes par utilisateur par mois

SELECT 
    e.nom_entreprise,
    SUM(ac.nb_requetes) AS total_requetes,
    COUNT(DISTINCT u.id_utilisateur) AS nombre_utilisateurs,
    CAST(SUM(ac.nb_requetes) * 1.0 / COUNT(DISTINCT u.id_utilisateur) AS DECIMAL(10, 2)) AS requetes_par_utilisateur,
    CASE 
        WHEN EXISTS (SELECT 1 FROM ABONNEMENTS WHERE id_entreprise = e.id_entreprise AND date_fin IS NULL) THEN 'Actif'
        ELSE 'Churné'
    END AS statut
FROM ACTIVITE ac
INNER JOIN UTILISATEURS u ON ac.id_utilisateur = u.id_utilisateur
INNER JOIN ENTREPRISES e ON u.id_entreprise = e.id_entreprise
GROUP BY e.id_entreprise, e.nom_entreprise
ORDER BY total_requetes DESC;

GO

-- Détail par utilisateur
SELECT 
    e.nom_entreprise,
    u.nom_utilisateur,
    u.role_actuel,
    SUM(ac.nb_requetes) AS total_requetes,
    ROW_NUMBER() OVER (PARTITION BY e.id_entreprise ORDER BY SUM(ac.nb_requetes) DESC) AS rang_utilisateur
FROM ACTIVITE ac
INNER JOIN UTILISATEURS u ON ac.id_utilisateur = u.id_utilisateur
INNER JOIN ENTREPRISES e ON u.id_entreprise = e.id_entreprise
GROUP BY e.id_entreprise, e.nom_entreprise, u.id_utilisateur, u.nom_utilisateur, u.role_actuel
ORDER BY e.nom_entreprise, rang_utilisateur;

GO

-- ============================================
-- 4. SUPPORT ET CHURN
-- ============================================
-- Analyse du lien entre tickets support et churn

SELECT 
    e.nom_entreprise,
    COUNT(DISTINCT ts.id_ticket) AS nombre_tickets,
    COUNT(DISTINCT CASE WHEN ts.statut = 'Ouvert' THEN ts.id_ticket END) AS tickets_ouverts,
    COUNT(DISTINCT CASE WHEN ts.statut = 'Résolu' THEN ts.id_ticket END) AS tickets_resolus,
    CASE 
        WHEN EXISTS (SELECT 1 FROM ABONNEMENTS WHERE id_entreprise = e.id_entreprise AND date_fin IS NULL) THEN 'Actif'
        ELSE 'Churné'
    END AS statut_abonnement
FROM ENTREPRISES e
LEFT JOIN TICKETS_SUPPORT ts ON e.id_entreprise = ts.id_entreprise
GROUP BY e.id_entreprise, e.nom_entreprise
ORDER BY nombre_tickets DESC;

GO

-- ============================================
-- 5. TEMPS DE RÉSOLUTION (SUPPORT)
-- ============================================
-- Temps moyen entre création et résolution d'un ticket

SELECT 
    e.nom_entreprise,
    COUNT(CASE WHEN ts.date_resolution IS NOT NULL THEN 1 END) AS tickets_resolus,
    AVG(CAST(DATEDIFF(HOUR, ts.date_creation, ts.date_resolution) AS FLOAT)) AS temps_resolution_heures_moyen,
    MIN(DATEDIFF(HOUR, ts.date_creation, ts.date_resolution)) AS temps_resolution_min_heures,
    MAX(DATEDIFF(HOUR, ts.date_creation, ts.date_resolution)) AS temps_resolution_max_heures
FROM TICKETS_SUPPORT ts
INNER JOIN ENTREPRISES e ON ts.id_entreprise = e.id_entreprise
WHERE ts.date_resolution IS NOT NULL
GROUP BY e.id_entreprise, e.nom_entreprise;

GO

-- ============================================
-- 6. SYNTHÈSE COMPLÈTE DES KPI
-- ============================================
-- Vue d'ensemble par entreprise

SELECT 
    e.nom_entreprise,
    (SELECT SUM(prix_mensuel) FROM ABONNEMENTS WHERE id_entreprise = e.id_entreprise AND date_fin IS NULL) AS mrr,
    (SELECT COUNT(DISTINCT id_utilisateur) FROM UTILISATEURS WHERE id_entreprise = e.id_entreprise AND date_depart IS NULL) AS utilisateurs_actifs,
    (SELECT SUM(nb_requetes) FROM ACTIVITE ac INNER JOIN UTILISATEURS u ON ac.id_utilisateur = u.id_utilisateur WHERE u.id_entreprise = e.id_entreprise) AS total_requetes,
    COUNT(DISTINCT ts.id_ticket) AS nombre_tickets,
    COUNT(DISTINCT CASE WHEN ts.statut = 'Ouvert' THEN ts.id_ticket END) AS tickets_ouverts,
    CASE 
        WHEN EXISTS (SELECT 1 FROM ABONNEMENTS WHERE id_entreprise = e.id_entreprise AND date_fin IS NULL) THEN 'Actif'
        ELSE 'Churné'
    END AS statut
FROM ENTREPRISES e
LEFT JOIN TICKETS_SUPPORT ts ON e.id_entreprise = ts.id_entreprise
GROUP BY e.id_entreprise, e.nom_entreprise
ORDER BY mrr DESC;

GO

-- ============================================
-- 7. MÉTRIQUES D'ACTIVITÉ
-- ============================================
-- Statistiques d'utilisation de la plateforme

SELECT 
    e.nom_entreprise,
    COUNT(DISTINCT ac.date_activite) AS jours_avec_activite,
    SUM(ac.nb_connexions) AS total_connexions,
    SUM(ac.nb_requetes) AS total_requetes,
    SUM(ac.nb_tableaux_bord) AS total_tableaux_bord,
    SUM(ac.nb_fonctionnalites_utilisees) AS total_fonctionnalites_utilisees
FROM ACTIVITE ac
INNER JOIN UTILISATEURS u ON ac.id_utilisateur = u.id_utilisateur
INNER JOIN ENTREPRISES e ON u.id_entreprise = e.id_entreprise
GROUP BY e.id_entreprise, e.nom_entreprise
ORDER BY total_requetes DESC;

GO

-- ============================================
-- 8. REVENU FACTURÉ
-- ============================================
-- Analyse des factures et du revenu

SELECT 
    e.nom_entreprise,
    COUNT(f.id_facture) AS nombre_factures,
    SUM(f.montant_total) AS revenu_total_facture,
    COUNT(CASE WHEN f.statut = 'Payée' THEN 1 END) AS factures_payees,
    COUNT(CASE WHEN f.statut = 'En attente' THEN 1 END) AS factures_en_attente,
    CAST(SUM(CASE WHEN f.statut = 'Payée' THEN f.montant_total ELSE 0 END) * 100.0 / SUM(f.montant_total) AS DECIMAL(5, 2)) AS taux_paiement_percent
FROM FACTURES f
INNER JOIN ENTREPRISES e ON f.id_entreprise = e.id_entreprise
GROUP BY e.id_entreprise, e.nom_entreprise
ORDER BY revenu_total_facture DESC;

GO

-- ============================================
-- 9. SIGNAUX D'ALERTE
-- ============================================
-- Clients à risque identifiés

SELECT 
    e.nom_entreprise,
    COUNT(DISTINCT CASE WHEN ts.statut = 'Ouvert' THEN ts.id_ticket END) AS tickets_ouverts_actuels,
    (SELECT COUNT(DISTINCT id_utilisateur) FROM UTILISATEURS WHERE id_entreprise = e.id_entreprise AND date_depart IS NULL) AS utilisateurs_actifs,
    (SELECT SUM(nb_requetes) FROM ACTIVITE ac INNER JOIN UTILISATEURS u ON ac.id_utilisateur = u.id_utilisateur WHERE u.id_entreprise = e.id_entreprise) AS total_requetes,
    MAX(ts.date_creation) AS dernier_ticket,
    CASE 
        WHEN COUNT(DISTINCT CASE WHEN ts.statut = 'Ouvert' THEN ts.id_ticket END) >= 2 THEN '🚨 CRITIQUE : 2+ tickets ouverts'
        WHEN COUNT(DISTINCT CASE WHEN ts.statut = 'Ouvert' THEN ts.id_ticket END) = 1 AND (SELECT SUM(nb_requetes) FROM ACTIVITE ac INNER JOIN UTILISATEURS u ON ac.id_utilisateur = u.id_utilisateur WHERE u.id_entreprise = e.id_entreprise) < 10 THEN '🟡 ALERTE : faible engagement + ticket ouvert'
        ELSE '🟢 OK'
    END AS signal_alerte
FROM ENTREPRISES e
LEFT JOIN TICKETS_SUPPORT ts ON e.id_entreprise = ts.id_entreprise
GROUP BY e.id_entreprise, e.nom_entreprise
ORDER BY tickets_ouverts_actuels DESC;

GO

-- ============================================
-- FIN DE L'ANALYSE
-- ============================================