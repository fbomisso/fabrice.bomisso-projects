# 📦 CDCI Distribution BI | SQL Analytics & Data Quality

## 01. 🎯 Objectif du projet

Concevoir et analyser une base de données relationnelle représentant l’activité d’une entreprise de distribution afin de mettre en pratique une démarche complète d’analyse et de contrôle des données avec **SQL Server et T-SQL**.

Le projet couvre plusieurs étapes d’un workflow SQL :

- Modélisation d’une base de données relationnelle
- Création des tables de dimensions et de faits
- Chargement de données volumineuses
- Mise en place des clés étrangères
- Création d’index de performance
- Contrôle de la qualité des données
- Détection des anomalies métier
- Identification des références orphelines
- Détection des doublons
- Nettoyage et validation des données

L’objectif est de reproduire un environnement de données de distribution suffisamment réaliste pour travailler sur des problématiques proches de celles rencontrées en entreprise.

## 02. 🏢 Contexte métier

**CDCI Distribution** représente un environnement de distribution comprenant plusieurs composantes métier :

- Gestion des produits et catégories
- Gestion des fournisseurs
- Gestion des magasins
- Gestion des entrepôts
- Gestion des clients
- Gestion des employés
- Gestion des ventes
- Gestion des stocks
- Gestion des approvisionnements
- Gestion des livraisons
- Gestion des retours

La base permet notamment d'étudier les relations entre les différents référentiels et les transactions opérationnelles.

L'analyse porte également sur la **qualité et l'intégrité des données**, avec des anomalies volontairement introduites afin de simuler des situations pouvant apparaître dans des systèmes opérationnels.

## 03. 📊 Volumétrie des données

Le projet contient **16 tables** réparties entre dimensions et tables de faits.

| Table | Nombre de lignes |
|---|---:|
| `Fact_Ventes` | 301 500 |
| `Fact_Stock` | 70 000 |
| `Fact_Approvisionnement` | 60 000 |
| `Fact_Livraison` | 40 000 |
| `Fact_Retours` | 20 000 |
| `Dim_Client` | 6 000 |
| `Dim_Date` | 1 826 |
| `Dim_Employe` | 1 200 |
| `Dim_Produit` | 500 |
| `Dim_Fournisseur` | 150 |
| `Dim_Magasin` | 150 |
| `Dim_Ville` | 122 |
| `Dim_Departement` | 108 |
| `Dim_Region` | 31 |
| `Dim_Entrepot` | 15 |
| `Dim_Categorie` | 12 |

**Total : 502 644 lignes**

Cette volumétrie permet notamment de travailler sur des requêtes SQL appliquées à plusieurs centaines de milliers d'enregistrements.

## 04. 🗂️ Modèle de données

La base repose sur une organisation en **tables de dimensions** et **tables de faits**.

### Dimensions

- `Dim_Region` : référentiel des régions
- `Dim_Departement` : référentiel des départements
- `Dim_Ville` : référentiel des villes
- `Dim_Categorie` : catégories de produits
- `Dim_Produit` : catalogue des produits
- `Dim_Fournisseur` : fournisseurs
- `Dim_Magasin` : magasins
- `Dim_Entrepot` : entrepôts
- `Dim_Client` : clients
- `Dim_Employe` : employés
- `Dim_Date` : calendrier d'analyse

### Tables de faits

- `Fact_Ventes` : transactions de vente
- `Fact_Stock` : niveaux de stock
- `Fact_Approvisionnement` : opérations d'approvisionnement
- `Fact_Livraison` : opérations de livraison
- `Fact_Retours` : retours produits

Cette organisation permet de construire une structure relationnelle adaptée aux analyses multidimensionnelles et aux requêtes analytiques.

## 05. 🔗 Contraintes et index

Les relations entre les différentes tables sont assurées par des **clés étrangères**.

Le script `04_add_constraints.sql` met notamment en place les relations entre :

- Produits et catégories
- Produits et fournisseurs
- Magasins et villes
- Magasins et régions
- Entrepôts et villes
- Entrepôts et régions
- Clients et villes
- Clients et régions
- Employés et magasins
- Employés et entrepôts
- Tables de faits et dimensions associées

Au total, la base contient **34 contraintes de clés étrangères**.

Des index ont également été créés sur les principales colonnes utilisées pour les jointures et les analyses.

**15 index hors clés primaires** ont été créés.

L'utilisation de `WITH NOCHECK` permet de conserver les anomalies existantes lors de l'ajout des contraintes afin de pouvoir les analyser dans le cadre du contrôle de qualité.

## 06. 🔎 Audit de qualité des données

Le script `05_data_quality_queries.sql` réalise plusieurs contrôles.

### Valeurs NULL

Les contrôles portent notamment sur :

- Les prix produits
- Les coûts unitaires
- Les marques
- Les employés associés aux ventes
- Les montants des ventes
- Les modes de paiement
- Les localisations des stocks
- Les informations téléphoniques des clients

### Quantités négatives

Les contrôles identifient les valeurs incohérentes dans :

- `Fact_Ventes`
- `Fact_Stock`
- `Fact_Retours`

Les délais négatifs sont également contrôlés dans `Fact_Approvisionnement`.

### Prix aberrants

Le contrôle porte notamment sur :

- Les coûts unitaires négatifs
- Les prix de vente supérieurs à un seuil défini

### Dates incohérentes

Les livraisons sont contrôlées afin d'identifier les situations où :

