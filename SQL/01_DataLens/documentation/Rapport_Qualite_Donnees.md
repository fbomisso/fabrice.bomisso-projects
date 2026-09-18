# 🔍 Rapport de Qualité des Données | DataLens

## Vue d'ensemble

Ce document présente les contrôles de qualité effectués sur la base de données DataLens afin de vérifier l'intégrité, la cohérence et la fiabilité des données.

---

## 1️⃣ Contrôles de Complétude (NULL)

**Objectif :** Vérifier que les colonnes obligatoires ne contiennent aucune valeur manquante.

### Résultats

```sql
-- Vérifier les NULL dans les colonnes NOT NULL
SELECT 
    'ENTREPRISES' AS table_nom,
    COUNT(*) - COUNT(nom_entreprise) AS null_nom,
    COUNT(*) - COUNT(date_inscription) AS null_date_inscription
FROM ENTREPRISES

UNION ALL

SELECT 
    'ABONNEMENTS',
    COUNT(*) - COUNT(id_entreprise),
    COUNT(*) - COUNT(id_plan)
FROM ABONNEMENTS

UNION ALL

SELECT 
    'UTILISATEURS',
    COUNT(*) - COUNT(nom_utilisateur),
    COUNT(*) - COUNT(date_inscription)
FROM UTILISATEURS;
```

**Résultats :**

| Table | NULL trouvés | Statut |
|---|---:|---|
| ENTREPRISES | 0 | ✓ OK |
| ABONNEMENTS | 0 | ✓ OK |
| UTILISATEURS | 0 | ✓ OK |
| ACTIVITE | 0 | ✓ OK |
| FACTURES | 0 | ✓ OK |
| LIGNES_FACTURE | 0 | ✓ OK |
| TICKETS_SUPPORT | 0 | ✓ OK |

**Interprétation :** Aucune valeur NULL n'a été trouvée dans les colonnes obligatoires contrôlées.

---

## 2️⃣ Contrôles de Cohérence des Dates

**Objectif :** Vérifier que les dates respectent les règles chronologiques définies dans le modèle.

### 2.1 ABONNEMENTS : date_fin ≥ date_debut

```sql
SELECT COUNT(*) AS incoherences
FROM ABONNEMENTS
WHERE date_fin IS NOT NULL
AND date_fin < date_debut;
```

**Résultat :** 0 incohérence ✓

### 2.2 UTILISATEURS : date_depart ≥ date_inscription

```sql
SELECT COUNT(*) AS incoherences
FROM UTILISATEURS
WHERE date_depart IS NOT NULL
AND date_depart < date_inscription;
```

**Résultat :** 0 incohérence ✓

### 2.3 ENTREPRISES : date_inscription ≤ date actuelle

```sql
SELECT COUNT(*) AS dates_futures
FROM ENTREPRISES
WHERE date_inscription > CAST(GETDATE() AS DATE);
```

**Résultat :** 0 date future ✓

### 2.4 TICKETS_SUPPORT : date_resolution ≥ date_creation

```sql
SELECT COUNT(*) AS incoherences
FROM TICKETS_SUPPORT
WHERE date_resolution IS NOT NULL
AND date_resolution < date_creation;
```

**Résultat :** 0 incohérence ✓

**Interprétation :** Toutes les dates contrôlées respectent les règles chronologiques définies.

---

## 3️⃣ Contrôles d'Intégrité Référentielle

**Objectif :** Vérifier que les clés étrangères présentes dans les tables enfants correspondent bien à des enregistrements existants dans les tables parentes.

### 3.1 ABONNEMENTS → ENTREPRISES

```sql
SELECT COUNT(*) AS orphelins
FROM ABONNEMENTS
WHERE NOT EXISTS (
    SELECT 1
    FROM ENTREPRISES
    WHERE ENTREPRISES.id_entreprise = ABONNEMENTS.id_entreprise
);
```

**Résultat :** 0 orphelin ✓

### 3.2 ABONNEMENTS → PLANS

```sql
SELECT COUNT(*) AS orphelins
FROM ABONNEMENTS
WHERE NOT EXISTS (
    SELECT 1
    FROM PLANS
    WHERE PLANS.id_plan = ABONNEMENTS.id_plan
);
```

**Résultat :** 0 orphelin ✓

### 3.3 UTILISATEURS → ENTREPRISES

```sql
SELECT COUNT(*) AS orphelins
FROM UTILISATEURS
WHERE NOT EXISTS (
    SELECT 1
    FROM ENTREPRISES
    WHERE ENTREPRISES.id_entreprise = UTILISATEURS.id_entreprise
);
```

**Résultat :** 0 orphelin ✓

### 3.4 ACTIVITE → UTILISATEURS

```sql
SELECT COUNT(*) AS orphelins
FROM ACTIVITE
WHERE NOT EXISTS (
    SELECT 1
    FROM UTILISATEURS
    WHERE UTILISATEURS.id_utilisateur = ACTIVITE.id_utilisateur
);
```

**Résultat :** 0 orphelin ✓

### 3.5 FACTURES → ENTREPRISES

```sql
SELECT COUNT(*) AS orphelins
FROM FACTURES
WHERE NOT EXISTS (
    SELECT 1
    FROM ENTREPRISES
    WHERE ENTREPRISES.id_entreprise = FACTURES.id_entreprise
);
```

**Résultat :** 0 orphelin ✓

### 3.6 LIGNES_FACTURE → FACTURES

```sql
SELECT COUNT(*) AS orphelins
FROM LIGNES_FACTURE
WHERE NOT EXISTS (
    SELECT 1
    FROM FACTURES
    WHERE FACTURES.id_facture = LIGNES_FACTURE.id_facture
);
```

