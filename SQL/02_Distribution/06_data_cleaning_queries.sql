/* =========================================================================
   06_data_cleaning_queries.sql

   CDCI Distribution BI - Nettoyage des données

   Objectif :
   - Corriger les anomalies détectées lors de l'audit
   - Conserver l'ensemble des lignes transactionnelles
   - Remplacer ou corriger les valeurs incohérentes
   - Préparer les données pour l'analyse BI

   Anomalies traitées :
   - Quantités négatives
   - Montants NULL
   - Clés étrangères orphelines
   - Quantités de stock négatives
   - Délais d'approvisionnement négatifs
   - Dates de livraison incohérentes
   - Quantités de retour négatives

   Principes de nettoyage :
   - Aucune suppression de ligne
   - Conservation des volumes transactionnels
   - Remplacement des valeurs invalides par des valeurs cohérentes
   - Conservation des anomalies dans les cas où aucune correction
     fiable ne peut être déduite

   ========================================================================= */

SET NOCOUNT ON;
GO

USE [CDCI_Distribution];
GO


/* =========================================================================
   SECTION 1 : NETTOYAGE DES QUANTITÉS DE VENTES
   ========================================================================= */

/*
   Les quantités négatives sont considérées comme invalides
   dans Fact_Ventes.

   Correction :
   - Conversion en valeur absolue.
   - Aucune ligne n'est supprimée.
*/

UPDATE Fact_Ventes
SET Quantite = ABS(Quantite)
WHERE Quantite < 0;


/* =========================================================================
   SECTION 2 : NETTOYAGE DES MONTANTS DE VENTES
   ========================================================================= */

/*
   Les MontantTotal NULL sont recalculés à partir de :
   Quantite × PrixUnitaireVente.

   Cette règle permet de conserver la cohérence
   entre les informations transactionnelles.
*/

UPDATE Fact_Ventes
SET MontantTotal = Quantite * PrixUnitaireVente
WHERE MontantTotal IS NULL
  AND Quantite IS NOT NULL
  AND PrixUnitaireVente IS NOT NULL;


/*
   Sécurisation supplémentaire :
   les éventuels montants encore NULL sont remplacés par 0
   lorsqu'aucune information permettant leur recalcul n'est disponible.
*/

UPDATE Fact_Ventes
SET MontantTotal = 0
WHERE MontantTotal IS NULL;


/* =========================================================================
   SECTION 3 : NETTOYAGE DES CLIENTS ORPHELINS
   ========================================================================= */

/*
   Les ClientID qui ne correspondent à aucun client existant
   sont remplacés par NULL.

   Cette approche évite de créer une fausse correspondance
   avec un autre client.
*/

UPDATE v
SET ClientID = NULL
FROM Fact_Ventes v
LEFT JOIN Dim_Client c
    ON v.ClientID = c.ClientID
WHERE c.ClientID IS NULL;


/* =========================================================================
   SECTION 4 : NETTOYAGE DES QUANTITÉS DE STOCK
   ========================================================================= */

/*
   Les quantités de stock négatives sont converties
   en valeurs positives.
*/

UPDATE Fact_Stock
SET QuantiteStock = ABS(QuantiteStock)
WHERE QuantiteStock < 0;


/* =========================================================================
   SECTION 5 : NETTOYAGE DES DÉLAIS D'APPROVISIONNEMENT
   ========================================================================= */

/*
   Les délais négatifs sont considérés comme invalides.

   Correction :
   - Conversion en valeur absolue.
*/

UPDATE Fact_Approvisionnement
SET DelaiLivraisonJours = ABS(DelaiLivraisonJours)
WHERE DelaiLivraisonJours < 0;


/* =========================================================================
   SECTION 6 : NETTOYAGE DES DATES DE LIVRAISON
   ========================================================================= */

/*
   Lorsqu'une date réelle est antérieure à la date prévue,
   la date réelle est remplacée par la date prévue.

   Cela permet de conserver l'enregistrement tout en supprimant
   l'incohérence temporelle.
*/

UPDATE Fact_Livraison
SET DateLivraisonReelle = DateLivraisonPrevue
WHERE DateLivraisonReelle IS NOT NULL
  AND DateLivraisonReelle < DateLivraisonPrevue;


/* =========================================================================
   SECTION 7 : NETTOYAGE DES QUANTITÉS DE RETOURS
   ========================================================================= */

/*
   Une quantité retournée négative est convertie
   en valeur positive.
*/

UPDATE Fact_Retours
SET QuantiteRetournee = ABS(QuantiteRetournee)
WHERE QuantiteRetournee < 0;


/* =========================================================================
   SECTION 8 : VÉRIFICATION APRÈS NETTOYAGE
   ========================================================================= */


/* 8.1 - Quantités négatives dans Fact_Ventes */

SELECT
    COUNT(*) AS Ventes_QteNegative_Apres
FROM Fact_Ventes
WHERE Quantite < 0;


/* 8.2 - Montants NULL dans Fact_Ventes */

SELECT
    COUNT(*) AS Ventes_MontantNull_Apres
FROM Fact_Ventes
WHERE MontantTotal IS NULL;


