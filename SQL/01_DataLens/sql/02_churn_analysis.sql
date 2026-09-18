```sql
-- ============================================================
-- DataLens
-- Analyse SQL et KPI
-- ============================================================

-- Sélectionne la base de données DataLens comme base de travail.
USE DataLens;
GO


-- ============================================================
-- 1. EXPLORATION DES DONNÉES
-- ============================================================

-- Affiche toutes les entreprises.
SELECT *
FROM ENTREPRISES;


-- Affiche les entreprises situées en France.
SELECT *
FROM ENTREPRISES
WHERE pays = 'FR';


-- Classe les entreprises de la plus récemment inscrite à la plus ancienne.
SELECT *
FROM ENTREPRISES
ORDER BY date_inscription DESC;


-- Affiche les deux entreprises les plus récemment inscrites.
SELECT TOP 2 *
FROM ENTREPRISES
ORDER BY date_inscription DESC;


-- Affiche la liste des pays présents dans la table ENTREPRISES, sans doublons.
SELECT DISTINCT pays
FROM ENTREPRISES;


-- Affiche les entreprises situées en France ou en Allemagne.
SELECT *
FROM ENTREPRISES
WHERE pays IN ('FR', 'DE');


-- Affiche les plans dont le prix catalogue est compris entre 100 et 1 000 €.
SELECT *
FROM PLANS
WHERE prix_catalogue BETWEEN 100 AND 1000;


-- Affiche les entreprises dont le nom contient le terme « Data ».
SELECT *
FROM ENTREPRISES
WHERE nom_entreprise LIKE '%Data%';


-- ============================================================
-- 2. JOINTURES ET AGRÉGATIONS
-- ============================================================

-- Affiche les informations d'abonnement associées à chaque entreprise.
SELECT
    ENTREPRISES.nom_entreprise,
    ABONNEMENTS.date_debut,
    ABONNEMENTS.date_fin,
    ABONNEMENTS.prix_mensuel
FROM ABONNEMENTS
INNER JOIN ENTREPRISES
    ON ABONNEMENTS.id_entreprise = ENTREPRISES.id_entreprise;


-- Compte le nombre d'abonnements pour chaque entreprise.
-- Le LEFT JOIN conserve également les entreprises sans abonnement.
SELECT
    ENTREPRISES.nom_entreprise,
    COUNT(ABONNEMENTS.id_abonnement) AS nombre_abonnements
FROM ENTREPRISES
LEFT JOIN ABONNEMENTS
    ON ENTREPRISES.id_entreprise = ABONNEMENTS.id_entreprise
GROUP BY
    ENTREPRISES.id_entreprise,
    ENTREPRISES.nom_entreprise;


-- Calcule le revenu mensuel des abonnements actuellement actifs
-- pour chaque entreprise.
SELECT
    ENTREPRISES.nom_entreprise,
    SUM(ABONNEMENTS.prix_mensuel) AS revenu_total_mensuel
FROM ABONNEMENTS
INNER JOIN ENTREPRISES
    ON ABONNEMENTS.id_entreprise = ENTREPRISES.id_entreprise
WHERE ABONNEMENTS.date_fin IS NULL
GROUP BY
    ENTREPRISES.id_entreprise,
    ENTREPRISES.nom_entreprise;


-- Affiche les entreprises comptant plus d'un utilisateur.
SELECT
    ENTREPRISES.nom_entreprise,
    COUNT(UTILISATEURS.id_utilisateur) AS nombre_utilisateurs
FROM ENTREPRISES
LEFT JOIN UTILISATEURS
    ON ENTREPRISES.id_entreprise = UTILISATEURS.id_entreprise
GROUP BY
    ENTREPRISES.id_entreprise,
    ENTREPRISES.nom_entreprise
HAVING COUNT(UTILISATEURS.id_utilisateur) > 1;


-- ============================================================
-- 3. SOUS-REQUÊTE
-- ============================================================

-- Affiche le nombre d'abonnements associés à chaque entreprise
-- à l'aide d'une sous-requête corrélée.
SELECT
    ENTREPRISES.nom_entreprise,
    (
        SELECT COUNT(*)
        FROM ABONNEMENTS
        WHERE ABONNEMENTS.id_entreprise = ENTREPRISES.id_entreprise
    ) AS nombre_abonnements
FROM ENTREPRISES;


-- ============================================================
-- 4. CTE ET CALCUL DU MRR
-- ============================================================

-- Identifie les abonnements actuellement actifs.
WITH abonnements_actifs AS (
    SELECT
        id_entreprise,
        prix_mensuel
    FROM ABONNEMENTS
    WHERE date_fin IS NULL
)

-- Calcule le revenu mensuel récurrent (MRR) par entreprise.
SELECT
    ENTREPRISES.nom_entreprise,
    SUM(abonnements_actifs.prix_mensuel) AS mrr
FROM abonnements_actifs
INNER JOIN ENTREPRISES
    ON abonnements_actifs.id_entreprise = ENTREPRISES.id_entreprise
GROUP BY
    ENTREPRISES.id_entreprise,
    ENTREPRISES.nom_entreprise;


-- ============================================================
-- 5. STATUT DES ABONNEMENTS
-- ============================================================

-- Identifie les entreprises ayant au moins un abonnement actif
-- ou un abonnement terminé.
SELECT
    ENTREPRISES.nom_entreprise,
    'Actif' AS statut
FROM ABONNEMENTS
INNER JOIN ENTREPRISES
    ON ABONNEMENTS.id_entreprise = ENTREPRISES.id_entreprise
WHERE ABONNEMENTS.date_fin IS NULL

UNION

SELECT
    ENTREPRISES.nom_entreprise,
    'Churné' AS statut
FROM ABONNEMENTS
INNER JOIN ENTREPRISES
    ON ABONNEMENTS.id_entreprise = ENTREPRISES.id_entreprise
WHERE ABONNEMENTS.date_fin IS NOT NULL;


-- ============================================================
-- 6. ANALYSE DE L'ACTIVITÉ
-- ============================================================

-- Affiche le nombre de requêtes effectuées par utilisateur
-- ainsi que le nombre total de requêtes de son entreprise.
SELECT
    UTILISATEURS.nom_utilisateur,
    ENTREPRISES.nom_entreprise,
    ACTIVITE.nb_requetes,
    SUM(ACTIVITE.nb_requetes)
        OVER (
            PARTITION BY UTILISATEURS.id_entreprise
        ) AS total_requetes_entreprise
FROM ACTIVITE
INNER JOIN UTILISATEURS
    ON ACTIVITE.id_utilisateur = UTILISATEURS.id_utilisateur
INNER JOIN ENTREPRISES
    ON UTILISATEURS.id_entreprise = ENTREPRISES.id_entreprise;


-- ============================================================
-- 7. CLASSEMENT DES UTILISATEURS
-- ============================================================

-- Classe les utilisateurs de chaque entreprise selon leur
-- nombre total de requêtes.
--
-- ROW_NUMBER() attribue un rang à chaque utilisateur au sein
-- de son entreprise, du plus actif au moins actif.
SELECT
    ENTREPRISES.nom_entreprise,
    UTILISATEURS.nom_utilisateur,
    SUM(ACTIVITE.nb_requetes) AS total_requetes,
    ROW_NUMBER() OVER (
        PARTITION BY ENTREPRISES.id_entreprise
        ORDER BY SUM(ACTIVITE.nb_requetes) DESC
    ) AS rang
FROM ACTIVITE
INNER JOIN UTILISATEURS
    ON ACTIVITE.id_utilisateur = UTILISATEURS.id_utilisateur
INNER JOIN ENTREPRISES
    ON UTILISATEURS.id_entreprise = ENTREPRISES.id_entreprise
GROUP BY
    ENTREPRISES.id_entreprise,
    ENTREPRISES.nom_entreprise,
    UTILISATEURS.id_utilisateur,
    UTILISATEURS.nom_utilisateur;
```
