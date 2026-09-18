/* =========================================================================
   03_insert_data.sql

   CDCI Distribution - Chargement des données

   Objectif :
   - Charger ~490 000 lignes de données synthétiques
   - Remplir les 11 dimensions et 5 tables de faits
   - Inclure volontairement des anomalies (NULL, quantités négatives,
     doublons, clés orphelines) pour l'audit de qualité

   Prérequis :
   - 01_create_database.sql
   - 02_create_tables.sql

   ========================================================================= */

SET NOCOUNT ON;
SET DATEFIRST 1;
GO

USE [CDCI_Distribution];
GO


/* =========================================================================
   INSERTION DES DIMENSIONS - PARTIE 1 : GÉOGRAPHIE
   ========================================================================= */

INSERT INTO Dim_Region
(
    RegionID,
    NomRegion,
    District,
    ChefLieuRegion
)
VALUES
(1,  'Gbôklé',            'Bas-Sassandra',        'Sassandra'),
(2,  'Nawa',              'Bas-Sassandra',        'Soubré'),
(3,  'San-Pédro',         'Bas-Sassandra',        'San-Pédro'),
(4,  'Indénié-Djuablin',  'Comoé',                'Abengourou'),
(5,  'Sud-Comoé',         'Comoé',                'Aboisso'),
(6,  'Folon',             'Denguélé',             'Minignan'),
(7,  'Kabadougou',        'Denguélé',             'Odienné'),
(8,  'Gôh',               'Gôh-Djiboua',          'Gagnoa'),
(9,  'Lôh-Djiboua',       'Gôh-Djiboua',          'Divo'),
(10, 'Bélier',            'Lacs',                 'Toumodi'),
(11, 'Iffou',             'Lacs',                 'Daoukro'),
(12, 'Moronou',           'Lacs',                 'Bongouanou'),
(13, 'N''Zi',             'Lacs',                 'Dimbokro'),
(14, 'Agnéby-Tiassa',     'Lagunes',              'Agboville'),
(15, 'Grands-Ponts',      'Lagunes',              'Dabou'),
(16, 'Mé',                'Lagunes',              'Adzopé'),
(17, 'Cavally',           'Montagnes',            'Guiglo'),
(18, 'Guémon',            'Montagnes',            'Duékoué'),
(19, 'Tonkpi',            'Montagnes',            'Man'),
(20, 'Haut-Sassandra',    'Sassandra-Marahoué',   'Daloa'),
(21, 'Marahoué',          'Sassandra-Marahoué',   'Bouaflé'),
(22, 'Bagoué',            'Savanes',              'Boundiali'),
(23, 'Poro',              'Savanes',              'Korhogo'),
(24, 'Tchologo',          'Savanes',              'Ferkessédougou'),
(25, 'Gbêké',             'Vallée du Bandama',    'Bouaké'),
(26, 'Hambol',            'Vallée du Bandama',    'Katiola'),
(27, 'Bafing',            'Woroba',               'Touba'),
(28, 'Béré',              'Woroba',               'Mankono'),
(29, 'Worodougou',        'Woroba',               'Séguéla'),
(30, 'Bounkani',          'Zanzan',               'Bouna'),
(31, 'Gontougo',          'Zanzan',               'Bondoukou');


INSERT INTO Dim_Categorie
(
    CategorieID,
    NomCategorie
)
VALUES
(1,  'Riz'),
(2,  'Huile'),
(3,  'Sucre'),
(4,  'Boissons'),
(5,  'Conserves'),
(6,  'Produits Frais'),
(7,  'Produits Laitiers'),
(8,  'Pâtes & Céréales'),
(9,  'Épicerie Salée'),
(10, 'Épicerie Sucrée'),
(11, 'Hygiène & Entretien'),
(12, 'Condiments & Épices');


/* =========================================================================
   Dim_Departement : 108 départements
   ========================================================================= */

IF OBJECT_ID('tempdb..#Regions') IS NOT NULL
    DROP TABLE #Regions;

SELECT
    RegionID,
    ChefLieuRegion,
    CASE
        WHEN RegionID <= 15 THEN 4
        ELSE 3
    END AS NbDept
INTO #Regions
FROM Dim_Region;


/* =========================================================================
   Liste auxiliaire de villes
   ========================================================================= */

IF OBJECT_ID('tempdb..#NomsVilles') IS NOT NULL
    DROP TABLE #NomsVilles;

CREATE TABLE #NomsVilles
(
    VilleIdx INT IDENTITY(1,1) PRIMARY KEY,
    Nom VARCHAR(60)
);