/* 8.3 - Clients orphelins dans Fact_Ventes */

SELECT
    COUNT(*) AS Ventes_ClientOrphelin_Apres
FROM Fact_Ventes v
LEFT JOIN Dim_Client c
    ON v.ClientID = c.ClientID
WHERE v.ClientID IS NOT NULL
  AND c.ClientID IS NULL;


/* 8.4 - Quantités négatives dans Fact_Stock */

SELECT
    COUNT(*) AS Stock_QteNegative_Apres
FROM Fact_Stock
WHERE QuantiteStock < 0;


/* 8.5 - Délais négatifs dans Fact_Approvisionnement */

SELECT
    COUNT(*) AS Appro_DelaiNegatif_Apres
FROM Fact_Approvisionnement
WHERE DelaiLivraisonJours < 0;


/* 8.6 - Dates de livraison incohérentes */

SELECT
    COUNT(*) AS Livraison_DateIncoherente_Apres
FROM Fact_Livraison
WHERE DateLivraisonReelle IS NOT NULL
  AND DateLivraisonReelle < DateLivraisonPrevue;


/* 8.7 - Quantités négatives dans Fact_Retours */

SELECT
    COUNT(*) AS Retours_QteNegative_Apres
FROM Fact_Retours
WHERE QuantiteRetournee < 0;


/* =========================================================================
   SECTION 9 : CONTRÔLE DES VOLUMES
   ========================================================================= */

SELECT
    'Dim_Region' AS Tableau,
    COUNT(*) AS Lignes
FROM Dim_Region

UNION ALL

SELECT
    'Dim_Departement',
    COUNT(*)
FROM Dim_Departement

UNION ALL

SELECT
    'Dim_Ville',
    COUNT(*)
FROM Dim_Ville

UNION ALL

SELECT
    'Dim_Categorie',
    COUNT(*)
FROM Dim_Categorie

UNION ALL

SELECT
    'Dim_Produit',
    COUNT(*)
FROM Dim_Produit

UNION ALL

SELECT
    'Dim_Fournisseur',
    COUNT(*)
FROM Dim_Fournisseur

UNION ALL

SELECT
    'Dim_Magasin',
    COUNT(*)
FROM Dim_Magasin

UNION ALL

SELECT
    'Dim_Entrepot',
    COUNT(*)
FROM Dim_Entrepot

UNION ALL

SELECT
    'Dim_Client',
    COUNT(*)
FROM Dim_Client

UNION ALL

SELECT
    'Dim_Employe',
    COUNT(*)
FROM Dim_Employe

UNION ALL

SELECT
    'Dim_Date',
    COUNT(*)
FROM Dim_Date

UNION ALL

SELECT
    'Fact_Ventes',
    COUNT(*)
FROM Fact_Ventes

UNION ALL

SELECT
    'Fact_Stock',
    COUNT(*)
FROM Fact_Stock

UNION ALL

SELECT
    'Fact_Approvisionnement',
    COUNT(*)
FROM Fact_Approvisionnement

UNION ALL

SELECT
    'Fact_Livraison',
    COUNT(*)
FROM Fact_Livraison

UNION ALL

SELECT
    'Fact_Retours',
    COUNT(*)
FROM Fact_Retours

ORDER BY Lignes DESC;


/* =========================================================================
   SECTION 10 : RÉSUMÉ FINAL DU NETTOYAGE
   ========================================================================= */

SELECT
    (SELECT COUNT(*)
     FROM Fact_Ventes
     WHERE Quantite < 0)
        AS Ventes_QteNegative,

    (SELECT COUNT(*)
     FROM Fact_Ventes
     WHERE MontantTotal IS NULL)
        AS Ventes_MontantNull,

    (SELECT COUNT(*)
     FROM Fact_Ventes v
     LEFT JOIN Dim_Client c
         ON v.ClientID = c.ClientID
     WHERE v.ClientID IS NOT NULL
       AND c.ClientID IS NULL)
        AS Ventes_ClientOrphelin,

    (SELECT COUNT(*)
     FROM Fact_Stock
     WHERE QuantiteStock < 0)
        AS Stock_QteNegative,

    (SELECT COUNT(*)
     FROM Fact_Stock
     WHERE MagasinID IS NULL
       AND EntrepotID IS NULL)
        AS Stock_SansLocalisations,

    (SELECT COUNT(*)
     FROM Fact_Approvisionnement
     WHERE DelaiLivraisonJours < 0)
        AS Appro_DelaiNegatif,

    (SELECT COUNT(*)
     FROM Fact_Livraison
     WHERE DateLivraisonReelle IS NOT NULL
       AND DateLivraisonReelle < DateLivraisonPrevue)
        AS Livraison_DateIncoherente,

    (SELECT COUNT(*)
     FROM Fact_Retours
     WHERE QuantiteRetournee < 0)
        AS Retours_QteNegative,

    (SELECT COUNT(*)
     FROM Dim_Produit
     WHERE PrixUnitaire IS NULL)
        AS Produit_PrixNull,

    (SELECT COUNT(*)
     FROM Dim_Produit
     WHERE CoutUnitaire < 0)
        AS Produit_CoutNegatif;
GO