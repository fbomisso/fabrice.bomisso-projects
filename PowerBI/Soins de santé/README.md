# 🏥 Healthcare Revenue Cycle Analytics | Power BI

## 🎯 Objectif

Construire un dashboard Power BI professionnel dédié à l'analyse du **Revenue Cycle Management (RCM)** d'un réseau de sites de santé américain.

L'objectif est d'analyser le cycle financier des actes médicaux, depuis la facturation jusqu'au recouvrement, en identifiant les créances, les ajustements, les rejets (*denials*) et les écarts de performance entre sites, assureurs et prestataires.

**Périmètre analytique :**

* Performances financières du cycle de facturation
* Analyse des créances et du recouvrement
* Analyse des rejets (*denials*)
* Performance des médecins et catégories de prestataires
* Comparaison des assureurs
* Analyse des sites de santé
* Analyse des patients et des cohortes
* Analyse temporelle et Time Intelligence
* Sécurisation des données avec le Row-Level Security

**Parties prenantes ciblées :** direction générale, direction financière, responsables de facturation, responsables de sites, direction médicale et médecins.

## 🧩 Contexte

Projet réalisé avec une démarche d'audit et de modélisation orientée production.

Les **84 219 transactions** ont été contrôlées avant la construction du modèle afin d'identifier les problèmes d'unicité, de clés étrangères, de dates, de doublons et de cohérence entre les différentes dimensions.

Chaque anomalie importante a été analysée afin de déterminer son impact sur le modèle et les indicateurs. Les corrections ont été réalisées avec une logique traçable et compatible avec une architecture BI robuste.

Le modèle final repose sur un **schéma en étoile de 10 tables**, avec une table de faits centrale et des dimensions dédiées aux patients, médecins, dates, assureurs, sites, transactions, codes CPT et diagnostics.

## 🔗 Sources de données

* **84 219 transactions** issues de la table de faits.
* **5 117 patients** dans `DimPatient`.
* **932 enregistrements médecins** dans `DimPhysician`, représentant 36 spécialités.
* **224 dates** dans `DimDate`.
* **4 assureurs** dans `DimPayer`.
* **11 sites** dans `DimLocation`.
* **955 transactions/types d'ajustement** dans `DimTransaction`.
* **1 256 codes CPT** dans `DimCPTCode`.
* **4 801 codes diagnostics** dans `DimDiagnosisCode`.

Le dataset couvre la période **décembre 2019 à juillet 2020**.

## 📈 KPIs

| KPI | Valeur | Ce qu'il mesure |
|---|---:|---|
| Gross Charge | $1.47M | Montant brut facturé |
| Total Payment | $703K | Montant total encaissé |
| AR Outstanding | $51.9K | Créances restant à recouvrer |
| Net Collection Rate | 93.2% | Efficacité globale du recouvrement |
| **Denial Rate** | **21.06%** | Part des actes concernés par un rejet |
| Adjustment Rate | 56.24% | Poids des ajustements dans le cycle financier |
| AR Rate | 3.53% | Part des créances par rapport aux charges brutes |
| Patient Count | 5 117 | Nombre de patients distincts |
| Charge Count | 14 544 | Nombre de charges utilisées comme dénominateur |

## 🔍 Analyses réalisées

### Audit et qualité des données

L'audit des données a permis d'identifier plusieurs anomalies importantes :

* `dimDateServicePK` ne contient qu'une seule valeur exploitable sur l'ensemble des transactions, ce qui limite l'analyse temporelle basée sur la date de service.
* **661 doublons** ont été détectés dans `DimDiagnosisCode`. Un dédoublonnage direct aurait cassé les relations avec la table de faits. Un remapping des clés a donc été réalisé.
* Un **NPI dupliqué** a été détecté dans `DimPhysician` pour le médecin Velez, avec deux clés différentes dans la dimension et une répartition des transactions entre ces deux clés. Le problème a été corrigé par remapping.
* La cohérence des clés étrangères a été contrôlée avant la mise en place des relations du modèle.