INSERT INTO #NomsVilles (Nom)
VALUES
('Sikensi'),
('Tiassalé'),
('Alépé'),
('Grand-Lahou'),
('Jacqueville'),
('Fresco'),
('Tabou'),
('Grabo'),
('Lakota'),
('Oumé'),
('Issia'),
('Vavoua'),
('Sinfra'),
('Zuénoula'),
('Danané'),
('Biankouma'),
('Bangolo'),
('Zouan-Hounien'),
('Toulepleu'),
('Sipilou'),
('Dabakala'),
('Sakassou'),
('Botro'),
('Niakaramandougou'),
('Tafiré'),
('Samatiguila'),
('Madinani'),
('Tengréla'),
('Kaniasso'),
('Tanda'),
('Transua'),
('Sandégué'),
('Koun-Fao'),
('Agnibilékrou'),
('Taabo'),
('Tiébissou'),
('Attiégouakro'),
('Yakassé-Attobrou'),
('Akoupé'),
('Affery'),
('Grand-Bassam'),
('Adiaké'),
('Bonoua'),
('Guitry'),
('Facobly'),
('Kouibly'),
('Bloléquin'),
('Ouangolodougou'),
('Sinématiali'),
('M''Bengué');


INSERT INTO Dim_Departement
(
    DepartementID,
    RegionID,
    NomDepartement
)
SELECT
    ROW_NUMBER() OVER
    (
        ORDER BY r.RegionID, n.N
    ) AS DepartementID,
    r.RegionID,
    CASE
        WHEN n.N = 1 THEN r.ChefLieuRegion
        ELSE
        (
            SELECT TOP 1 Nom
            FROM #NomsVilles
            ORDER BY NEWID()
        )
    END AS NomDepartement
FROM #Regions r
JOIN dbo.Numbers n
    ON n.N <= r.NbDept;


/* =========================================================================
   Dim_Ville
   ========================================================================= */

INSERT INTO Dim_Ville
(
    VilleID,
    NomVille,
    DepartementID,
    RegionID
)
SELECT
    DepartementID,
    NomDepartement,
    DepartementID,
    RegionID
FROM Dim_Departement;


INSERT INTO Dim_Ville
(
    VilleID,
    NomVille,
    DepartementID,
    RegionID
)
SELECT
    108 + ROW_NUMBER() OVER
    (
        ORDER BY (SELECT NULL)
    ),
    NomVille,
    NULL,
    (
        SELECT RegionID
        FROM Dim_Region
        WHERE NomRegion = 'Grands-Ponts'
    )
FROM
(
    VALUES
    ('Abobo'),
    ('Adjamé'),
    ('Attécoubé'),
    ('Cocody'),
    ('Koumassi'),
    ('Marcory'),
    ('Plateau'),
    ('Port-Bouët'),
    ('Treichville'),
    ('Yopougon'),
    ('Bingerville'),
    ('Anyama'),
    ('Songon')
) AS t(NomVille);


INSERT INTO Dim_Ville
(
    VilleID,
    NomVille,
    DepartementID,
    RegionID
)
VALUES
(
    122,
    'Yamoussoukro',
    NULL,
    (
        SELECT RegionID
        FROM Dim_Region
        WHERE NomRegion = 'Bélier'
    )
);


/* =========================================================================
   INSERTION DES FOURNISSEURS
   ========================================================================= */

IF OBJECT_ID('tempdb..#Noms') IS NOT NULL
    DROP TABLE #Noms;

CREATE TABLE #Noms
(
    Idx INT IDENTITY(1,1) PRIMARY KEY,
    Nom VARCHAR(60)
);

INSERT INTO #Noms (Nom)
VALUES
('Kouassi'),
('Koffi'),
('Yao'),
('N''Guessan'),
('Diabaté'),
('Traoré'),
('Ouattara'),
('Bamba'),
('Coulibaly'),
('Koné'),
('Bakayoko'),
('Touré'),
('Sanogo'),
('Camara'),
('Fofana'),
('Diallo'),
('Cissé'),
('Doumbia'),
('Sangaré'),
('Kobenan'),
('Assamoi'),
('Aka'),
('Brou'),
('Kacou'),
('Kragbe');


/* =========================================================================
   Fournisseurs locaux : 90
   ========================================================================= */

