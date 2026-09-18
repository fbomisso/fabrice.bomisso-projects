# Analyse des KPI, DataLens

## Vue d'ensemble

Ce document présente les principaux indicateurs clés de performance (KPI) calculés à partir de la base de données DataLens, ainsi que leur interprétation métier.

L'objectif est d'évaluer quatre dimensions principales de la plateforme SaaS :

- la performance financière ;
- la fidélisation des clients ;
- l'engagement des utilisateurs ;
- la qualité du support.

> **Note méthodologique :** le dataset contient seulement 4 entreprises. Les résultats sont donc utiles pour démontrer la démarche d'analyse SQL, mais les indicateurs de churn et les relations entre variables doivent être interprétés avec prudence.

---

## 1. MRR, Monthly Recurring Revenue

**Définition :** revenu mensuel récurrent généré par les abonnements actuellement actifs.

### Formule SQL

```sql
SELECT 
    SUM(prix_mensuel) AS mrr_total
FROM ABONNEMENTS
WHERE date_fin IS NULL;
```

**Résultat : 1 097 €/mois**

### Détail par entreprise

| Entreprise | MRR | Plan | Statut |
|---|---:|---|---|
| DataViz Inc | 499 € | Professionnel | Actif |
| Business Intelligence Co | 499 € | Professionnel | Actif |
| Startup Data | 99 € | Formule de démarrage | Actif |
| **Total** | **1 097 €** | | |

### Interprétation

- 3 entreprises disposent actuellement d'un abonnement actif.
- Le portefeuille est composé de 2 abonnements Professionnel et 1 abonnement Formule de démarrage.
- Startup Data représente une possibilité d'upsell à moyen terme, mais son ancienneté doit être prise en compte avant toute conclusion sur son potentiel d'expansion.

---

## 2. Churn Rate

**Définition :** proportion des entreprises ayant connu une résiliation d'abonnement dans l'historique disponible.

### Formule SQL

```sql
SELECT 
    COUNT(DISTINCT CASE 
        WHEN date_fin IS NOT NULL THEN id_entreprise 
    END) AS entreprises_churnees,
    COUNT(DISTINCT id_entreprise) AS total_entreprises,
    CAST(
        COUNT(DISTINCT CASE 
            WHEN date_fin IS NOT NULL THEN id_entreprise 
        END) * 100.0 
        / COUNT(DISTINCT id_entreprise)
        AS DECIMAL(5,2)
    ) AS churn_rate_percent
FROM ABONNEMENTS;
```

**Résultat : 25 %**

Une seule entreprise sur les quatre présentes dans la base a churné : **Analytics Pro**.

### Détail

| Entreprise | Statut | Date de churn |
|---|---|---|
| Analytics Pro | Churné | 2024-09-30 |
| DataViz Inc | Actif | |
| Business Intelligence Co | Actif | |
| Startup Data | Actif | |

### Interprétation

- Le churn historique observé est de **25 %**.
- Ce résultat doit être interprété avec prudence compte tenu de la très faible taille de l'échantillon.
- Analytics Pro représentait un abonnement Professionnel de **499 €/mois**, soit une perte de MRR de 499 € après sa résiliation.

> **Attention :** il s'agit d'un taux de churn historique calculé sur les entreprises présentes dans le dataset, et non d'un taux de churn mensuel ou annuel au sens strict.

---

## 3. Engagement utilisateur

**Définition :** niveau d'utilisation de la plateforme mesuré ici par le nombre de requêtes lancées.

### Formule SQL

```sql
SELECT 
    e.nom_entreprise,
    SUM(ac.nb_requetes) AS total_requetes,
    COUNT(DISTINCT u.id_utilisateur) AS nombre_utilisateurs,
    CAST(
        SUM(ac.nb_requetes) * 1.0 
        / COUNT(DISTINCT u.id_utilisateur)
        AS DECIMAL(10,2)
    ) AS requetes_par_utilisateur
FROM ACTIVITE ac
INNER JOIN UTILISATEURS u 
    ON ac.id_utilisateur = u.id_utilisateur
INNER JOIN ENTREPRISES e 
    ON u.id_entreprise = e.id_entreprise
GROUP BY 
    e.id_entreprise,
    e.nom_entreprise
ORDER BY total_requetes DESC;
```

### Résultats

