-- ============================================
-- CRÉATION DE LA BASE DE DONNÉES DATALENS
-- Projet Portfolio SaaS Analytics
-- ============================================

-- Créer la base de données
CREATE DATABASE DataLens;
GO

USE DataLens;
GO

-- ============================================
-- TABLE 1 : PLANS
-- ============================================
CREATE TABLE PLANS (
    id_plan INT PRIMARY KEY IDENTITY(1,1),
    nom_plan VARCHAR(50) NOT NULL UNIQUE,
    prix_catalogue DECIMAL(10, 2) NOT NULL CHECK (prix_catalogue >= 0),
    nb_utilisateurs_max INT NOT NULL CHECK (nb_utilisateurs_max = -1 OR nb_utilisateurs_max > 0),
    nb_sources_donnees_max INT NOT NULL CHECK (nb_sources_donnees_max = -1 OR nb_sources_donnees_max > 0),
    nb_lignes_max BIGINT NOT NULL CHECK (nb_lignes_max = -1 OR nb_lignes_max > 0)
);
GO

-- ============================================
-- TABLE 2 : ENTREPRISES
-- ============================================
CREATE TABLE ENTREPRISES (
    id_entreprise INT PRIMARY KEY IDENTITY(1,1),
    nom_entreprise VARCHAR(255) NOT NULL,
    pays CHAR(2) NULL,
    secteur_activite VARCHAR(100) NULL,
    date_inscription DATE NOT NULL CHECK (date_inscription <= CAST(GETDATE() AS DATE))
);
GO

-- ============================================
-- TABLE 3 : ABONNEMENTS
-- ============================================
CREATE TABLE ABONNEMENTS (
    id_abonnement INT PRIMARY KEY IDENTITY(1,1),
    id_entreprise INT NOT NULL,
    id_plan INT NOT NULL,
    date_debut DATE NOT NULL,
    date_fin DATE NULL,
    prix_mensuel DECIMAL(10, 2) NOT NULL CHECK (prix_mensuel >= 0),
    CONSTRAINT FK_ABONNEMENTS_ENTREPRISES FOREIGN KEY (id_entreprise) REFERENCES ENTREPRISES(id_entreprise),
    CONSTRAINT FK_ABONNEMENTS_PLANS FOREIGN KEY (id_plan) REFERENCES PLANS(id_plan),
    CONSTRAINT CHK_DATES_ABONNEMENT CHECK (date_fin IS NULL OR date_fin >= date_debut)
);
GO

-- ============================================
-- TABLE 4 : UTILISATEURS
-- ============================================
CREATE TABLE UTILISATEURS (
    id_utilisateur INT PRIMARY KEY IDENTITY(1,1),
    id_entreprise INT NOT NULL,
    nom_utilisateur VARCHAR(255) NOT NULL,
    role_actuel VARCHAR(50) NULL,
    date_inscription DATE NOT NULL,
    date_depart DATE NULL,
    CONSTRAINT FK_UTILISATEURS_ENTREPRISES FOREIGN KEY (id_entreprise) REFERENCES ENTREPRISES(id_entreprise),
    CONSTRAINT CHK_DATES_UTILISATEUR CHECK (date_depart IS NULL OR date_depart >= date_inscription)
);
GO

-- ============================================
-- TABLE 5 : ACTIVITE
-- ============================================
CREATE TABLE ACTIVITE (
    id_utilisateur INT NOT NULL,
    date_activite DATE NOT NULL,
    nb_connexions INT NOT NULL DEFAULT 0 CHECK (nb_connexions >= 0),
    nb_requetes INT NOT NULL DEFAULT 0 CHECK (nb_requetes >= 0),
    nb_tableaux_bord INT NOT NULL DEFAULT 0 CHECK (nb_tableaux_bord >= 0),
    nb_fonctionnalites_utilisees INT NOT NULL DEFAULT 0 CHECK (nb_fonctionnalites_utilisees >= 0),
    PRIMARY KEY (id_utilisateur, date_activite),
    CONSTRAINT FK_ACTIVITE_UTILISATEURS FOREIGN KEY (id_utilisateur) REFERENCES UTILISATEURS(id_utilisateur)
);
GO

-- ============================================
-- TABLE 6 : FACTURES
-- ============================================
CREATE TABLE FACTURES (
    id_facture INT PRIMARY KEY IDENTITY(1,1),
    id_entreprise INT NOT NULL,
    date_facture DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    montant_total DECIMAL(10, 2) NOT NULL CHECK (montant_total >= 0),
    statut VARCHAR(20) NOT NULL DEFAULT 'En attente',
    CONSTRAINT FK_FACTURES_ENTREPRISES FOREIGN KEY (id_entreprise) REFERENCES ENTREPRISES(id_entreprise)
);
GO

