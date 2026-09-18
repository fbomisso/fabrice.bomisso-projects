# 📋 Dictionnaire des Données | DataLens

## Vue d'ensemble

Ce document décrit les tables, les colonnes, les types de données, les contraintes et les relations de la base de données **DataLens**.

---

## 📦 TABLE : PLANS

**Description :** Référentiel des plans d'abonnement disponibles sur la plateforme.

**Granularité :** Une ligne par plan unique.

**Usage :** Table de référence utilisée par `ABONNEMENTS`.

**Clé primaire :** `id_plan`

| Colonne | Type | Null | Contrainte | Description |
|---|---|---|---|---|
| `id_plan` | INT | ✗ | PRIMARY KEY, IDENTITY(1,1) | Identifiant unique du plan. Auto-généré. |
| `nom_plan` | VARCHAR(50) | ✗ | UNIQUE | Nom du plan : Formule de démarrage, Professionnel ou Entreprise. |
| `prix_catalogue` | DECIMAL(10,2) | ✗ | CHECK >= 0 | Prix mensuel du plan en euros. Peut être égal à 0 pour un plan gratuit. |
| `nb_utilisateurs_max` | INT | ✗ | CHECK (-1 ou > 0) | Nombre maximal d'utilisateurs. `-1` signifie illimité. |
| `nb_sources_donnees_max` | INT | ✗ | CHECK (-1 ou > 0) | Nombre maximal de sources de données. `-1` signifie illimité. |
| `nb_lignes_max` | BIGINT | ✗ | CHECK (-1 ou > 0) | Nombre maximal de lignes traitées par mois. `-1` signifie illimité. |

### Exemples de données

| id_plan | nom_plan | prix_catalogue | nb_utilisateurs_max | nb_sources_donnees_max | nb_lignes_max |
|---|---|---:|---:|---:|---:|
| 1 | Formule de démarrage | 99.00 | 1 | 1 | 100000 |
| 2 | Professionnel | 499.00 | 5 | 3 | 1000000 |
| 3 | Entreprise | 1999.00 | -1 | -1 | -1 |

---

## 🏢 TABLE : ENTREPRISES

**Description :** Entreprises clientes de la plateforme DataLens.

**Granularité :** Une ligne par entreprise cliente.

**Usage :** Table de référence utilisée par `ABONNEMENTS`, `UTILISATEURS`, `FACTURES` et `TICKETS_SUPPORT`.

**Clé primaire :** `id_entreprise`

| Colonne | Type | Null | Contrainte | Description |
|---|---|---|---|---|
| `id_entreprise` | INT | ✗ | PRIMARY KEY, IDENTITY(1,1) | Identifiant unique de l'entreprise. Auto-généré. |
| `nom_entreprise` | VARCHAR(255) | ✗ | Aucune | Nom ou raison sociale de l'entreprise. |
| `pays` | CHAR(2) | ✓ | Aucune | Code ISO 3166-1 alpha-2, par exemple FR, US, DE ou CA. |
| `secteur_activite` | VARCHAR(100) | ✓ | Aucune | Secteur ou industrie de l'entreprise. |
| `date_inscription` | DATE | ✗ | CHECK <= GETDATE() | Date d'inscription de l'entreprise à DataLens. Les dates futures sont interdites. |

### Exemples de données

| id_entreprise | nom_entreprise | pays | secteur_activite | date_inscription |
|---|---|---|---|---|
| 1 | DataViz Inc | US | Technologie | 2024-01-15 |
| 2 | Analytics Pro | FR | Conseil | 2024-03-20 |
| 3 | Business Intelligence Co | DE | Logiciels | 2024-06-10 |
| 4 | Startup Data | CA | Intelligence artificielle | 2024-09-05 |

---

## 📅 TABLE : ABONNEMENTS

**Description :** Historique des abonnements des entreprises. Chaque ligne représente une période pendant laquelle une entreprise utilise un plan à un prix donné.

**Granularité :** Une ligne par période d'abonnement. Un changement de plan crée une nouvelle ligne.

**Usage :** Source de référence pour le calcul du MRR, du churn et le suivi des changements de plan.

**Clés :**

- Primaire : `id_abonnement`
- Étrangères : `id_entreprise` → `ENTREPRISES`, `id_plan` → `PLANS`

