# 📊 DataLens | SaaS Analytics

## 🎯 Objectif du projet

Concevoir et analyser une base de données relationnelle représentant une plateforme SaaS B2B spécialisée dans la Business Intelligence.

Le projet met en pratique plusieurs compétences en analyse de données et en SQL :

- Modélisation d'une base de données relationnelle
- SQL Server et langage T-SQL
- Requêtes `SELECT`, `JOIN` et agrégations
- CTE et fonctions de fenêtrage
- Construction et analyse de KPI
- Contrôle de la qualité et de l'intégrité des données
- Analyse du churn et identification des signaux de risque

## 📋 Contexte métier

**DataLens** est une plateforme cloud d'analytics self-service destinée aux PME et aux scale-ups.

Le service fonctionne sur un modèle d'abonnement mensuel avec trois plans :

- Formule de démarrage
- Professionnel
- Entreprise

L'analyse cherche notamment à répondre aux questions suivantes :

- Quel est le revenu récurrent mensuel (MRR) ?
- Quel est le taux de churn ?
- Quels facteurs peuvent signaler un risque de churn ?
- Quelles différences observe-t-on entre les clients fidèles et les clients ayant quitté la plateforme ?

## 📊 Résultats clés

| Métrique | Valeur |
|---|---:|
| **MRR total** | 1 097 € |
| **Clients actifs** | 3 |
| **Churn Rate** | 50 % |
| **Engagement moyen** | 26 requêtes/mois |
| **Tickets ouverts** | 4 |

### 🔍 Analyse du churn

L'analyse met en évidence une relation entre les tickets de support ouverts et le churn.

**Analytics Pro** comptait 2 tickets ouverts non résolus avant son départ en septembre.

Les trois autres entreprises, **DataViz Inc**, **Business Intelligence Co** et **Startup Data**, comptaient chacune 1 ticket ouvert et sont restées actives sur la période observée.

Ce résultat constitue un signal à surveiller, mais le volume de données reste limité pour établir une relation statistique robuste entre les tickets ouverts et le churn.

## 🗂️ Base de données

### Schéma relationnel

La base comprend 8 tables :

- `PLANS` : référentiel des plans d'abonnement
- `ENTREPRISES` : informations sur les entreprises clientes
- `ABONNEMENTS` : historique des abonnements, upgrades, downgrades et churn
- `UTILISATEURS` : utilisateurs associés à chaque entreprise
- `ACTIVITE` : activité quotidienne des utilisateurs
- `FACTURES` : factures mensuelles
- `LIGNES_FACTURE` : détail des factures et gestion du prorata
- `TICKETS_SUPPORT` : historique des tickets de support

### Données disponibles

- **4 entreprises** clientes
- **9 utilisateurs** avec les rôles Administrateur, Analyste et Lecteur
- **5 périodes d'abonnement**, incluant un upgrade de DataViz Inc et le churn d'Analytics Pro
- **18 enregistrements d'activité** quotidienne
- **20 factures** mensuelles
- **10 tickets** de support

**Période couverte : janvier à décembre 2024**

## 🔧 Technologies utilisées

- **SGBD** : SQL Server 2019+
- **Langage** : T-SQL
- **Outil** : SQL Server Management Studio (SSMS)

## 📁 Structure du projet

```text
DataLens/
├── README.md
├── DICTIONNAIRE_DONNEES.md
├── ANALYSE_KPIS.md
├── QUALITE_DONNEES.md
├── database/
│   └── schema_creation.sql
└── sql/
    ├── 01_analyse_kpis_synthese.sql
    └── 02_churn_analysis.sql
```

## 🚀 Utilisation

### 1. Créer la base de données

Exécuter le script suivant dans SQL Server Management Studio :

```sql
database/schema_creation.sql
```

Ce script permet de créer la structure de la base et les tables nécessaires au projet.

### 2. Analyser les KPI

Exécuter :

```sql
sql/01_analyse_kpis_synthese.sql
```

Ce script permet notamment d'analyser le MRR, les revenus, l'activité des clients et plusieurs indicateurs SaaS.

### 3. Analyser le churn

Exécuter :

```sql
sql/02_churn_analysis.sql
```

Ce script permet d'identifier les clients ayant quitté la plateforme et d'examiner différents facteurs associés à leur comportement.

## 📖 Documentation

Les fichiers suivants détaillent les différentes étapes du projet :

- [**Dictionnaire des données**](DICTIONNAIRE_DONNEES.md) : description des tables, colonnes et relations
- [**Analyse des KPI**](ANALYSE_KPIS.md) : calculs, résultats et interprétation des indicateurs
- [**Qualité des données**](QUALITE_DONNEES.md) : contrôles effectués et anomalies identifiées

## 🎯 Ce que ce projet démontre

Ce projet montre ma capacité à partir d'un besoin métier, structurer une base de données, contrôler la qualité des données, écrire des requêtes SQL et transformer les résultats en indicateurs utiles à la prise de décision.

L'objectif n'est pas uniquement de produire des requêtes SQL, mais de relier chaque analyse à une problématique métier concrète.