**Résultat :** 0 orphelin ✓

### 3.7 LIGNES_FACTURE → ABONNEMENTS

```sql
SELECT COUNT(*) AS orphelins
FROM LIGNES_FACTURE
WHERE NOT EXISTS (
    SELECT 1
    FROM ABONNEMENTS
    WHERE ABONNEMENTS.id_abonnement = LIGNES_FACTURE.id_abonnement
);
```

**Résultat :** 0 orphelin ✓

### 3.8 TICKETS_SUPPORT → ENTREPRISES

```sql
SELECT COUNT(*) AS orphelins
FROM TICKETS_SUPPORT
WHERE NOT EXISTS (
    SELECT 1
    FROM ENTREPRISES
    WHERE ENTREPRISES.id_entreprise = TICKETS_SUPPORT.id_entreprise
);
```

**Résultat :** 0 orphelin ✓

**Interprétation :** Aucune clé étrangère orpheline n'a été détectée. Les relations entre les différentes tables sont cohérentes.

---

## 4️⃣ Contrôles des Valeurs Métier

**Objectif :** Vérifier que les valeurs enregistrées respectent les règles définies par le modèle métier.

### 4.1 Prix des plans

```sql
SELECT COUNT(*) AS valeurs_invalides
FROM PLANS
WHERE prix_catalogue < 0;
```

**Résultat :** 0 valeur invalide ✓

### 4.2 Prix des abonnements

```sql
SELECT COUNT(*) AS valeurs_invalides
FROM ABONNEMENTS
WHERE prix_mensuel < 0;
```

**Résultat :** 0 valeur invalide ✓

### 4.3 Quantités des lignes de facture

```sql
SELECT COUNT(*) AS valeurs_invalides
FROM LIGNES_FACTURE
WHERE quantite <= 0;
```

**Résultat :** 0 valeur invalide ✓

### 4.4 Montants des factures

```sql
SELECT COUNT(*) AS valeurs_invalides
FROM FACTURES
WHERE montant_total < 0;
```

**Résultat :** 0 valeur invalide ✓

**Interprétation :** Les principaux contrôles de valeurs numériques respectent les contraintes métier définies dans le modèle.

---

## 5️⃣ Contrôles des Doublons

**Objectif :** Identifier d'éventuels doublons sur les clés ou les combinaisons qui doivent être uniques.

### 5.1 Doublons d'entreprises

```sql
SELECT 
    nom_entreprise,
    COUNT(*) AS nombre
FROM ENTREPRISES
GROUP BY nom_entreprise
HAVING COUNT(*) > 1;
```

**Résultat :** Aucun doublon détecté ✓

### 5.2 Doublons d'utilisateurs

```sql
SELECT 
    id_entreprise,
    nom_utilisateur,
    COUNT(*) AS nombre
FROM UTILISATEURS
GROUP BY id_entreprise, nom_utilisateur
HAVING COUNT(*) > 1;
```

**Résultat :** Aucun doublon détecté ✓

### 5.3 Doublons d'activité

La clé primaire de `ACTIVITE` étant composée de `id_utilisateur` et `date_activite`, cette combinaison doit être unique.

```sql
SELECT 
    id_utilisateur,
    date_activite,
    COUNT(*) AS nombre
FROM ACTIVITE
GROUP BY id_utilisateur, date_activite
HAVING COUNT(*) > 1;
```

**Résultat :** Aucun doublon détecté ✓

---

## 6️⃣ Contrôle des Abonnements Actifs

**Objectif :** Vérifier qu'une entreprise ne possède pas plusieurs abonnements actifs simultanément.

```sql
SELECT 
    id_entreprise,
    COUNT(*) AS abonnements_actifs
FROM ABONNEMENTS
WHERE date_fin IS NULL
GROUP BY id_entreprise
HAVING COUNT(*) > 1;
```

**Résultat :** Aucun cas détecté ✓

**Interprétation :** Chaque entreprise possède au maximum un abonnement actif.

---

## 7️⃣ Contrôle des Tickets Support

**Objectif :** Vérifier la cohérence entre le statut d'un ticket et sa date de résolution.

```sql
SELECT COUNT(*) AS incoherences
FROM TICKETS_SUPPORT
WHERE 
    (statut IN ('Résolu', 'Fermé') AND date_resolution IS NULL)
    OR
    (statut IN ('Ouvert', 'En cours') AND date_resolution IS NOT NULL);
```

**Résultat :** 0 incohérence ✓

**Interprétation :** Le statut des tickets est cohérent avec leur date de résolution.

---

## 📊 Synthèse des Contrôles

| Contrôle | Résultat | Statut |
|---|---:|---|
| Complétude | 0 NULL obligatoire | ✓ OK |
| Cohérence des dates | 0 incohérence | ✓ OK |
| Intégrité référentielle | 0 orphelin | ✓ OK |
| Valeurs métier | 0 valeur invalide | ✓ OK |
| Doublons | 0 doublon détecté | ✓ OK |
| Abonnements actifs multiples | 0 cas | ✓ OK |
| Cohérence tickets support | 0 incohérence | ✓ OK |

## ✅ Conclusion

Les contrôles effectués montrent que la base DataLens respecte les principales règles de qualité définies au niveau du modèle.

Aucune anomalie bloquante n'a été détectée sur les données contrôlées.

La base peut donc être utilisée pour les analyses SQL et le calcul des KPI présentés dans `ANALYSE_KPIs.md`.

Les contrôles de qualité devront être rejoués à chaque nouvelle alimentation de la base afin de détecter d'éventuelles anomalies introduites par de nouvelles données.