| Colonne | Type | Null | Contrainte | Description |
|---|---|---|---|---|
| `id_abonnement` | INT | ✗ | PRIMARY KEY, IDENTITY(1,1) | Identifiant unique de la période d'abonnement. |
| `id_entreprise` | INT | ✗ | FK → ENTREPRISES | Entreprise ayant souscrit à l'abonnement. |
| `id_plan` | INT | ✗ | FK → PLANS | Plan associé à cette période d'abonnement. |
| `date_debut` | DATE | ✗ | CHECK date_fin IS NULL OR date_fin >= date_debut | Premier jour de la période d'abonnement. |
| `date_fin` | DATE | ✓ | CHECK date_fin IS NULL OR date_fin >= date_debut | Dernier jour de la période. `NULL` signifie que l'abonnement est actif. |
| `prix_mensuel` | DECIMAL(10,2) | ✗ | CHECK >= 0 | Prix mensuel réellement facturé. Il peut différer du prix catalogue. |

### Exemples de données

| id_abonnement | id_entreprise | id_plan | date_debut | date_fin | prix_mensuel |
|---|---:|---:|---|---|---:|
| 1 | 1 | 1 | 2024-01-15 | 2024-03-31 | 99.00 |
| 2 | 1 | 2 | 2024-04-01 | NULL | 499.00 |
| 3 | 2 | 2 | 2024-03-20 | 2024-09-30 | 499.00 |
| 4 | 3 | 2 | 2024-06-10 | NULL | 499.00 |
| 5 | 4 | 1 | 2024-09-05 | NULL | 99.00 |

### Interprétation

- Les lignes 1 et 2 montrent que DataViz Inc a effectué un upgrade du plan 1 vers le plan 2 en avril.
- La ligne 3 indique qu'Analytics Pro a churné le 30 septembre.
- Les lignes 4 et 5 indiquent que Business Intelligence Co et Startup Data disposent actuellement d'un abonnement actif.

---

## 👤 TABLE : UTILISATEURS

**Description :** Utilisateurs individuels de DataLens appartenant aux entreprises clientes.

**Granularité :** Une ligne par utilisateur. La table représente l'état actuel du rôle et conserve les dates d'inscription et de départ.

**Usage :** Comptabiliser les utilisateurs et analyser l'adoption de la plateforme selon les rôles.

**Clés :**

- Primaire : `id_utilisateur`
- Étrangère : `id_entreprise` → `ENTREPRISES`

| Colonne | Type | Null | Contrainte | Description |
|---|---|---|---|---|
| `id_utilisateur` | INT | ✗ | PRIMARY KEY, IDENTITY(1,1) | Identifiant unique de l'utilisateur. |
| `id_entreprise` | INT | ✗ | FK → ENTREPRISES | Entreprise à laquelle appartient l'utilisateur. |
| `nom_utilisateur` | VARCHAR(255) | ✗ | Aucune | Nom complet de l'utilisateur. |
| `role_actuel` | VARCHAR(50) | ✓ | Aucune | Rôle actuel : Administrateur, Analyste ou Lecteur. |
| `date_inscription` | DATE | ✗ | CHECK date_depart IS NULL OR date_depart >= date_inscription | Date de création du compte. |
| `date_depart` | DATE | ✓ | CHECK date_depart IS NULL OR date_depart >= date_inscription | Date de départ ou de suppression du compte. `NULL` signifie que l'utilisateur est actif. |

### Exemples de données

| id_utilisateur | id_entreprise | nom_utilisateur | role_actuel | date_inscription | date_depart |
|---|---:|---|---|---|---|
| 1 | 1 | Alice Martin | Administrateur | 2024-01-15 | NULL |
| 2 | 1 | Bob Dupont | Analyste | 2024-01-20 | NULL |
| 5 | 2 | Eric Rousseau | Analyste | 2024-04-05 | 2024-08-15 |
| 9 | 4 | Isabelle Mercier | Administrateur | 2024-09-05 | NULL |

---

## 📊 TABLE : ACTIVITE

**Description :** Activité quotidienne des utilisateurs sur la plateforme : connexions, requêtes, tableaux de bord créés et fonctionnalités utilisées.

**Granularité :** Une ligne par utilisateur et par jour suivi.

**Usage :** Analyser l'engagement, l'adoption de la plateforme et identifier les utilisateurs peu actifs.

**Clés :**

- Primaire composite : `(id_utilisateur, date_activite)`
- Étrangère : `id_utilisateur` → `UTILISATEURS`

