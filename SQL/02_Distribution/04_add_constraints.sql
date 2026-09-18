/* =========================================================================
   04_add_constraints.sql
   CDCI Distribution - Contraintes et index
   ========================================================================= */

SET NOCOUNT ON;
GO

USE [CDCI_Distribution];
GO


/* =========================================================================
   Clés étrangères - dimensions
   ========================================================================= */

ALTER TABLE Dim_Departement WITH NOCHECK
ADD CONSTRAINT FK_Dept_Region
FOREIGN KEY (RegionID)
REFERENCES Dim_Region(RegionID);

ALTER TABLE Dim_Ville WITH NOCHECK
ADD CONSTRAINT FK_Ville_Region
FOREIGN KEY (RegionID)
REFERENCES Dim_Region(RegionID);

ALTER TABLE Dim_Ville WITH NOCHECK
ADD CONSTRAINT FK_Ville_Dept
FOREIGN KEY (DepartementID)
REFERENCES Dim_Departement(DepartementID);

ALTER TABLE Dim_Produit WITH NOCHECK
ADD CONSTRAINT FK_Produit_Categorie
FOREIGN KEY (CategorieID)
REFERENCES Dim_Categorie(CategorieID);

ALTER TABLE Dim_Produit WITH NOCHECK
ADD CONSTRAINT FK_Produit_Fournisseur
FOREIGN KEY (FournisseurID)
REFERENCES Dim_Fournisseur(FournisseurID);

ALTER TABLE Dim_Magasin WITH NOCHECK
ADD CONSTRAINT FK_Magasin_Ville
FOREIGN KEY (VilleID)
REFERENCES Dim_Ville(VilleID);

ALTER TABLE Dim_Magasin WITH NOCHECK
ADD CONSTRAINT FK_Magasin_Region
FOREIGN KEY (RegionID)
REFERENCES Dim_Region(RegionID);

ALTER TABLE Dim_Entrepot WITH NOCHECK
ADD CONSTRAINT FK_Entrepot_Ville
FOREIGN KEY (VilleID)
REFERENCES Dim_Ville(VilleID);

ALTER TABLE Dim_Entrepot WITH NOCHECK
ADD CONSTRAINT FK_Entrepot_Region
FOREIGN KEY (RegionID)
REFERENCES Dim_Region(RegionID);

ALTER TABLE Dim_Client WITH NOCHECK
ADD CONSTRAINT FK_Client_Ville
FOREIGN KEY (VilleID)
REFERENCES Dim_Ville(VilleID);

ALTER TABLE Dim_Client WITH NOCHECK
ADD CONSTRAINT FK_Client_Region
FOREIGN KEY (RegionID)
REFERENCES Dim_Region(RegionID);

ALTER TABLE Dim_Employe WITH NOCHECK
ADD CONSTRAINT FK_Employe_Magasin
FOREIGN KEY (MagasinID)
REFERENCES Dim_Magasin(MagasinID);

ALTER TABLE Dim_Employe WITH NOCHECK
ADD CONSTRAINT FK_Employe_Entrepot
FOREIGN KEY (EntrepotID)
REFERENCES Dim_Entrepot(EntrepotID);


/* =========================================================================
   Clés étrangères - tables de faits
   ========================================================================= */

ALTER TABLE Fact_Ventes WITH NOCHECK
ADD CONSTRAINT FK_Ventes_Date
FOREIGN KEY (DateID)
REFERENCES Dim_Date(DateID);

ALTER TABLE Fact_Ventes WITH NOCHECK
ADD CONSTRAINT FK_Ventes_Magasin
FOREIGN KEY (MagasinID)
REFERENCES Dim_Magasin(MagasinID);

ALTER TABLE Fact_Ventes WITH NOCHECK
ADD CONSTRAINT FK_Ventes_Produit
FOREIGN KEY (ProduitID)
REFERENCES Dim_Produit(ProduitID);

ALTER TABLE Fact_Ventes WITH NOCHECK
ADD CONSTRAINT FK_Ventes_Client
FOREIGN KEY (ClientID)
REFERENCES Dim_Client(ClientID);

ALTER TABLE Fact_Ventes WITH NOCHECK
ADD CONSTRAINT FK_Ventes_Employe
FOREIGN KEY (EmployeID)
REFERENCES Dim_Employe(EmployeID);

ALTER TABLE Fact_Stock WITH NOCHECK
ADD CONSTRAINT FK_Stock_Date
FOREIGN KEY (DateID)
REFERENCES Dim_Date(DateID);

ALTER TABLE Fact_Stock WITH NOCHECK
ADD CONSTRAINT FK_Stock_Produit
FOREIGN KEY (ProduitID)
REFERENCES Dim_Produit(ProduitID);

ALTER TABLE Fact_Stock WITH NOCHECK
ADD CONSTRAINT FK_Stock_Magasin
FOREIGN KEY (MagasinID)
REFERENCES Dim_Magasin(MagasinID);

