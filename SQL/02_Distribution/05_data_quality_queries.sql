/* =========================================================================
   05_data_quality_queries.sql

   CDCI Distribution BI - Audit de qualité des données

   Objectif :
   - Détecter les anomalies volontaires dans les données
   - Mesurer leur impact sur chaque table
   - Produire un rapport de qualité complet

   Anomalies recherchées :
   - Valeurs NULL
   - Quantités négatives
   - Doublons
   - Clés étrangères orphelines
   - Dates incohérentes
   - Prix aberrants
   - Valeurs hors plage

   ========================================================================= */

SET NOCOUNT ON;
GO

USE [CDCI_Distribution];
GO


/* =========================================================================
   SECTION 1 : VOLUMES ET DISTRIBUTION
   ========================================================================= */

SELECT
    'Dim_Region' AS Tableau,
    COUNT(*) AS Lignes,
    NULL AS Details
FROM Dim_Region

UNION ALL

SELECT
    'Dim_Departement',
    COUNT(*),
    NULL
FROM Dim_Departement

UNION ALL

SELECT
    'Dim_Ville',
    COUNT(*),
    NULL
FROM Dim_Ville

UNION ALL

SELECT
    'Dim_Categorie',
    COUNT(*),
    NULL
FROM Dim_Categorie

UNION ALL

SELECT
    'Dim_Produit',
    COUNT(*),
    NULL
FROM Dim_Produit

UNION ALL

SELECT
    'Dim_Fournisseur',
    COUNT(*),
    NULL
FROM Dim_Fournisseur

UNION ALL

SELECT
    'Dim_Magasin',
    COUNT(*),
    NULL
FROM Dim_Magasin

UNION ALL

SELECT
    'Dim_Entrepot',
    COUNT(*),
    NULL
FROM Dim_Entrepot

UNION ALL

SELECT
    'Dim_Client',
    COUNT(*),
    NULL
FROM Dim_Client

UNION ALL

SELECT
    'Dim_Employe',
    COUNT(*),
    NULL
FROM Dim_Employe

UNION ALL

SELECT
    'Dim_Date',
    COUNT(*),
    NULL
FROM Dim_Date

UNION ALL

SELECT
    'Fact_Ventes',
    COUNT(*),
    NULL
FROM Fact_Ventes

UNION ALL

SELECT
    'Fact_Stock',
    COUNT(*),
    NULL
FROM Fact_Stock

UNION ALL

SELECT
    'Fact_Approvisionnement',
    COUNT(*),
    NULL
FROM Fact_Approvisionnement

UNION ALL

SELECT
    'Fact_Livraison',
    COUNT(*),
    NULL
FROM Fact_Livraison

UNION ALL

SELECT
    'Fact_Retours',
    COUNT(*),
    NULL
FROM Fact_Retours

ORDER BY Lignes DESC;


/* =========================================================================
   SECTION 2 : NULL DANS LES COLONNES CRITIQUES
   ========================================================================= */


/* 2.1 - Dim_Produit : NULL dans les prix */

SELECT
    'PrixUnitaire' AS Colonne,
    COUNT(*) AS NbNull,
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Dim_Produit), 0) AS TauxNull
FROM Dim_Produit
WHERE PrixUnitaire IS NULL

UNION ALL

SELECT
    'CoutUnitaire',
    COUNT(*),
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Dim_Produit), 0)
FROM Dim_Produit
WHERE CoutUnitaire IS NULL

UNION ALL

SELECT
    'Marque',
    COUNT(*),
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Dim_Produit), 0)
FROM Dim_Produit
WHERE Marque IS NULL;


/* 2.2 - Fact_Ventes : NULL dans les colonnes critiques */

SELECT
    'EmployeID' AS Colonne,
    COUNT(*) AS NbNull,
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Fact_Ventes), 0) AS TauxNull
FROM Fact_Ventes
WHERE EmployeID IS NULL

UNION ALL