| Colonne | Type | Null | Contrainte | Description |
|---|---|---|---|---|
| `id_utilisateur` | INT | ✗ | PK, FK → UTILISATEURS | Utilisateur à l'origine de l'activité. |
| `date_activite` | DATE | ✗ | PK | Date de l'activité. |
| `nb_connexions` | INT | ✗ | DEFAULT 0, CHECK >= 0 | Nombre de connexions effectuées ce jour. |
| `nb_requetes` | INT | ✗ | DEFAULT 0, CHECK >= 0 | Nombre de requêtes exécutées. |
| `nb_tableaux_bord` | INT | ✗ | DEFAULT 0, CHECK >= 0 | Nombre de tableaux de bord créés. |
| `nb_fonctionnalites_utilisees` | INT | ✗ | DEFAULT 0, CHECK >= 0 | Nombre de fonctionnalités différentes utilisées. |

### Notes

- Une valeur `0` signifie qu'aucune action de ce type n'a été enregistrée pour la journée.
- Les valeurs sont conservées à `0` plutôt que `NULL`.
- Une ligne correspond à un utilisateur et à une journée suivie.

### Exemples

| id_utilisateur | date_activite | nb_connexions | nb_requetes | nb_tableaux_bord | nb_fonctionnalites_utilisees |
|---|---|---:|---:|---:|---:|
| 1 | 2024-12-15 | 2 | 5 | 1 | 3 |
| 1 | 2024-12-16 | 3 | 8 | 0 | 2 |
| 3 | 2024-12-17 | 0 | 0 | 0 | 0 |

---

## 💳 TABLE : FACTURES

**Description :** Factures émises aux entreprises clientes.

**Granularité :** Une ligne par facture.

**Usage :** Suivre le revenu facturé et le statut de paiement.

**Clés :**

- Primaire : `id_facture`
- Étrangère : `id_entreprise` → `ENTREPRISES`

| Colonne | Type | Null | Contrainte | Description |
|---|---|---|---|---|
| `id_facture` | INT | ✗ | PRIMARY KEY, IDENTITY(1,1) | Identifiant unique de la facture. |
| `id_entreprise` | INT | ✗ | FK → ENTREPRISES | Entreprise facturée. |
| `date_facture` | DATE | ✗ | DEFAULT CAST(GETDATE() AS DATE) | Date d'émission de la facture. |
| `montant_total` | DECIMAL(10,2) | ✗ | CHECK >= 0 | Montant total de la facture en euros. |
| `statut` | VARCHAR(20) | ✗ | DEFAULT 'En attente' | Statut de la facture : En attente, Payée ou Annulée. |

### Exemples

| id_facture | id_entreprise | date_facture | montant_total | statut |
|---|---:|---|---:|---|
| 1 | 1 | 2024-01-31 | 99.00 | Payée |
| 6 | 1 | 2024-12-15 | 499.00 | En attente |
| 13 | 2 | 2024-09-30 | 499.00 | Payée |

---

## 🧾 TABLE : LIGNES_FACTURE

**Description :** Détail des éléments composant chaque facture. Une facture peut contenir plusieurs lignes, notamment lors d'un changement de plan ou d'une facturation au prorata.

**Granularité :** Une ligne par élément facturé.

**Usage :** Analyser le détail du revenu et gérer les situations de prorata.

**Clés :**

- Primaire : `id_ligne_facture`
- Étrangères : `id_facture` → `FACTURES`, `id_abonnement` → `ABONNEMENTS`

| Colonne | Type | Null | Contrainte | Description |
|---|---|---|---|---|
| `id_ligne_facture` | INT | ✗ | PRIMARY KEY, IDENTITY(1,1) | Identifiant unique de la ligne de facture. |
| `id_facture` | INT | ✗ | FK → FACTURES | Facture à laquelle appartient la ligne. |
| `id_abonnement` | INT | ✗ | FK → ABONNEMENTS | Abonnement correspondant à la ligne facturée. |
| `description` | VARCHAR(255) | ✗ | Aucune | Description de l'élément facturé, par exemple « Professionnel - Avril ». |
| `date_debut_facturee` | DATE | ✗ | CHECK date_fin_facturee >= date_debut_facturee | Premier jour de la période facturée. |
| `date_fin_facturee` | DATE | ✗ | CHECK date_fin_facturee >= date_debut_facturee | Dernier jour de la période facturée. |
| `quantite` | INT | ✗ | DEFAULT 1 | Quantité facturée. |
| `prix_unitaire` | DECIMAL(10,2) | ✗ | CHECK >= 0 | Prix unitaire de l'élément facturé. |
| `montant` | DECIMAL(10,2) | ✗ | CHECK >= 0 | Montant total de la ligne. |