`DateLivraisonReelle < DateLivraisonPrevue`

### Clés étrangères orphelines

Des contrôles spécifiques permettent d'identifier les références sans correspondance dans les dimensions parentes, notamment :

- `ClientID`
- `FournisseurID`

### Doublons

Les transactions de vente sont regroupées selon plusieurs attributs métier afin d'identifier les enregistrements présentant les mêmes caractéristiques transactionnelles.

## 07. 🧹 Nettoyage des données

Le script `06_data_cleaning_queries.sql` constitue l'étape de correction des anomalies identifiées lors de l'audit.

Le nettoyage permet de traiter les principales anomalies détectées dans les données et de vérifier leur disparition après correction.

Les contrôles réalisés après nettoyage ont retourné :

| Contrôle | Anomalies restantes |
|---|---:|
| Quantités négatives | 0 |
| Montants NULL | 0 |
| Clients orphelins | 0 |
| Stock sans localisation | 0 |
| Délais négatifs | 0 |
| Dates incohérentes | 0 |
| Retours négatifs | 0 |
| Prix NULL | 0 |
| Coûts négatifs | 0 |

Les résultats montrent que les anomalies ciblées ont été corrigées après le processus de nettoyage.

## 08. 📈 Résultats de l'analyse qualité

L'audit initial a permis d'identifier plusieurs catégories d'anomalies dans les données.

| Indicateur | Anomalies détectées |
|---|---:|
| Ventes avec quantité négative | 2 638 |
| Ventes avec montant NULL | 3 043 |
| Ventes avec client orphelin | 1 501 |
| Stocks avec quantité négative | 479 |
| Stocks sans localisation | 0 |
| Approvisionnements avec délai négatif | 282 |
| Livraisons avec date incohérente | 1 145 |
| Retours avec quantité négative | 149 |
| Produits avec prix NULL | 0 |
| Produits avec coût négatif | 0 |

Ces résultats illustrent l'intérêt d'intégrer un **contrôle de qualité des données** avant toute exploitation analytique.

## 09. 🛠️ Technologies utilisées

- **SGBD :** SQL Server
- **Langage :** T-SQL
- **IDE :** SQL Server Management Studio (SSMS)
- **Gestion des relations :** Primary Keys / Foreign Keys
- **Optimisation :** Index SQL
- **Contrôle qualité :** requêtes SQL d'audit
- **Nettoyage :** requêtes SQL de correction

## 10. 📁 Structure du projet

```text
02_Distribution/
├── README.md
├── 01_create_database.sql
├── 02_create_tables.sql
├── 03_insert_data.sql
├── 04_add_constraints.sql
├── 05_data_quality_queries.sql
└── 06_data_cleaning_queries.sql
```

Chaque script correspond à une étape du processus :

| Script | Rôle |
|---|---|
| `01_create_database.sql` | Création de la base de données |
| `02_create_tables.sql` | Création des tables |
| `03_insert_data.sql` | Chargement des données |
| `04_add_constraints.sql` | Ajout des contraintes et index |
| `05_data_quality_queries.sql` | Audit de qualité |
| `06_data_cleaning_queries.sql` | Nettoyage et correction |

## 11. 🚀 Utilisation

### 1. Créer la base

Exécuter :

```text
01_create_database.sql
```

Ce script crée la base de données `CDCI_Distribution`.

### 2. Créer les tables

Exécuter :

```text
02_create_tables.sql
```

Ce script crée les dimensions et les tables de faits.

### 3. Charger les données

Exécuter :

```text
03_insert_data.sql
```

Ce script charge les données dans les différentes tables.

### 4. Ajouter les contraintes et index

Exécuter :

```text
04_add_constraints.sql
```

Ce script crée les relations entre les tables ainsi que les index nécessaires aux principales opérations de jointure.

### 5. Auditer la qualité

Exécuter :

```text
05_data_quality_queries.sql
```

Ce script permet d'identifier les anomalies présentes dans les données.

### 6. Nettoyer les données

Exécuter :

```text
06_data_cleaning_queries.sql
```

Ce script corrige les anomalies identifiées puis permet de vérifier la qualité finale des données.

## 12. 💡 Compétences SQL démontrées

Ce projet met en pratique plusieurs compétences techniques :

- Création et structuration d'une base relationnelle
- `CREATE DATABASE`
- `CREATE TABLE`
- `PRIMARY KEY`
- `FOREIGN KEY`
- `ALTER TABLE`
- `WITH NOCHECK`
- `CREATE INDEX`
- `SELECT`
- `WHERE`
- `JOIN`
- `LEFT JOIN`
- `UNION ALL`
- `GROUP BY`
- `COUNT`
- `COUNT(DISTINCT)`
- `MIN` / `MAX`
- CTE
- Sous-requêtes
- Agrégations
- Contrôles de cohérence
- Analyse des valeurs NULL
- Détection des doublons
- Détection des clés orphelines
- Data Quality
- Data Cleaning
- Optimisation des requêtes par index

## 13. 🎯 Ce que ce projet démontre

Ce projet montre ma capacité à construire un environnement de données relationnel avec **SQL Server**, depuis la création de la base jusqu'au contrôle et au nettoyage des données.

Il démontre également une approche orientée **Data Quality**, consistant à ne pas considérer les données comme directement exploitables, mais à :

**Charger → Contrôler → Identifier → Corriger → Vérifier**

L'objectif est de produire des données suffisamment fiables pour servir ensuite de base à des analyses décisionnelles.