Cette démarche permet de distinguer les problèmes de qualité du dataset source des problèmes liés à la modélisation Power BI.

### Modélisation en étoile

Le modèle repose sur une architecture en étoile comprenant une table de faits et plusieurs dimensions métier.

Les relations principales sont configurées en **1-à-plusieurs**, avec une direction de filtre **Single** des dimensions vers la table de faits.

Une relation inactive dédiée à la date de service permet d'utiliser ponctuellement `USERELATIONSHIP()` dans les mesures DAX.

Des colonnes métier ont également été créées pour enrichir l'analyse :

* `AgeGroup`
* `FTE_Category`
* `IsReversal`

### Power Query (M)

Les transformations Power Query ont été conçues pour préparer les données avant leur chargement dans le modèle.

Les principales opérations concernent :

* la gestion des types de données ;
* la correction et le remapping des clés ;
* le traitement des doublons ;
* la préparation des dimensions ;
* la création de colonnes métier ;
* le contrôle de la cohérence entre les tables ;
* la préparation des données pour le modèle en étoile.

Au total, **7 transformations principales** ont été documentées et justifiées selon leur objectif métier ou technique.

### DAX

Le modèle contient **19 mesures DAX** couvrant plusieurs niveaux de complexité.

Les principales fonctions utilisées comprennent notamment :

* `CALCULATE`
* `DIVIDE`
* `VAR`
* `BLANK()`
* `COALESCE`
* `DISTINCTCOUNT`
* `USERELATIONSHIP`
* fonctions de Time Intelligence

Les mesures permettent notamment de calculer les indicateurs financiers, les taux de rejet, les indicateurs de recouvrement, les cohortes et les analyses temporelles.

Une mesure **Denial Rate ALL** permet également de conserver le contexte global du taux de rejet lorsque les visuels sont filtrés.

## 🔐 Row-Level Security

Le modèle intègre une architecture **Row-Level Security (RLS)** destinée à contrôler l'accès aux données selon le profil de l'utilisateur.

| Rôle | Accès | Filtrage |
|---|---|---|
| **Executive Director** | Tous les sites et toutes les données | Aucun filtre |
| **Site Manager** | Données de son site | `DimLocation` |
| **Physician** | Ses propres actes | `DimPhysician` |

Une table `SecurityTable` permet d'associer l'utilisateur à son rôle, son site et, lorsque nécessaire, son médecin.

L'identification de l'utilisateur repose notamment sur `USERPRINCIPALNAME()` et `LOOKUPVALUE()`.

La modélisation utilise une propagation **Single** des filtres afin de limiter les risques de propagation involontaire des règles de sécurité.

## 🖼️ Aperçu du dashboard

Le rapport comprend **4 pages**, chacune répondant à une question métier précise.

### Vue d'ensemble

Combien le réseau facture-t-il, encaisse-t-il et doit-il encore récupérer ?