INSERT INTO Dim_Fournisseur
(
    FournisseurID,
    NomFournisseur,
    Pays,
    TypeFournisseur,
    NoteQualite,
    DelaiLivraisonMoyenJours
)
SELECT
    n.N,
    CASE (n.N % 4)
        WHEN 0 THEN 'Ets ' + nm.Nom + ' & Fils'
        WHEN 1 THEN 'SARL ' + nm.Nom + ' Distribution'
        WHEN 2 THEN 'Groupe ' + nm.Nom
        ELSE 'Comptoir ' + nm.Nom
    END
    + ' ' + CAST(n.N AS VARCHAR(10)),
    'Côte d''Ivoire',
    'Local',
    CAST
    (
        2 + (ABS(CHECKSUM(NEWID())) % 80) / 10.0
        AS DECIMAL(3,1)
    ),
    1 + ABS(CHECKSUM(NEWID())) % 10
FROM dbo.Numbers n
CROSS APPLY
(
    SELECT Nom
    FROM #Noms
    WHERE Idx = 1 + (n.N % 25)
) nm
WHERE n.N <= 90;


/* =========================================================================
   Fournisseurs internationaux : 60
   ========================================================================= */

INSERT INTO Dim_Fournisseur
(
    FournisseurID,
    NomFournisseur,
    Pays,
    TypeFournisseur,
    NoteQualite,
    DelaiLivraisonMoyenJours
)
SELECT
    n.N,
    'Global Foods Import '
    + p.Pays
    + ' '
    + CAST(n.N AS VARCHAR(10)),
    p.Pays,
    'International',
    CAST
    (
        2 + (ABS(CHECKSUM(NEWID())) % 80) / 10.0
        AS DECIMAL(3,1)
    ),
    5 + ABS(CHECKSUM(NEWID())) % 45
FROM dbo.Numbers n
CROSS APPLY
(
    SELECT Pays
    FROM
    (
        VALUES
        ('France'),
        ('Belgique'),
        ('Pays-Bas'),
        ('Chine'),
        ('Thaïlande'),
        ('Inde'),
        ('Brésil'),
        ('Sénégal'),
        ('Ghana'),
        ('Maroc'),
        ('Afrique du Sud'),
        ('Vietnam')
    ) AS t(Pays)
    ORDER BY (SELECT NULL)
    OFFSET (n.N % 12) ROWS
    FETCH NEXT 1 ROWS ONLY
) p
WHERE n.N > 90
  AND n.N <= 150;


/* =========================================================================
   Dim_Produit : 500 produits
   ========================================================================= */

IF OBJECT_ID('tempdb..#Stems') IS NOT NULL
    DROP TABLE #Stems;

CREATE TABLE #Stems
(
    CategorieID INT,
    Stem VARCHAR(60)
);

INSERT INTO #Stems
(
    CategorieID,
    Stem
)
VALUES
(1,'Riz parfumé'),
(1,'Riz étuvé'),
(1,'Riz brisé'),
(1,'Riz long grain'),
(1,'Riz local'),
(2,'Huile de palme'),
(2,'Huile d''arachide'),
(2,'Huile végétale'),
(2,'Huile de tournesol'),
(2,'Huile de coprah'),
(3,'Sucre en poudre'),
(3,'Sucre morceaux'),
(3,'Sucre roux'),
(3,'Sucre en sachet'),
(4,'Jus de fruit'),
(4,'Eau minérale'),
(4,'Boisson gazeuse'),
(4,'Boisson énergisante'),
(4,'Sirop'),
(4,'Bissap'),
(5,'Tomate concentrée'),
(5,'Sardine en boîte'),
(5,'Maquereau en boîte'),
(5,'Corned-beef'),
(5,'Petits pois en boîte'),
(6,'Poulet frais'),
(6,'Poisson frais'),
(6,'Légumes frais'),
(6,'Fruits frais'),
(6,'Œufs frais'),
(7,'Lait en poudre'),
(7,'Lait concentré'),
(7,'Yaourt'),
(7,'Fromage fondu'),
(7,'Beurre'),
(8,'Pâtes alimentaires'),
(8,'Spaghetti'),
(8,'Farine de blé'),
(8,'Farine de maïs'),
(8,'Semoule'),
(8,'Attiéké'),
(9,'Cube bouillon'),
(9,'Sel de cuisine'),
(9,'Sauce tomate'),
(9,'Mayonnaise'),
(9,'Vinaigre'),
(10,'Biscuits'),
(10,'Bonbons'),
(10,'Chocolat en poudre'),
(10,'Confiture'),
(10,'Café soluble'),
(11,'Savon'),
(11,'Détergent'),
(11,'Eau de javel'),
(11,'Papier hygiénique'),
(11,'Dentifrice'),
(12,'Piment moulu'),
(12,'Gingembre en poudre'),
(12,'Poivre'),
(12,'Curry'),
(12,'Arôme Maggi');