-- ============================================
-- TABLE 7 : LIGNES_FACTURE
-- ============================================
CREATE TABLE LIGNES_FACTURE (
    id_ligne_facture INT PRIMARY KEY IDENTITY(1,1),
    id_facture INT NOT NULL,
    id_abonnement INT NOT NULL,
    description VARCHAR(255) NOT NULL,
    date_debut_facturee DATE NOT NULL,
    date_fin_facturee DATE NOT NULL,
    quantite INT NOT NULL DEFAULT 1,
    prix_unitaire DECIMAL(10, 2) NOT NULL CHECK (prix_unitaire >= 0),
    montant DECIMAL(10, 2) NOT NULL CHECK (montant >= 0),
    CONSTRAINT FK_LIGNES_FACTURE_FACTURES FOREIGN KEY (id_facture) REFERENCES FACTURES(id_facture),
    CONSTRAINT FK_LIGNES_FACTURE_ABONNEMENTS FOREIGN KEY (id_abonnement) REFERENCES ABONNEMENTS(id_abonnement),
    CONSTRAINT CHK_DATES_LIGNE CHECK (date_fin_facturee >= date_debut_facturee)
);
GO

-- ============================================
-- TABLE 8 : TICKETS_SUPPORT
-- ============================================
CREATE TABLE TICKETS_SUPPORT (
    id_ticket INT PRIMARY KEY IDENTITY(1,1),
    id_entreprise INT NOT NULL,
    date_creation DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    date_resolution DATETIME2 NULL,
    categorie VARCHAR(50) NOT NULL,
    priorite VARCHAR(20) NOT NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'Ouvert',
    CONSTRAINT FK_TICKETS_SUPPORT_ENTREPRISES FOREIGN KEY (id_entreprise) REFERENCES ENTREPRISES(id_entreprise)
);
GO

-- ============================================
-- INDEX POUR OPTIMISER LES PERFORMANCES
-- ============================================
CREATE INDEX IDX_ABONNEMENTS_ENTREPRISE ON ABONNEMENTS(id_entreprise);
CREATE INDEX IDX_ABONNEMENTS_PLAN ON ABONNEMENTS(id_plan);
CREATE INDEX IDX_ABONNEMENTS_DATES ON ABONNEMENTS(date_debut, date_fin);

CREATE INDEX IDX_UTILISATEURS_ENTREPRISE ON UTILISATEURS(id_entreprise);
CREATE INDEX IDX_UTILISATEURS_DATES ON UTILISATEURS(date_inscription, date_depart);

CREATE INDEX IDX_FACTURES_ENTREPRISE ON FACTURES(id_entreprise);

CREATE INDEX IDX_LIGNES_FACTURE_FACTURE ON LIGNES_FACTURE(id_facture);
CREATE INDEX IDX_LIGNES_FACTURE_ABONNEMENT ON LIGNES_FACTURE(id_abonnement);

CREATE INDEX IDX_TICKETS_SUPPORT_ENTREPRISE ON TICKETS_SUPPORT(id_entreprise);

GO

-- ============================================
-- INSERTION DES DONNÉES DE TEST
-- ============================================

-- Insérer les plans
INSERT INTO PLANS (
    nom_plan,
    prix_catalogue,
    nb_utilisateurs_max,
    nb_sources_donnees_max,
    nb_lignes_max
)
VALUES 
    ('Formule de démarrage', 99.00, 1, 1, 100000),
    ('Professionnel', 499.00, 5, 3, 1000000),
    ('Entreprise', 1999.00, -1, -1, -1);
GO

-- Insérer les entreprises
INSERT INTO ENTREPRISES (
    nom_entreprise,
    pays,
    secteur_activite,
    date_inscription
)
VALUES 
    ('DataViz Inc', 'US', 'Technologie', '2024-01-15'),
    ('Analytics Pro', 'FR', 'Conseil', '2024-03-20'),
    ('Business Intelligence Co', 'DE', 'Logiciels', '2024-06-10'),
    ('Startup Data', 'CA', 'Intelligence artificielle', '2024-09-05');
GO

-- Insérer les abonnements
INSERT INTO ABONNEMENTS (
    id_entreprise,
    id_plan,
    date_debut,
    date_fin,
    prix_mensuel
)
VALUES 
    (1, 1, '2024-01-15', '2024-03-31', 99.00),
    (1, 2, '2024-04-01', NULL, 499.00),
    (2, 2, '2024-03-20', '2024-09-30', 499.00),
    (3, 2, '2024-06-10', NULL, 499.00),
    (4, 1, '2024-09-05', NULL, 99.00);