![Vue d'ensemble](./screenshots/Vue%20d%27ensemble.png)

La page présente les principaux KPIs financiers, le taux de rejet par groupe CPT et assureur, la répartition des charges par payeur ainsi que la performance financière des différents sites.

### Analyse des rejets

Où se concentrent les rejets et quelles spécialités présentent le plus de risques ?

![Analyse des rejets](./screenshots/Analyse%20des%20rejets.png)

La page présente notamment le classement des spécialités à risque, les médecins présentant des taux de rejet élevés et l'analyse de la relation entre volume d'actes et robustesse statistique.

Un seuil de robustesse de **n ≥ 50 actes** est utilisé afin d'éviter de surinterpréter les taux calculés sur de très faibles volumes.

### Performance Médecins

Quels profils de prestataires nécessitent une attention particulière ?

![Performance Médecins](./screenshots/Performance%20Médecins.png)

Cette page analyse les **931 médecins**, leurs taux de rejet, leur catégorie d'activité et leur performance par spécialité.

Elle permet notamment d'identifier les catégories de prestataires présentant les taux de rejet les plus élevés.

### Répartition Assureurs

Comment les différents payeurs se comportent-ils sur le cycle de facturation ?

![Répartition assureurs](./screenshots/Répartitions%20assureurs.png)

La page analyse les ajustements contractuels, la décomposition du cycle financier et la relation entre recouvrement et taux de rejet selon les assureurs.

Une attention particulière est portée au **paradoxe Medicare**, caractérisé par un taux de recouvrement élevé mais également un taux de rejet important.

## 💡 Insights clés

* Le **Net Collection Rate de 93.2%** indique une capacité globale de recouvrement relativement élevée, mais le **Denial Rate de 21.06%** révèle un volume important d'actes nécessitant une intervention avant recouvrement.
* Les rejets ne semblent pas concentrés sur une seule spécialité ou un seul acteur. Leur présence à plusieurs niveaux du modèle suggère davantage un problème systémique du processus de facturation.
* **Medicare** combine un taux de recouvrement élevé avec un taux de rejet important, ce qui constitue un axe prioritaire pour l'analyse des causes de rejet et de la qualité de la codification.
* **Angelstone** concentre une part importante des charges et présente également un niveau élevé de rejets. Le site constitue donc une priorité pour un audit opérationnel.
* Les catégories **Nurse Practitioners** et **Physician Assistants** présentent des taux de rejet élevés et constituent un axe potentiel d'amélioration via la formation et la validation des actes avant soumission.
* Les résultats temporels doivent être interprétés avec prudence : **92% des charges sont concentrées sur décembre 2019**, ce qui limite la portée analytique des mesures de Time Intelligence.

## 🎥 Démonstration

Une vidéo de démonstration du dashboard est également disponible dans le dossier `screenshots`.

[🎥 Voir la démonstration vidéo](./screenshots/Video_2026-09-01_000831.mp4)

## 🛠️ Technologies utilisées

* **Power BI Desktop** : modèle de données, visualisations et DAX
* **Power Query (M)** : audit, nettoyage et transformation des données
* **DAX** : mesures, calculs métier et Time Intelligence
* **Modélisation en étoile**
* **Row-Level Security (RLS)**
* **Data Storytelling**
* **Contrôle qualité des données**

## 📌 Limites du projet

La principale limite du dataset concerne la **date de service**. La clé `dimDateServicePK` ne fournit pas une granularité temporelle exploitable sur l'ensemble des transactions.

Par conséquent, les analyses temporelles basées sur la date de service sont documentées comme une limitation du dataset source plutôt qu'une faiblesse de l'architecture du modèle.

Une seconde limite concerne la concentration temporelle des données : **92% des charges sont concentrées sur décembre 2019**. Les mesures YTD, MTD et MoM sont donc techniquement présentes mais leur interprétation métier reste limitée.

## 🚀 Pistes d'amélioration

* Ajouter un historique multi-années permettant une véritable analyse de Time Intelligence.
* Automatiser l'alimentation du modèle via un pipeline ETL Python/SQL.
* Mettre en place une détection statistique automatique des médecins et sites atypiques.
* Ajouter des indicateurs prédictifs de risque de rejet.
* Développer un suivi mensuel des Denial Rates par médecin, CPT et assureur.
* Ajouter un système d'alerte permettant d'identifier rapidement les variations anormales.
* Optimiser le modèle pour des volumes supérieurs à 1 million de transactions.
* Produire une synthèse exécutive séparant les enjeux financiers, opérationnels et médicaux.

## 📂 Structure du projet

```text
Soins de santé/
├── README.md
├── data/
├── screenshots/
│   ├── Analyse des rejets.png
│   ├── Performance Médecins.png
│   ├── Répartitions assureurs.png
│   ├── Video_2026-09-01_000831.mp4
│   └── Vue d'ensemble.png
└── Healthcare Revenue Cycle Analytics.pbix
```

> 📝 Ce projet met l'accent sur une démarche complète de Business Intelligence : compréhension du métier, audit des données, transformation, modélisation, DAX, sécurité, visualisation et interprétation des résultats. L'objectif n'est pas seulement de produire un dashboard, mais de transformer les données du cycle de revenus de santé en éléments directement exploitables pour la prise de décision.