IF OBJECT_ID('tempdb..#Marques') IS NOT NULL
    DROP TABLE #Marques;

CREATE TABLE #Marques
(
    Marque VARCHAR(40)
);

INSERT INTO #Marques
VALUES
('Ivoire d''Or'),
('Sana'),
('Tropika'),
('Baobab'),
('Savana'),
('Lion d''Abidjan'),
('Cocody Gold'),
('Bandama'),
('Wassakara'),
('Ebrié'),
('Delta Sud'),
('Akwaba'),
('Fama'),
('Djolo'),
('Yamoussoukro Fresh'),
('Comoé Prime'),
('Bassam Bio'),
('Cavally Naturel'),
('Kôkô'),
('N''Zassa');


IF OBJECT_ID('tempdb..#Conditionnements') IS NOT NULL
    DROP TABLE #Conditionnements;

CREATE TABLE #Conditionnements
(
    Cond VARCHAR(30)
);

INSERT INTO #Conditionnements
VALUES
('250g'),
('500g'),
('1kg'),
('5kg'),
('25kg'),
('50kg'),
('1L'),
('1.5L'),
('5L'),
('20cl'),
('33cl'),
('sachet 400g'),
('carton 12x1L');


;WITH ProduitsAleatoires AS
(
    SELECT TOP (500)
        s.Stem + ' ' + m.Marque + ' ' + c.Cond AS NomProduit,
        s.CategorieID,
        m.Marque,
        c.Cond,
        CAST
        (
            cout.Cout
            * (
                1.15
                + (ABS(CHECKSUM(NEWID())) % 60) / 100.0
              )
            AS DECIMAL(10,2)
        ) AS PrixUnitaire,
        cout.Cout AS CoutUnitaire,
        1 + ABS(CHECKSUM(NEWID())) % 150 AS FournisseurID
    FROM #Stems s
    CROSS JOIN #Marques m
    CROSS JOIN #Conditionnements c
    CROSS APPLY
    (
        SELECT
            CAST
            (
                100 + ABS(CHECKSUM(NEWID())) % 15000
                AS DECIMAL(10,2)
            ) AS Cout
    ) cout
    ORDER BY NEWID()
)
INSERT INTO Dim_Produit
(
    ProduitID,
    NomProduit,
    CategorieID,
    Marque,
    Conditionnement,
    PrixUnitaire,
    CoutUnitaire,
    FournisseurID
)
SELECT
    ROW_NUMBER() OVER
    (
        ORDER BY (SELECT NULL)
    ) AS ProduitID,
    NomProduit,
    CategorieID,
    Marque,
    Cond,
    PrixUnitaire,
    CoutUnitaire,
    FournisseurID
FROM ProduitsAleatoires;


/* =========================================================================
   Anomalies intentionnelles sur les produits
   ========================================================================= */

UPDATE Dim_Produit
SET PrixUnitaire = NULL
WHERE ProduitID IN
(
    SELECT ProduitID
    FROM Dim_Produit
    WHERE ABS(CHECKSUM(NEWID())) % 100 < 2
);


UPDATE Dim_Produit
SET CoutUnitaire = -CoutUnitaire
WHERE ProduitID IN
(
    SELECT ProduitID
    FROM Dim_Produit
    WHERE ABS(CHECKSUM(NEWID())) % 100 < 1
);


/* =========================================================================
   Dim_Magasin : 150 magasins
   ========================================================================= */

IF OBJECT_ID('tempdb..#VillePool') IS NOT NULL
    DROP TABLE #VillePool;

SELECT
    VilleID,
    RegionID,
    NomVille,
    ROW_NUMBER() OVER
    (
        ORDER BY (SELECT NULL)
    ) AS PoolIdx
INTO #VillePool
FROM
(
    SELECT
        VilleID,
        RegionID,
        NomVille
    FROM Dim_Ville
    WHERE VilleID BETWEEN 109 AND 121

    UNION ALL

    SELECT
        VilleID,
        RegionID,
        NomVille
    FROM Dim_Ville
    WHERE VilleID BETWEEN 109 AND 121

    UNION ALL

    SELECT
        VilleID,
        RegionID,
        NomVille
    FROM Dim_Ville
    WHERE VilleID BETWEEN 109 AND 121

    UNION ALL

    SELECT
        VilleID,
        RegionID,
        NomVille
    FROM Dim_Ville
    WHERE VilleID NOT BETWEEN 109 AND 121
) AS pool;