GO

-- Insérer les utilisateurs
INSERT INTO UTILISATEURS (
    id_entreprise,
    nom_utilisateur,
    role_actuel,
    date_inscription,
    date_depart
)
VALUES 
    (1, 'Alice Martin', 'Administrateur', '2024-01-15', NULL),
    (1, 'Bob Dupont', 'Analyste', '2024-01-20', NULL),
    (1, 'Charlie Moreau', 'Lecteur', '2024-02-10', NULL),
    (2, 'Diana Laurent', 'Administrateur', '2024-03-20', NULL),
    (2, 'Eric Rousseau', 'Analyste', '2024-04-05', '2024-08-15'),
    (3, 'Fiona Dubois', 'Administrateur', '2024-06-10', NULL),
    (3, 'Georges Petit', 'Analyste', '2024-06-15', NULL),
    (3, 'Hélène Lefevre', 'Lecteur', '2024-07-01', NULL),
    (4, 'Isabelle Mercier', 'Administrateur', '2024-09-05', NULL);
GO

-- Insérer les activités
INSERT INTO ACTIVITE (
    id_utilisateur,
    date_activite,
    nb_connexions,
    nb_requetes,
    nb_tableaux_bord,
    nb_fonctionnalites_utilisees
)
VALUES 
    (1, '2024-12-15', 2, 5, 1, 3),
    (1, '2024-12-16', 3, 8, 0, 2),
    (1, '2024-12-17', 1, 3, 1, 1),
    (2, '2024-12-15', 1, 2, 0, 1),
    (2, '2024-12-16', 2, 4, 0, 2),
    (3, '2024-12-17', 0, 0, 0, 0),
    (3, '2024-12-15', 1, 1, 0, 0),
    (4, '2024-12-15', 3, 10, 2, 4),
    (4, '2024-12-16', 2, 6, 1, 2),
    (5, '2024-07-15', 1, 1, 0, 1),
    (5, '2024-07-16', 0, 0, 0, 0),
    (6, '2024-12-16', 4, 15, 3, 5),
    (6, '2024-12-17', 2, 8, 1, 3),
    (7, '2024-12-15', 2, 5, 1, 2),
    (7, '2024-12-17', 1, 3, 0, 1),
    (8, '2024-12-15', 1, 0, 0, 0),
    (9, '2024-09-05', 1, 2, 1, 1),
    (9, '2024-12-15', 2, 4, 1, 2);
GO

-- Insérer les factures
INSERT INTO FACTURES (
    id_entreprise,
    date_facture,
    montant_total,
    statut
)
VALUES 
    (1, '2024-01-31', 99.00, 'Payée'),
    (1, '2024-02-29', 99.00, 'Payée'),
    (1, '2024-03-31', 99.00, 'Payée'),
    (1, '2024-04-30', 499.00, 'Payée'),
    (1, '2024-05-31', 499.00, 'Payée'),
    (1, '2024-12-15', 499.00, 'En attente'),
    (2, '2024-03-31', 499.00, 'Payée'),
    (2, '2024-04-30', 499.00, 'Payée'),
    (2, '2024-05-31', 499.00, 'Payée'),
    (2, '2024-06-30', 499.00, 'Payée'),
    (2, '2024-07-31', 499.00, 'Payée'),
    (2, '2024-08-31', 499.00, 'Payée'),
    (2, '2024-09-30', 499.00, 'Payée'),
    (3, '2024-06-30', 499.00, 'Payée'),
    (3, '2024-07-31', 499.00, 'Payée'),
    (3, '2024-08-31', 499.00, 'Payée'),
    (3, '2024-12-15', 499.00, 'En attente'),
    (4, '2024-09-30', 99.00, 'Payée'),
    (4, '2024-10-31', 99.00, 'Payée'),
    (4, '2024-12-15', 99.00, 'En attente');
GO

