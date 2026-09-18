/* =========================================================================
   07_validation_final.sql

   CDCI Distribution - Validation finale de la base

   Objectif :
   - Vérifier les volumes finaux
   - Vérifier l'absence d'anomalies
   - Vérifier les contraintes FK
   - Vérifier les index
   - Confirmer que la base est prête pour Power BI

   ========================================================================= */

SET NOCOUNT ON;
GO

USE [CDCI_Distribution];
GO


/* =========================================================================
   SECTION 1 : VOLUMES FINAUX
   ========================================================================= */

SELECT
    'Dim_Region' AS Tableau,
    COUNT(*) AS NombreLignes
FROM Dim_Region

UNION ALL

SELECT 'Dim_Departement', COUNT(*)
FROM Dim_Departement

UNION ALL

SELECT 'Dim_Ville', COUNT(*)
FROM Dim_Ville

UNION ALL

SELECT 'Dim_Categorie', COUNT(*)
FROM Dim_Categorie

UNION ALL

SELECT 'Dim_Produit', COUNT(*)
FROM Dim_Produit

UNION ALL

SELECT 'Dim_Fournisseur', COUNT(*)
FROM Dim_Fournisseur

UNION ALL

SELECT 'Dim_Magasin', COUNT(*)
FROM Dim_Magasin

UNION ALL

SELECT 'Dim_Entrepot', COUNT(*)
FROM Dim_Entrepot

UNION ALL

SELECT 'Dim_Client', COUNT(*)
FROM Dim_Client

UNION ALL

SELECT 'Dim_Employe', COUNT(*)
FROM Dim_Employe

UNION ALL

SELECT 'Dim_Date', COUNT(*)
FROM Dim_Date

UNION ALL

SELECT 'Fact_Ventes', COUNT(*)
FROM Fact_Ventes

UNION ALL

SELECT 'Fact_Stock', COUNT(*)
FROM Fact_Stock

UNION ALL

SELECT 'Fact_Approvisionnement', COUNT(*)
FROM Fact_Approvisionnement

UNION ALL

SELECT 'Fact_Livraison', COUNT(*)
FROM Fact_Livraison

UNION ALL

SELECT 'Fact_Retours', COUNT(*)
FROM Fact_Retours

ORDER BY NombreLignes DESC;


/* =========================================================================
   SECTION 2 : VALIDATION DES ANOMALIES MÉTIER
   ========================================================================= */

SELECT
    'Ventes - Quantités négatives' AS Controle,
    COUNT(*) AS Anomalies
FROM Fact_Ventes
WHERE Quantite < 0

UNION ALL

SELECT
    'Ventes - Montant NULL',
    COUNT(*)
FROM Fact_Ventes
WHERE MontantTotal IS NULL

UNION ALL

SELECT
    'Stock - Quantités négatives',
    COUNT(*)
FROM Fact_Stock
WHERE QuantiteStock < 0

UNION ALL

SELECT
    'Stock - Sans localisation',
    COUNT(*)
FROM Fact_Stock
WHERE MagasinID IS NULL
  AND EntrepotID IS NULL

UNION ALL

SELECT
    'Approvisionnement - Délais négatifs',
    COUNT(*)
FROM Fact_Approvisionnement
WHERE DelaiLivraisonJours < 0

UNION ALL

SELECT
    'Livraison - Dates incohérentes',
    COUNT(*)
FROM Fact_Livraison
WHERE DateLivraisonReelle IS NOT NULL
  AND DateLivraisonReelle < DateLivraisonPrevue

UNION ALL

SELECT
    'Retours - Quantités négatives',
    COUNT(*)
FROM Fact_Retours
WHERE QuantiteRetournee < 0

UNION ALL

SELECT
    'Produit - Prix NULL',
    COUNT(*)
FROM Dim_Produit
WHERE PrixUnitaire IS NULL

UNION ALL

SELECT
    'Produit - Coûts négatifs',
    COUNT(*)
FROM Dim_Produit
WHERE CoutUnitaire < 0;


/* =========================================================================
   SECTION 3 : VALIDATION DES CLÉS ÉTRANGÈRES
   ========================================================================= */

SELECT
    COUNT(*) AS NombreContraintesFK
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'dbo'
  AND CONSTRAINT_TYPE = 'FOREIGN KEY';


/* =========================================================================
   SECTION 4 : VALIDATION DES INDEX
   ========================================================================= */

SELECT
    COUNT(*) AS NombreIndexHorsPK
FROM sys.indexes
WHERE object_id IN
(
    SELECT object_id
    FROM sys.tables
    WHERE type = 'U'
)
AND name NOT LIKE 'PK_%'
AND type <> 0;


/* =========================================================================
   SECTION 5 : VALIDATION DES TABLES
   ========================================================================= */

SELECT
    COUNT(*) AS NombreTables
FROM sys.tables
WHERE type = 'U';


/* =========================================================================
   SECTION 6 : VALIDATION DE LA STRUCTURE
   ========================================================================= */

SELECT
    t.name AS TableName,
    COUNT(c.column_id) AS NombreColonnes
FROM sys.tables t
INNER JOIN sys.columns c
    ON t.object_id = c.object_id
WHERE t.type = 'U'
GROUP BY t.name
ORDER BY t.name;
GO