SELECT
    'MontantTotal',
    COUNT(*),
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Fact_Ventes), 0)
FROM Fact_Ventes
WHERE MontantTotal IS NULL

UNION ALL

SELECT
    'ModePaiement',
    COUNT(*),
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Fact_Ventes), 0)
FROM Fact_Ventes
WHERE ModePaiement IS NULL;


/* 2.3 - Fact_Stock : NULL aux deux localisations */

SELECT
    COUNT(*) AS NbLignesSansMagasinNiEntrepot,
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Fact_Stock), 0) AS TauxAnomalie
FROM Fact_Stock
WHERE MagasinID IS NULL
  AND EntrepotID IS NULL;


/* 2.4 - Dim_Client : NULL sur les informations clients */

SELECT
    'Telephone' AS Colonne,
    COUNT(*) AS NbNull,
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Dim_Client), 0) AS TauxNull
FROM Dim_Client
WHERE Telephone IS NULL;


/* =========================================================================
   SECTION 3 : QUANTITÉS NÉGATIVES
   ========================================================================= */


/* 3.1 - Fact_Ventes : quantités négatives */

SELECT
    COUNT(*) AS NbQuantitesNegatives,
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Fact_Ventes), 0) AS TauxAnomalie,
    MIN(Quantite) AS MinQuantite,
    MAX(Quantite) AS MaxQuantite
FROM Fact_Ventes
WHERE Quantite < 0;


/* 3.2 - Fact_Stock : quantités négatives */

SELECT
    COUNT(*) AS NbQuantitesNegatives,
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Fact_Stock), 0) AS TauxAnomalie,
    MIN(QuantiteStock) AS MinQuantite,
    MAX(QuantiteStock) AS MaxQuantite
FROM Fact_Stock
WHERE QuantiteStock < 0;


/* 3.3 - Fact_Retours : quantités négatives */

SELECT
    COUNT(*) AS NbQuantitesNegatives,
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Fact_Retours), 0) AS TauxAnomalie
FROM Fact_Retours
WHERE QuantiteRetournee < 0;


/* 3.4 - Fact_Approvisionnement : délais négatifs */

SELECT
    COUNT(*) AS NbDelaisNegatifs,
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Fact_Approvisionnement), 0) AS TauxAnomalie,
    MIN(DelaiLivraisonJours) AS MinDelai,
    MAX(DelaiLivraisonJours) AS MaxDelai
FROM Fact_Approvisionnement
WHERE DelaiLivraisonJours < 0;


/* =========================================================================
   SECTION 4 : PRIX ABERRANTS
   ========================================================================= */


/* 4.1 - Dim_Produit : coûts unitaires négatifs */

SELECT
    COUNT(*) AS NbCoutsNegatifs,
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Dim_Produit), 0) AS TauxAnomalie,
    MIN(CoutUnitaire) AS MinCout,
    MAX(CoutUnitaire) AS MaxCout
FROM Dim_Produit
WHERE CoutUnitaire < 0;


/* 4.2 - Fact_Ventes : prix unitaires aberrants */

SELECT
    COUNT(*) AS NbPrixAberrants,
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Fact_Ventes), 0) AS TauxAnomalie,
    MIN(PrixUnitaireVente) AS MinPrix,
    MAX(PrixUnitaireVente) AS MaxPrix
FROM Fact_Ventes
WHERE PrixUnitaireVente > 10000;


/* =========================================================================
   SECTION 5 : DATES INCOHÉRENTES
   ========================================================================= */


/* 5.1 - Fact_Livraison : date réelle avant date prévue */

SELECT
    COUNT(*) AS NbDatesIncoherentes,
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Fact_Livraison), 0) AS TauxAnomalie,
    COUNT(DISTINCT LivraisonID) AS LivraisonsAffectees
FROM Fact_Livraison
WHERE DateLivraisonReelle IS NOT NULL
  AND DateLivraisonReelle < DateLivraisonPrevue;