ALTER TABLE #VillePool
ALTER COLUMN PoolIdx INT NOT NULL;

ALTER TABLE #VillePool
ADD CONSTRAINT PK_VillePool
PRIMARY KEY (PoolIdx);


INSERT INTO Dim_Magasin
(
    MagasinID,
    NomMagasin,
    VilleID,
    RegionID,
    TypeMagasin,
    Surface_m2
)
SELECT
    n.N,
    'Magasin '
    + vp.NomVille
    + ' #'
    + CAST(n.N AS VARCHAR(5)),
    vp.VilleID,
    vp.RegionID,
    CASE ABS(CHECKSUM(NEWID())) % 3
        WHEN 0 THEN 'Hypermarché'
        WHEN 1 THEN 'Supermarché'
        ELSE 'Supérette'
    END,
    150 + ABS(CHECKSUM(NEWID())) % 3850
FROM dbo.Numbers n
JOIN #VillePool vp
    ON vp.PoolIdx =
       1 + (
           (n.N - 1)
           % (SELECT COUNT(*) FROM #VillePool)
       )
WHERE n.N <= 150;


/* =========================================================================
   Dim_Entrepot : 15 entrepôts
   ========================================================================= */

INSERT INTO Dim_Entrepot
(
    EntrepotID,
    NomEntrepot,
    VilleID,
    RegionID,
    CapaciteM3
)
SELECT
    t.EntrepotID,
    'Entrepôt ' + t.NomVille,
    (
        SELECT TOP 1 VilleID
        FROM Dim_Ville
        WHERE NomVille = t.NomVille
    ),
    (
        SELECT TOP 1 RegionID
        FROM Dim_Ville
        WHERE NomVille = t.NomVille
    ),
    t.Capacite
FROM
(
    VALUES
    (1,  'Yopougon',           25000),
    (2,  'Koumassi',           18000),
    (3,  'Abobo',              20000),
    (4,  'San-Pédro',          15000),
    (5,  'Bouaké',             16000),
    (6,  'Korhogo',            12000),
    (7,  'Man',                10000),
    (8,  'Daloa',              11000),
    (9,  'Abengourou',          9000),
    (10, 'Odienné',             7000),
    (11, 'Bondoukou',           8000),
    (12, 'Gagnoa',              9500),
    (13, 'Divo',                7500),
    (14, 'Yamoussoukro',       13000),
    (15, 'Ferkessédougou',      6500)
) AS t
(
    EntrepotID,
    NomVille,
    Capacite
);


/* =========================================================================
   Dim_Client : 6 000 clients B2B
   ========================================================================= */

INSERT INTO Dim_Client
(
    ClientID,
    NomClient,
    TypeClient,
    VilleID,
    RegionID,
    Telephone
)
SELECT
    n.N,
    CASE ABS(CHECKSUM(NEWID())) % 4
        WHEN 0 THEN 'Supérette ' + CAST(n.N AS VARCHAR(10))
        WHEN 1 THEN 'Boutique ' + CAST(n.N AS VARCHAR(10))
        WHEN 2 THEN 'Grossiste ' + CAST(n.N AS VARCHAR(10))
        ELSE 'Restaurant ' + CAST(n.N AS VARCHAR(10))
    END,
    CASE ABS(CHECKSUM(NEWID())) % 4
        WHEN 0 THEN 'Supérette'
        WHEN 1 THEN 'Boutique'
        WHEN 2 THEN 'Grossiste'
        ELSE 'Restaurant'
    END,
    v.VilleID,
    v.RegionID,
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 3
            THEN NULL
        ELSE
            '+225 '
            + CAST
            (
                1000000000
                + ABS(CHECKSUM(NEWID())) % 899999999
                AS VARCHAR(15)
            )
    END
FROM dbo.Numbers n
JOIN Dim_Ville v
    ON v.VilleID =
       1 + ABS(CHECKSUM(NEWID())) % 122
WHERE n.N <= 6000;


/* =========================================================================
   Dim_Employe : 1 200 employés
   ========================================================================= */

INSERT INTO Dim_Employe
(
    EmployeID,
    Nom,
    Prenom,
    Poste,
    DateEmbauche,
    MagasinID,
    EntrepotID
)
SELECT
    n.N,
    (
        SELECT Nom
        FROM #Noms
        WHERE Idx =
              1 + ABS(CHECKSUM(NEWID())) % 25
    ),
    CASE ABS(CHECKSUM(NEWID())) % 10
        WHEN 0 THEN 'Aya'
        WHEN 1 THEN 'Adjoua'
        WHEN 2 THEN 'Kouadio'
        WHEN 3 THEN 'Affoué'
        WHEN 4 THEN 'Yao'
        WHEN 5 THEN 'Akissi'
        WHEN 6 THEN 'Kouamé'
        WHEN 7 THEN 'Amenan'
        WHEN 8 THEN 'Konan'
        ELSE 'Awa'
    END,
    CASE ABS(CHECKSUM(NEWID())) % 5
        WHEN 0 THEN 'Vendeur'
        WHEN 1 THEN 'Caissier'
        WHEN 2 THEN 'Magasinier'
        WHEN 3 THEN 'Responsable Rayon'
        ELSE 'Chef de Dépôt'
    END,
    DATEADD
    (
        DAY,
        ABS(CHECKSUM(NEWID())) % 3650,
        '2015-01-01'
    ),
    CASE
        WHEN n.N % 7 <> 0
            THEN 1 + ABS(CHECKSUM(NEWID())) % 150
        ELSE NULL
    END,
    CASE
        WHEN n.N % 7 = 0
            THEN 1 + ABS(CHECKSUM(NEWID())) % 15
        ELSE NULL
    END
FROM dbo.Numbers n
WHERE n.N <= 1200;


/* =========================================================================
   Dim_Date : 2021-01-01 au 2025-12-31
   ========================================================================= */

INSERT INTO Dim_Date
(
    DateID,
    DateComplete,
    Jour,
    Mois,
    NomMois,
    Trimestre,
    Annee,
    JourSemaine,
    EstWeekend,
    Semaine
)
SELECT
    CAST
    (
        CONVERT
        (
            VARCHAR(8),
            DATEADD
            (
                DAY,
                n.N - 1,
                '2021-01-01'
            ),
            112
        )
        AS INT
    ),
    DATEADD
    (
        DAY,
        n.N - 1,
        '2021-01-01'
    ),
    DAY
    (
        DATEADD
        (
            DAY,
            n.N - 1,
            '2021-01-01'
        )
    ),
    MONTH
    (
        DATEADD
        (
            DAY,
            n.N - 1,
            '2021-01-01'
        )
    ),
    DATENAME
    (
        MONTH,
        DATEADD
        (
            DAY,
            n.N - 1,
            '2021-01-01'
        )
    ),
    DATEPART
    (
        QUARTER,
        DATEADD
        (
            DAY,
            n.N - 1,
            '2021-01-01'
        )
    ),
    YEAR
    (
        DATEADD
        (
            DAY,
            n.N - 1,
            '2021-01-01'
        )
    ),
    DATENAME
    (
        WEEKDAY,
        DATEADD
        (
            DAY,
            n.N - 1,
            '2021-01-01'
        )
    ),
    CASE
        WHEN DATEPART
        (
            WEEKDAY,
            DATEADD
            (
                DAY,
                n.N - 1,
                '2021-01-01'
            )
        ) IN (6,7)
            THEN 1
        ELSE 0
    END,
    DATEPART
    (
        WEEK,
        DATEADD
        (
            DAY,
            n.N - 1,
            '2021-01-01'
        )
    )
FROM dbo.Numbers n
WHERE n.N <= 1826;


/* =========================================================================
   TABLES DE FAITS
   ========================================================================= */


/* =========================================================================
   Fact_Ventes : 301 500 lignes
   ========================================================================= */

INSERT INTO Fact_Ventes
(
    VenteID,
    DateID,
    MagasinID,
    ProduitID,
    ClientID,
    EmployeID,
    Quantite,
    PrixUnitaireVente,
    MontantTotal,
    ModePaiement
)
SELECT
    n.N,
    CAST
    (
        CONVERT
        (
            VARCHAR(8),
            DATEADD
            (
                DAY,
                ABS(CHECKSUM(NEWID())) % 1826,
                '2021-01-01'
            ),
            112
        )
        AS INT
    ),
    1 + ABS(CHECKSUM(NEWID())) % 150,
    p.ProduitID,
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 200 = 0
            THEN 6500 + ABS(CHECKSUM(NEWID())) % 500
        ELSE
            1 + ABS(CHECKSUM(NEWID())) % 6000
    END,
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 250 = 0
            THEN NULL
        ELSE
            1 + ABS(CHECKSUM(NEWID())) % 1200
    END,
    qte.Q,
    p.PrixUnitaire,
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 1
            THEN NULL
        ELSE
            CAST
            (
                qte.Q * ISNULL(p.PrixUnitaire, 0)
                AS DECIMAL(14,2)
            )
    END,
    CASE ABS(CHECKSUM(NEWID())) % 5
        WHEN 0 THEN 'Especes'
        WHEN 1 THEN 'Mobile Money'
        WHEN 2 THEN 'Carte'
        WHEN 3 THEN 'Virement'
        ELSE NULL
    END
FROM dbo.Numbers n
CROSS APPLY
(
    SELECT TOP (1)
        ProduitID,
        PrixUnitaire
    FROM Dim_Produit
    ORDER BY NEWID()
) p
CROSS APPLY
(
    SELECT
        CASE
            WHEN ABS(CHECKSUM(NEWID())) % 120 = 0
                THEN -(
                    1 + ABS(CHECKSUM(NEWID())) % 30
                )
            ELSE
                1 + ABS(CHECKSUM(NEWID())) % 30
        END AS Q
) qte
WHERE n.N <= 300000;


/* =========================================================================
   Doublons volontaires
   ========================================================================= */

INSERT INTO Fact_Ventes
(
    VenteID,
    DateID,
    MagasinID,
    ProduitID,
    ClientID,
    EmployeID,
    Quantite,
    PrixUnitaireVente,
    MontantTotal,
    ModePaiement
)
SELECT TOP (1500)
    300000 + ROW_NUMBER() OVER
    (
        ORDER BY (SELECT NULL)
    ),
    DateID,
    MagasinID,
    ProduitID,
    ClientID,
    EmployeID,
    Quantite,
    PrixUnitaireVente,
    MontantTotal,
    ModePaiement
FROM Fact_Ventes
ORDER BY NEWID();


/* =========================================================================
   Fact_Stock : 70 000 lignes
   ========================================================================= */

INSERT INTO Fact_Stock
(
    StockID,
    DateID,
    ProduitID,
    MagasinID,
    EntrepotID,
    QuantiteStock,
    SeuilAlerte
)
SELECT
    n.N,
    CAST
    (
        CONVERT
        (
            VARCHAR(8),
            DATEADD
            (
                DAY,
                ABS(CHECKSUM(NEWID())) % 1826,
                '2021-01-01'
            ),
            112
        )
        AS INT
    ),
    1 + ABS(CHECKSUM(NEWID())) % 500,
    CASE
        WHEN n.N % 5 <> 0
            THEN 1 + ABS(CHECKSUM(NEWID())) % 150
        ELSE NULL
    END,
    CASE
        WHEN n.N % 5 = 0
            THEN 1 + ABS(CHECKSUM(NEWID())) % 15
        ELSE NULL
    END,
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 150 = 0
            THEN -(
                ABS(CHECKSUM(NEWID())) % 50
            )
        ELSE
            ABS(CHECKSUM(NEWID())) % 3000
    END,
    10 + ABS(CHECKSUM(NEWID())) % 100
FROM dbo.Numbers n
WHERE n.N <= 70000;


/* =========================================================================
   Fact_Approvisionnement : 60 000 lignes
   ========================================================================= */

INSERT INTO Fact_Approvisionnement
(
    ApproID,
    DateID,
    ProduitID,
    FournisseurID,
    EntrepotID,
    QuantiteCommandee,
    CoutTotal,
    DelaiLivraisonJours
)
SELECT
    n.N,
    CAST
    (
        CONVERT
        (
            VARCHAR(8),
            DATEADD
            (
                DAY,
                ABS(CHECKSUM(NEWID())) % 1826,
                '2021-01-01'
            ),
            112
        )
        AS INT
    ),
    p.ProduitID,
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 180 = 0
            THEN 160 + ABS(CHECKSUM(NEWID())) % 30
        ELSE
            p.FournisseurID
    END,
    1 + ABS(CHECKSUM(NEWID())) % 15,
    qte.Q,
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 1
            THEN NULL
        ELSE
            CAST
            (
                qte.Q * ISNULL(p.CoutUnitaire, 0)
                AS DECIMAL(14,2)
            )
    END,
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 200 = 0
            THEN -(
                1 + ABS(CHECKSUM(NEWID())) % 5
            )
        ELSE
            2 + ABS(CHECKSUM(NEWID())) % 40
    END
FROM dbo.Numbers n
CROSS APPLY
(
    SELECT TOP (1)
        ProduitID,
        FournisseurID,
        CoutUnitaire
    FROM Dim_Produit
    ORDER BY NEWID()
) p
CROSS APPLY
(
    SELECT
        50 + ABS(CHECKSUM(NEWID())) % 2000 AS Q
) qte
WHERE n.N <= 60000;


/* =========================================================================
   Fact_Livraison : 40 000 lignes
   ========================================================================= */

INSERT INTO Fact_Livraison
(
    LivraisonID,
    DateID,
    EntrepotID,
    MagasinID,
    ProduitID,
    QuantiteLivree,
    DateLivraisonPrevue,
    DateLivraisonReelle,
    StatutLivraison
)
SELECT
    n.N,
    CAST
    (
        CONVERT
        (
            VARCHAR(8),
            p1.DPrevue,
            112
        )
        AS INT
    ),
    1 + ABS(CHECKSUM(NEWID())) % 15,
    1 + ABS(CHECKSUM(NEWID())) % 150,
    1 + ABS(CHECKSUM(NEWID())) % 500,
    1 + ABS(CHECKSUM(NEWID())) % 500,
    p1.DPrevue,
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 40 = 0
            THEN NULL
        ELSE
            p2.DReelle
    END,
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 40 = 0
            THEN 'En transit'
        WHEN ABS(CHECKSUM(NEWID())) % 300 = 0
            THEN 'Perdue'
        WHEN p2.DReelle > p1.DPrevue
            THEN 'Retardée'
        ELSE
            'Livrée'
    END
FROM dbo.Numbers n
CROSS APPLY
(
    SELECT
        DATEADD
        (
            DAY,
            ABS(CHECKSUM(NEWID())) % 1826,
            '2021-01-01'
        ) AS DPrevue
) p1
CROSS APPLY
(
    SELECT
        DATEADD
        (
            DAY,
            CASE
                WHEN ABS(CHECKSUM(NEWID())) % 100 < 3
                    THEN -(
                        1 + ABS(CHECKSUM(NEWID())) % 3
                    )
                ELSE
                    ABS(CHECKSUM(NEWID())) % 7
            END,
            p1.DPrevue
        ) AS DReelle
) p2
WHERE n.N <= 40000;


/* =========================================================================
   Fact_Retours : 20 000 lignes
   ========================================================================= */

INSERT INTO Fact_Retours
(
    RetourID,
    DateID,
    MagasinID,
    ProduitID,
    ClientID,
    QuantiteRetournee,
    MotifRetour,
    MontantRembourse
)
SELECT
    n.N,
    CAST
    (
        CONVERT
        (
            VARCHAR(8),
            DATEADD
            (
                DAY,
                ABS(CHECKSUM(NEWID())) % 1826,
                '2021-01-01'
            ),
            112
        )
        AS INT
    ),
    1 + ABS(CHECKSUM(NEWID())) % 150,
    p.ProduitID,
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 5 = 0
            THEN NULL
        ELSE
            1 + ABS(CHECKSUM(NEWID())) % 6000
    END,
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 130 = 0
            THEN -(
                1 + ABS(CHECKSUM(NEWID())) % 10
            )
        ELSE
            1 + ABS(CHECKSUM(NEWID())) % 15
    END,
    CASE ABS(CHECKSUM(NEWID())) % 5
        WHEN 0 THEN 'Produit périmé'
        WHEN 1 THEN 'Produit défectueux'
        WHEN 2 THEN 'Erreur de livraison'
        WHEN 3 THEN 'Emballage endommagé'
        ELSE 'Non conforme commande'
    END,
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 2
            THEN NULL
        ELSE
            CAST
            (
                (
                    1 + ABS(CHECKSUM(NEWID())) % 15
                )
                * ISNULL(p.PrixUnitaire, 0)
                AS DECIMAL(12,2)
            )
    END
FROM dbo.Numbers n
CROSS APPLY
(
    SELECT TOP (1)
        ProduitID,
        PrixUnitaire
    FROM Dim_Produit
    ORDER BY NEWID()
) p
WHERE n.N <= 20000;


/* =========================================================================
   NETTOYAGE
   ========================================================================= */

DROP TABLE dbo.Numbers;

DROP TABLE #Regions;
DROP TABLE #NomsVilles;
DROP TABLE #Noms;
DROP TABLE #Stems;
DROP TABLE #Marques;
DROP TABLE #Conditionnements;
DROP TABLE #VillePool;

GO