---

## 🎫 TABLE : TICKETS_SUPPORT

**Description :** Tickets créés par les entreprises auprès du support technique.

**Granularité :** Un ticket correspond à une demande adressée au support.

**Usage :** Analyser l'activité du support et identifier d'éventuels signaux associés au churn.

**Clés :**

- Primaire : `id_ticket`
- Étrangère : `id_entreprise` → `ENTREPRISES`

| Colonne | Type | Null | Contrainte | Description |
|---|---|---|---|---|
| `id_ticket` | INT | ✗ | PRIMARY KEY, IDENTITY(1,1) | Identifiant unique du ticket. |
| `id_entreprise` | INT | ✗ | FK → ENTREPRISES | Entreprise à l'origine du ticket. |
| `date_creation` | DATETIME2 | ✗ | DEFAULT SYSDATETIME() | Date et heure de création du ticket. |
| `date_resolution` | DATETIME2 | ✓ | Aucune | Date et heure de résolution. `NULL` signifie que le ticket n'est pas encore résolu. |
| `categorie` | VARCHAR(50) | ✗ | Aucune | Catégorie du ticket : Bogue, Fonctionnalité, Compte, Facturation, etc. |
| `priorite` | VARCHAR(20) | ✗ | Aucune | Niveau de priorité : Faible, Moyenne, Élevée ou Critique. |
| `statut` | VARCHAR(20) | ✗ | DEFAULT 'Ouvert' | Statut : Ouvert, En cours, Résolu ou Fermé. |

### Notes

- `date_resolution = NULL` signifie que le ticket n'est pas encore résolu.
- Le temps de résolution peut être calculé à partir de `date_creation` et `date_resolution`.

### Exemples

| id_ticket | id_entreprise | date_creation | date_resolution | categorie | priorite | statut |
|---|---:|---|---|---|---|---|
| 1 | 1 | 2024-12-10 09:30 | 2024-12-10 14:00 | Bogue | Élevée | Résolu |
| 4 | 2 | 2024-08-20 10:00 | NULL | Bogue | Élevée | Ouvert |

---

## 📊 Relations et cardinalités

```text
PLANS (1) ──────────── (N) ABONNEMENTS
ENTREPRISES (1) ────── (N) ABONNEMENTS
ENTREPRISES (1) ────── (N) UTILISATEURS
UTILISATEURS (1) ───── (N) ACTIVITE
ENTREPRISES (1) ────── (N) FACTURES
FACTURES (1) ───────── (N) LIGNES_FACTURE
ABONNEMENTS (1) ────── (N) LIGNES_FACTURE
ENTREPRISES (1) ────── (N) TICKETS_SUPPORT
```

### Lecture du modèle

- Un **plan** peut être associé à plusieurs abonnements.
- Une **entreprise** peut avoir plusieurs périodes d'abonnement.
- Une **entreprise** peut avoir plusieurs utilisateurs.
- Un **utilisateur** peut avoir plusieurs enregistrements d'activité.
- Une **entreprise** peut recevoir plusieurs factures.
- Une **facture** peut contenir plusieurs lignes.
- Un **abonnement** peut apparaître sur plusieurs lignes de facture.
- Une **entreprise** peut créer plusieurs tickets de support.

---

## 🔑 Index créés

Les index suivants sont utilisés pour améliorer les performances des recherches et des jointures :

- `IDX_ABONNEMENTS_ENTREPRISE` : recherches par entreprise
- `IDX_ABONNEMENTS_PLAN` : recherches par plan
- `IDX_ABONNEMENTS_DATES` : recherches sur les périodes d'abonnement
- `IDX_UTILISATEURS_ENTREPRISE` : recherches d'utilisateurs par entreprise
- `IDX_UTILISATEURS_DATES` : recherches sur les dates d'inscription et de départ
- `IDX_FACTURES_ENTREPRISE` : recherches de factures par entreprise
- `IDX_LIGNES_FACTURE_FACTURE` : recherches des lignes par facture
- `IDX_LIGNES_FACTURE_ABONNEMENT` : recherches des lignes par abonnement
- `IDX_TICKETS_SUPPORT_ENTREPRISE` : recherches de tickets par entreprise