| Entreprise | Total requêtes | Utilisateurs | Requêtes/utilisateur | Statut |
|---|---:|---:|---:|---|
| Business Intelligence Co | 31 | 3 | 10,33 | Actif |
| DataViz Inc | 23 | 3 | 7,67 | Actif |
| Analytics Pro | 17 | 2 | 8,50 | Churné |
| Startup Data | 6 | 1 | 6,00 | Actif |

### Interprétation

- Business Intelligence Co présente le niveau d'utilisation le plus élevé avec 10,33 requêtes par utilisateur.
- DataViz Inc affiche également un niveau d'engagement significatif avec 7,67 requêtes par utilisateur.
- Analytics Pro, malgré son churn, affichait 8,50 requêtes par utilisateur. L'engagement seul ne permet donc pas d'expliquer le churn.
- Startup Data présente le niveau d'utilisation le plus faible, mais son ancienneté limitée doit être prise en compte.

### Pattern observé

Le volume de requêtes ne semble pas être, à lui seul, un indicateur suffisant pour expliquer le churn. Analytics Pro présentait un niveau d'engagement comparable à celui de DataViz Inc avant sa résiliation.

---

## 4. Support et churn

**Objectif :** rechercher un éventuel lien entre les tickets support non résolus et le churn.

### Formule SQL

```sql
SELECT 
    e.nom_entreprise,
    COUNT(DISTINCT ts.id_ticket) AS nombre_tickets,
    COUNT(DISTINCT CASE 
        WHEN ts.statut = 'Ouvert' THEN ts.id_ticket 
    END) AS tickets_ouverts,
    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM ABONNEMENTS
            WHERE id_entreprise = e.id_entreprise
              AND date_fin IS NULL
        ) THEN 'Actif'
        ELSE 'Churné'
    END AS statut
FROM ENTREPRISES e
LEFT JOIN TICKETS_SUPPORT ts 
    ON e.id_entreprise = ts.id_entreprise
GROUP BY 
    e.id_entreprise,
    e.nom_entreprise
ORDER BY nombre_tickets DESC;
```

### Résultats

| Entreprise | Total tickets | Tickets ouverts | Statut |
|---|---:|---:|---|
| DataViz Inc | 3 | 1 | Actif |
| Business Intelligence Co | 3 | 1 | Actif |
| Startup Data | 2 | 1 | Actif |
| Analytics Pro | 2 | **2** | **Churné** |

### Interprétation

Analytics Pro est la seule entreprise présentant simultanément :

- 2 tickets ouverts ;
- aucun ticket résolu dans les données disponibles ;
- une résiliation d'abonnement.

Cela constitue un **signal potentiel** de risque de churn.

Cependant, les données disponibles ne permettent pas d'établir une relation causale entre les tickets non résolus et le churn.

### Conclusion

> Les tickets support non résolus constituent un indicateur intéressant à surveiller, mais l'hypothèse doit être validée sur un portefeuille plus important avant d'être utilisée comme règle de détection du churn.

---

## 5. Temps moyen de résolution des tickets

**Définition :** durée moyenne entre la création et la résolution d'un ticket.

### Formule SQL

```sql
SELECT 
    e.nom_entreprise,
    COUNT(CASE 
        WHEN ts.date_resolution IS NOT NULL THEN 1 
    END) AS tickets_resolus,
    AVG(
        CAST(
            DATEDIFF(
                HOUR,
                ts.date_creation,
                ts.date_resolution
            ) AS FLOAT
        )
    ) AS temps_resolution_heures
FROM TICKETS_SUPPORT ts
INNER JOIN ENTREPRISES e 
    ON ts.id_entreprise = e.id_entreprise
WHERE ts.date_resolution IS NOT NULL
GROUP BY 
    e.id_entreprise,
    e.nom_entreprise;
```

### Résultats

| Entreprise | Tickets résolus | Temps moyen de résolution |
|---|---:|---:|
| DataViz Inc | 2 | 5,0 h |
| Business Intelligence Co | 2 | 18,5 h |
| Startup Data | 1 | 2,0 h |

Analytics Pro ne possède aucun ticket résolu dans les données disponibles.

### Interprétation

