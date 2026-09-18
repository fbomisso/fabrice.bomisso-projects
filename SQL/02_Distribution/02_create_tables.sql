/* =========================================================================
   02_create_tables.sql
   CDCI Distribution - Création des tables
   ========================================================================= */

SET NOCOUNT ON;

USE [CDCI_Distribution];


/* =========================================================================
   TABLE UTILITAIRE : Numbers
   ========================================================================= */

;WITH L0 AS
(
    SELECT 1 AS c
    UNION ALL
    SELECT 1
),
L1 AS
(
    SELECT 1 AS c
    FROM L0 A
    CROSS JOIN L0 B
),
L2 AS
(
    SELECT 1 AS c
    FROM L1 A
    CROSS JOIN L1 B
),
L3 AS
(
    SELECT 1 AS c
    FROM L2 A
    CROSS JOIN L2 B
),
L4 AS
(
    SELECT 1 AS c
    FROM L3 A
    CROSS JOIN L3 B
),
L5 AS
(
    SELECT 1 AS c
    FROM L4 A
    CROSS JOIN L4 B
)
SELECT TOP (300000)
    CAST(
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
        AS INT
    ) AS N
INTO dbo.Numbers
FROM L5;

ALTER TABLE dbo.Numbers
ALTER COLUMN N INT NOT NULL;

ALTER TABLE dbo.Numbers
ADD CONSTRAINT PK_Numbers
PRIMARY KEY CLUSTERED (N);


/* =========================================================================
   DIMENSIONS
   ========================================================================= */

CREATE TABLE dbo.Dim_Region
(
    RegionID        INT PRIMARY KEY,
    NomRegion       VARCHAR(60) NOT NULL,
    District        VARCHAR(60) NOT NULL,
    ChefLieuRegion  VARCHAR(60) NOT NULL
);

CREATE TABLE dbo.Dim_Departement
(
    DepartementID   INT PRIMARY KEY,
    RegionID        INT NOT NULL,
    NomDepartement  VARCHAR(80) NOT NULL
);

CREATE TABLE dbo.Dim_Ville
(
    VilleID         INT PRIMARY KEY,
    NomVille        VARCHAR(80) NOT NULL,
    DepartementID   INT NULL,
    RegionID        INT NOT NULL
);

CREATE TABLE dbo.Dim_Categorie
(
    CategorieID     INT PRIMARY KEY,
    NomCategorie    VARCHAR(60) NOT NULL
);

CREATE TABLE dbo.Dim_Fournisseur
(
    FournisseurID            INT PRIMARY KEY,
    NomFournisseur           VARCHAR(120) NOT NULL,
    Pays                     VARCHAR(60),
    TypeFournisseur          VARCHAR(20),
    NoteQualite              DECIMAL(3,1),
    DelaiLivraisonMoyenJours INT
);

CREATE TABLE dbo.Dim_Produit
(
    ProduitID       INT PRIMARY KEY,
    NomProduit      VARCHAR(150) NOT NULL,
    CategorieID     INT NOT NULL,
    Marque          VARCHAR(60),
    Conditionnement VARCHAR(30),
    PrixUnitaire    DECIMAL(10,2),
    CoutUnitaire    DECIMAL(10,2),
    FournisseurID   INT
);

CREATE TABLE dbo.Dim_Magasin
(
    MagasinID       INT PRIMARY KEY,
    NomMagasin      VARCHAR(100) NOT NULL,
    VilleID         INT NOT NULL,
    RegionID        INT NOT NULL,
    TypeMagasin     VARCHAR(30),
    Surface_m2      INT
);

CREATE TABLE dbo.Dim_Entrepot
(
    EntrepotID      INT PRIMARY KEY,
    NomEntrepot     VARCHAR(100) NOT NULL,
    VilleID         INT NULL,
    RegionID        INT NULL,
    CapaciteM3      INT
);