/* =========================================================================
   SECTION 6 : CLÉS ÉTRANGÈRES ORPHELINES
   ========================================================================= */


/* 6.1 - Fact_Ventes : ClientID sans correspondance */

SELECT
    COUNT(*) AS NbClientsOrphelines,
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Fact_Ventes), 0) AS TauxAnomalie,
    CAST(COUNT(DISTINCT v.ClientID) AS INT) AS NbClientIDDistincts
FROM Fact_Ventes v
LEFT JOIN Dim_Client c
    ON v.ClientID = c.ClientID
WHERE c.ClientID IS NULL;


/* 6.2 - Fact_Approvisionnement : FournisseurID sans correspondance */

SELECT
    COUNT(*) AS NbFournisseursOrphelines,
    COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Fact_Approvisionnement), 0) AS TauxAnomalie,
    CAST(COUNT(DISTINCT a.FournisseurID) AS INT) AS NbFournisseurIDDistincts
FROM Fact_Approvisionnement a
LEFT JOIN Dim_Fournisseur f
    ON a.FournisseurID = f.FournisseurID
WHERE f.FournisseurID IS NULL;


/* =========================================================================
   SECTION 7 : DOUBLONS
   ========================================================================= */


/* 7.1 - Fact_Ventes : mêmes données métier */

WITH VentesGroupees AS
(
    SELECT
        DateID,
        MagasinID,
        ProduitID,
        ClientID,
        Quantite,
        PrixUnitaireVente,
        COUNT(*) AS NbOccurrences
    FROM Fact_Ventes
    GROUP BY
        DateID,
        MagasinID,
        ProduitID,
        ClientID,
        Quantite,
        PrixUnitaireVente
)
SELECT
    SUM(NbOccurrences - 1) AS NbLignesDoublons,
    SUM(NbOccurrences - 1) * 100.0
        / NULLIF((SELECT COUNT(*) FROM Fact_Ventes), 0) AS TauxDoublons,
    COUNT(*) AS NbGroupesUniqueAvecDoublons
FROM VentesGroupees
WHERE NbOccurrences > 1;


/* =========================================================================
   SECTION 8 : RÉSUMÉ EXÉCUTIF
   ========================================================================= */

SELECT
    (
        SELECT COUNT(*)
        FROM Fact_Ventes
        WHERE Quantite < 0
    ) AS Ventes_QteNegative,

    (
        SELECT COUNT(*)
        FROM Fact_Ventes
        WHERE MontantTotal IS NULL
    ) AS Ventes_MontantNull,

    (
        SELECT COUNT(*)
        FROM Fact_Ventes v
        LEFT JOIN Dim_Client c
            ON v.ClientID = c.ClientID
        WHERE c.ClientID IS NULL
    ) AS Ventes_ClientOrphelin,

    (
        SELECT COUNT(*)
        FROM Fact_Stock
        WHERE QuantiteStock < 0
    ) AS Stock_QteNegative,

    (
        SELECT COUNT(*)
        FROM Fact_Stock
        WHERE MagasinID IS NULL
          AND EntrepotID IS NULL
    ) AS Stock_SansLocalisations,

    (
        SELECT COUNT(*)
        FROM Fact_Approvisionnement
        WHERE DelaiLivraisonJours < 0
    ) AS Appro_DelaiNegatif,

    (
        SELECT COUNT(*)
        FROM Fact_Livraison
        WHERE DateLivraisonReelle < DateLivraisonPrevue
    ) AS Livraison_DateIncoherente,

    (
        SELECT COUNT(*)
        FROM Fact_Retours
        WHERE QuantiteRetournee < 0
    ) AS Retours_QteNegative,

    (
        SELECT COUNT(*)
        FROM Dim_Produit
        WHERE PrixUnitaire IS NULL
    ) AS Produit_PrixNull,

    (
        SELECT COUNT(*)
        FROM Dim_Produit
        WHERE CoutUnitaire < 0
    ) AS Produit_CoutNegatif;
GO