- Startup Data présente le temps moyen de résolution le plus faible : 2 heures.
- DataViz Inc présente également une résolution relativement rapide : 5 heures.
- Business Intelligence Co présente un délai moyen supérieur : 18,5 heures.
- Analytics Pro ne dispose d'aucun ticket résolu dans l'historique observé.

Le délai de résolution peut constituer un indicateur complémentaire dans une analyse de satisfaction et de risque client.

---

## 6. Synthèse des KPI

| KPI | Valeur | Interprétation |
|---|---:|---|
| **MRR** | 1 097 € | Revenu mensuel récurrent généré par les 3 clients actifs |
| **Churn historique** | 25 % | 1 entreprise churnée sur 4 |
| **Clients actifs** | 3/4 | 75 % des entreprises sont actuellement actives |
| **Engagement** | 77 requêtes au total | Activité mesurée sur les données disponibles |
| **Tickets ouverts** | 5 | Analytics Pro concentre 2 tickets ouverts |
| **MRR perdu historiquement** | 499 € | Correspond au churn d'Analytics Pro |

---

## 7. Signaux d'alerte identifiés

### Analytics Pro, CHURNÉ

**Signaux observés avant la résiliation :**

- 2 tickets ouverts non résolus ;
- aucun ticket résolu dans les données disponibles ;
- 8,50 requêtes par utilisateur, soit un niveau d'engagement comparable à DataViz Inc ;
- abonnement Professionnel à 499 €/mois.

**Hypothèse :**

> La combinaison de problèmes support non résolus et d'une absence de résolution pourrait constituer un signal de risque de churn.

Cette hypothèse reste à confirmer avec davantage de données.

---

### DataViz Inc, ACTIF

**Points positifs :**

- 7,67 requêtes par utilisateur ;
- passage du plan Formule de démarrage au plan Professionnel ;
- 3 utilisateurs ;
- 2 tickets résolus.

**Point d'attention :**

- 1 ticket actuellement ouvert.

DataViz Inc ne présente pas, dans les données disponibles, les mêmes signaux que le client ayant churné.

---

### Business Intelligence Co, ACTIF

- 10,33 requêtes par utilisateur ;
- niveau d'engagement le plus élevé du portefeuille ;
- 2 tickets résolus ;
- 1 ticket ouvert ;
- délai moyen de résolution de 18,5 heures.

Le niveau d'engagement est élevé, mais le délai de résolution pourrait être surveillé.

---

### Startup Data, ACTIF

- 6 requêtes par utilisateur ;
- 1 utilisateur ;
- 1 ticket ouvert ;
- abonnement Formule de démarrage ;
- entreprise récemment inscrite.

Le faible niveau d'activité doit être interprété en tenant compte de la récence du client.

---

## 8. Recommandations

### 1. Renforcer le suivi du support

Mettre en place un suivi des tickets ouverts, notamment pour les demandes à priorité élevée ou critique.

### 2. Construire un score de risque client

Combiner plusieurs signaux plutôt que de se baser uniquement sur l'engagement :

- nombre de tickets ouverts ;
- ancienneté des tickets ;
- évolution du nombre de requêtes ;
- évolution du nombre d'utilisateurs actifs ;
- évolution du plan d'abonnement ;
- historique des paiements.

### 3. Suivre l'engagement dans le temps

Mettre en place un indicateur d'évolution de l'activité sur 30 jours afin de détecter les baisses progressives d'utilisation.

### 4. Identifier les opportunités d'expansion

Surveiller les clients utilisant régulièrement la plateforme mais disposant encore d'un plan inférieur afin d'identifier les opportunités d'upsell.

### 5. Augmenter le volume de données

Le dataset actuel contient seulement 4 entreprises. Les patterns observés doivent donc être considérés comme des **hypothèses analytiques** et non comme des conclusions statistiques généralisables.

---

## Conclusion

L'analyse montre que le **MRR**, le **churn**, l'**engagement** et le **support** permettent de construire une première vision du portefeuille SaaS.

Le cas d'**Analytics Pro** est particulièrement intéressant : son niveau d'engagement n'était pas exceptionnellement faible, mais l'entreprise cumulait plusieurs tickets ouverts non résolus avant son churn.

Ce résultat suggère que l'analyse du churn ne doit pas reposer sur une seule métrique. Une approche combinant **usage, support, évolution de l'abonnement et historique client** serait plus pertinente pour construire un véritable système de détection du risque de churn.