CREATE TABLE dbo.Dim_Client
(
    ClientID        INT PRIMARY KEY,
    NomClient       VARCHAR(120) NOT NULL,
    TypeClient      VARCHAR(30),
    VilleID         INT,
    RegionID        INT,
    Telephone       VARCHAR(30)
);

CREATE TABLE dbo.Dim_Employe
(
    EmployeID       INT PRIMARY KEY,
    Nom             VARCHAR(60),
    Prenom          VARCHAR(60),
    Poste            VARCHAR(50),
    DateEmbauche    DATE,
    MagasinID       INT NULL,
    EntrepotID      INT NULL
);

CREATE TABLE dbo.Dim_Date
(
    DateID          INT PRIMARY KEY,
    DateComplete    DATE NOT NULL,
    Jour            INT,
    Mois            INT,
    NomMois         VARCHAR(20),
    Trimestre       INT,
    Annee           INT,
    JourSemaine     VARCHAR(20),
    EstWeekend      BIT,
    Semaine         INT
);


/* =========================================================================
   TABLES DE FAITS
   ========================================================================= */

CREATE TABLE dbo.Fact_Ventes
(
    VenteID             BIGINT PRIMARY KEY,
    DateID              INT,
    MagasinID           INT,
    ProduitID           INT,
    ClientID            INT,
    EmployeID           INT,
    Quantite            INT,
    PrixUnitaireVente   DECIMAL(10,2),
    MontantTotal        DECIMAL(14,2),
    ModePaiement        VARCHAR(30)
);

CREATE TABLE dbo.Fact_Stock
(
    StockID         BIGINT PRIMARY KEY,
    DateID          INT,
    ProduitID       INT,
    MagasinID       INT NULL,
    EntrepotID      INT NULL,
    QuantiteStock   INT,
    SeuilAlerte     INT
);

CREATE TABLE dbo.Fact_Approvisionnement
(
    ApproID                 BIGINT PRIMARY KEY,
    DateID                  INT,
    ProduitID               INT,
    FournisseurID           INT,
    EntrepotID              INT,
    QuantiteCommandee       INT,
    CoutTotal               DECIMAL(14,2),
    DelaiLivraisonJours     INT
);

CREATE TABLE dbo.Fact_Livraison
(
    LivraisonID             BIGINT PRIMARY KEY,
    DateID                  INT,
    EntrepotID              INT,
    MagasinID               INT,
    ProduitID               INT,
    QuantiteLivree          INT,
    DateLivraisonPrevue     DATE,
    DateLivraisonReelle     DATE,
    StatutLivraison         VARCHAR(20)
);

CREATE TABLE dbo.Fact_Retours
(
    RetourID            BIGINT PRIMARY KEY,
    DateID              INT,
    MagasinID           INT,
    ProduitID           INT,
    ClientID            INT NULL,
    QuantiteRetournee   INT,
    MotifRetour         VARCHAR(50),
    MontantRembourse    DECIMAL(12,2)
);


/* =========================================================================
   CONTROLE
   ========================================================================= */

SELECT
    TABLE_NAME AS TableName
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
  AND TABLE_NAME IN
  (
      'Numbers',
      'Dim_Region',
      'Dim_Departement',
      'Dim_Ville',
      'Dim_Categorie',
      'Dim_Fournisseur',
      'Dim_Produit',
      'Dim_Magasin',
      'Dim_Entrepot',
      'Dim_Client',
      'Dim_Employe',
      'Dim_Date',
      'Fact_Ventes',
      'Fact_Stock',
      'Fact_Approvisionnement',
      'Fact_Livraison',
      'Fact_Retours'
  )
ORDER BY
    CASE
        WHEN TABLE_NAME = 'Numbers' THEN 0
        WHEN TABLE_NAME LIKE 'Dim_%' THEN 1
        ELSE 2
    END,
    TABLE_NAME;

SELECT COUNT(*) AS NbNumeros
FROM dbo.Numbers;