-- Insérer les lignes de facture
INSERT INTO LIGNES_FACTURE (
    id_facture,
    id_abonnement,
    description,
    date_debut_facturee,
    date_fin_facturee,
    quantite,
    prix_unitaire,
    montant
)
VALUES 
    (1, 1, 'Formule de démarrage - Janvier', '2024-01-15', '2024-01-31', 1, 99.00, 99.00),
    (2, 1, 'Formule de démarrage - Février', '2024-02-01', '2024-02-29', 1, 99.00, 99.00),
    (3, 1, 'Formule de démarrage - Mars', '2024-03-01', '2024-03-31', 1, 99.00, 99.00),
    (4, 2, 'Professionnel - Avril', '2024-04-01', '2024-04-30', 1, 499.00, 499.00),
    (5, 2, 'Professionnel - Mai', '2024-05-01', '2024-05-31', 1, 499.00, 499.00),
    (6, 2, 'Professionnel - Décembre', '2024-12-01', '2024-12-15', 1, 499.00, 499.00),
    (7, 3, 'Professionnel - Mars', '2024-03-20', '2024-03-31', 1, 499.00, 499.00),
    (8, 3, 'Professionnel - Avril', '2024-04-01', '2024-04-30', 1, 499.00, 499.00),
    (9, 3, 'Professionnel - Mai', '2024-05-01', '2024-05-31', 1, 499.00, 499.00),
    (10, 3, 'Professionnel - Juin', '2024-06-01', '2024-06-30', 1, 499.00, 499.00),
    (11, 3, 'Professionnel - Juillet', '2024-07-01', '2024-07-31', 1, 499.00, 499.00),
    (12, 3, 'Professionnel - Août', '2024-08-01', '2024-08-31', 1, 499.00, 499.00),
    (13, 3, 'Professionnel - Septembre', '2024-09-01', '2024-09-30', 1, 499.00, 499.00),
    (14, 4, 'Professionnel - Juin', '2024-06-10', '2024-06-30', 1, 499.00, 499.00),
    (15, 4, 'Professionnel - Juillet', '2024-07-01', '2024-07-31', 1, 499.00, 499.00),
    (16, 4, 'Professionnel - Août', '2024-08-01', '2024-08-31', 1, 499.00, 499.00),
    (17, 4, 'Professionnel - Décembre', '2024-12-01', '2024-12-15', 1, 499.00, 499.00),
    (18, 5, 'Formule de démarrage - Septembre', '2024-09-05', '2024-09-30', 1, 99.00, 99.00),
    (19, 5, 'Formule de démarrage - Octobre', '2024-10-01', '2024-10-31', 1, 99.00, 99.00),
    (20, 5, 'Formule de démarrage - Décembre', '2024-12-01', '2024-12-15', 1, 99.00, 99.00);
GO

-- Insérer les tickets support
INSERT INTO TICKETS_SUPPORT (
    id_entreprise,
    date_creation,
    date_resolution,
    categorie,
    priorite,
    statut
)
VALUES 
    (1, '2024-12-10 09:30:00', '2024-12-10 14:00:00', 'Bogue', 'Élevée', 'Résolu'),
    (1, '2024-12-15 11:00:00', '2024-12-15 16:30:00', 'Fonctionnalité', 'Moyenne', 'Résolu'),
    (1, '2024-12-17 08:15:00', NULL, 'Compte', 'Faible', 'Ouvert'),
    (2, '2024-08-20 10:00:00', NULL, 'Bogue', 'Élevée', 'Ouvert'),
    (2, '2024-09-10 14:30:00', NULL, 'Facturation', 'Élevée', 'Ouvert'),
    (3, '2024-11-05 09:00:00', '2024-11-05 11:30:00', 'Bogue', 'Moyenne', 'Résolu'),
    (3, '2024-12-01 16:00:00', '2024-12-02 10:00:00', 'Fonctionnalité', 'Faible', 'Résolu'),
    (3, '2024-12-15 13:45:00', NULL, 'Compte', 'Moyenne', 'Ouvert'),
    (4, '2024-09-15 10:00:00', '2024-09-15 12:00:00', 'Compte', 'Faible', 'Résolu'),
    (4, '2024-12-12 14:00:00', NULL, 'Fonctionnalité', 'Faible', 'Ouvert');
GO

-- ============================================
-- VÉRIFICATION : Afficher le nombre de lignes par table
-- ============================================

SELECT 'PLANS' AS table_nom, COUNT(*) AS nombre_lignes FROM PLANS
UNION ALL
SELECT 'ENTREPRISES', COUNT(*) FROM ENTREPRISES
UNION ALL
SELECT 'ABONNEMENTS', COUNT(*) FROM ABONNEMENTS
UNION ALL
SELECT 'UTILISATEURS', COUNT(*) FROM UTILISATEURS
UNION ALL
SELECT 'ACTIVITE', COUNT(*) FROM ACTIVITE
UNION ALL
SELECT 'FACTURES', COUNT(*) FROM FACTURES
UNION ALL
SELECT 'LIGNES_FACTURE', COUNT(*) FROM LIGNES_FACTURE
UNION ALL
SELECT 'TICKETS_SUPPORT', COUNT(*) FROM TICKETS_SUPPORT;

GO