ALTER TABLE Fact_Stock WITH NOCHECK
ADD CONSTRAINT FK_Stock_Entrepot
FOREIGN KEY (EntrepotID)
REFERENCES Dim_Entrepot(EntrepotID);

ALTER TABLE Fact_Approvisionnement WITH NOCHECK
ADD CONSTRAINT FK_Appro_Date
FOREIGN KEY (DateID)
REFERENCES Dim_Date(DateID);

ALTER TABLE Fact_Approvisionnement WITH NOCHECK
ADD CONSTRAINT FK_Appro_Produit
FOREIGN KEY (ProduitID)
REFERENCES Dim_Produit(ProduitID);

ALTER TABLE Fact_Approvisionnement WITH NOCHECK
ADD CONSTRAINT FK_Appro_Fournisseur
FOREIGN KEY (FournisseurID)
REFERENCES Dim_Fournisseur(FournisseurID);

ALTER TABLE Fact_Approvisionnement WITH NOCHECK
ADD CONSTRAINT FK_Appro_Entrepot
FOREIGN KEY (EntrepotID)
REFERENCES Dim_Entrepot(EntrepotID);

ALTER TABLE Fact_Livraison WITH NOCHECK
ADD CONSTRAINT FK_Livraison_Date
FOREIGN KEY (DateID)
REFERENCES Dim_Date(DateID);

ALTER TABLE Fact_Livraison WITH NOCHECK
ADD CONSTRAINT FK_Livraison_Entrepot
FOREIGN KEY (EntrepotID)
REFERENCES Dim_Entrepot(EntrepotID);

ALTER TABLE Fact_Livraison WITH NOCHECK
ADD CONSTRAINT FK_Livraison_Magasin
FOREIGN KEY (MagasinID)
REFERENCES Dim_Magasin(MagasinID);

ALTER TABLE Fact_Livraison WITH NOCHECK
ADD CONSTRAINT FK_Livraison_Produit
FOREIGN KEY (ProduitID)
REFERENCES Dim_Produit(ProduitID);

ALTER TABLE Fact_Retours WITH NOCHECK
ADD CONSTRAINT FK_Retours_Date
FOREIGN KEY (DateID)
REFERENCES Dim_Date(DateID);

ALTER TABLE Fact_Retours WITH NOCHECK
ADD CONSTRAINT FK_Retours_Magasin
FOREIGN KEY (MagasinID)
REFERENCES Dim_Magasin(MagasinID);

ALTER TABLE Fact_Retours WITH NOCHECK
ADD CONSTRAINT FK_Retours_Produit
FOREIGN KEY (ProduitID)
REFERENCES Dim_Produit(ProduitID);

ALTER TABLE Fact_Retours WITH NOCHECK
ADD CONSTRAINT FK_Retours_Client
FOREIGN KEY (ClientID)
REFERENCES Dim_Client(ClientID);


/* =========================================================================
   Index de performance
   ========================================================================= */

CREATE INDEX IX_Ventes_Date
ON Fact_Ventes(DateID);

CREATE INDEX IX_Ventes_Produit
ON Fact_Ventes(ProduitID);

CREATE INDEX IX_Ventes_Magasin
ON Fact_Ventes(MagasinID);

CREATE INDEX IX_Ventes_Client
ON Fact_Ventes(ClientID);

CREATE INDEX IX_Stock_Produit
ON Fact_Stock(ProduitID);

CREATE INDEX IX_Stock_Date
ON Fact_Stock(DateID);

CREATE INDEX IX_Appro_Fournisseur
ON Fact_Approvisionnement(FournisseurID);

CREATE INDEX IX_Appro_Date
ON Fact_Approvisionnement(DateID);

CREATE INDEX IX_Appro_Produit
ON Fact_Approvisionnement(ProduitID);

CREATE INDEX IX_Livraison_Date
ON Fact_Livraison(DateID);

CREATE INDEX IX_Livraison_Entrepot
ON Fact_Livraison(EntrepotID);

CREATE INDEX IX_Livraison_Magasin
ON Fact_Livraison(MagasinID);

CREATE INDEX IX_Retours_Date
ON Fact_Retours(DateID);

CREATE INDEX IX_Retours_Magasin
ON Fact_Retours(MagasinID);

CREATE INDEX IX_Retours_Produit
ON Fact_Retours(ProduitID);


/* =========================================================================
   Vérification
   ========================================================================= */

SELECT
    'Contraintes FK' AS ObjetType,
    COUNT(*) AS Nombre
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'dbo'
  AND CONSTRAINT_TYPE = 'FOREIGN KEY'

UNION ALL

SELECT
    'Index hors PK' AS ObjetType,
    COUNT(*) AS Nombre
FROM sys.indexes
WHERE object_id IN (
    SELECT object_id
    FROM sys.tables
    WHERE type = 'U'
)
AND name NOT LIKE 'PK_%'
AND type <> 0;
GO