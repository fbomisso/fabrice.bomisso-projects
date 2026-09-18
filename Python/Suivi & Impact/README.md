# Suivi & Impact

Projet de **Data Analytics** consacré à la préparation et à l'analyse de données d'organisations à but non lucratif et d'opportunités de financement.

L'objectif de cette première phase est de transformer plusieurs fichiers de données brutes en tables propres, cohérentes et directement exploitables dans **Power BI**.

> **Statut actuel :** phase de nettoyage et de préparation des données terminée. La prochaine étape est la construction de l'analyse et du tableau de bord dans Power BI.

---

## 1. Contexte du projet

Le projet repose sur un jeu de données synthétique consacré aux organisations à but non lucratif et aux opportunités de financement.

L'idée est de travailler sur une problématique proche d'un contexte de suivi de programmes :

> **Les ressources financières allouées aux organisations produisent-elles les résultats attendus, et quels programmes nécessitent un suivi renforcé ?**

Pour répondre correctement à cette question, la première étape a été de vérifier et de préparer les données avant toute analyse dans Power BI.

---

## 2. Données utilisées

Le dataset d'origine contenait trois fichiers :

- `non-profits_final.csv`
- `nonprofit_quality.csv`
- `grants.csv`

Ces fichiers contiennent respectivement les informations sur les organisations, des informations relatives à la qualité des données et les opportunités de financement.

### Volumes initiaux

| Fichier | Lignes | Colonnes |
|---|---:|---:|
| `non-profits_final.csv` | 240 585 | 33 |
| `nonprofit_quality.csv` | 240 585 | 10 |
| `grants.csv` | 75 337 | 22 |

---

# 3. Importation des données

Les données ont été importées avec **Pandas**.

Le fichier `grants.csv` nécessitait un encodage `latin1` pour être correctement lu, contrairement aux deux autres fichiers.

```python
grants = pd.read_csv("grants.csv", sep=";", encoding="latin1")
nonprofits = pd.read_csv("non-profits_final.csv", sep=";")
quality = pd.read_csv("nonprofit_quality.csv", sep=";")
```

Après importation :

```text
Grants : 75 337 lignes et 22 colonnes
Nonprofits : 240 585 lignes et 33 colonnes
Quality : 240 585 lignes et 10 colonnes
```

---

# 4. Audit initial des données

Avant de modifier les données, un audit a été réalisé afin d'identifier :

- les valeurs manquantes ;
- les doublons ;
- les types de données ;
- les colonnes inutiles ;
- les valeurs négatives ;
- les incohérences entre variables ;
- les problèmes potentiels lors de la fusion des fichiers.

Aucun doublon n'a été détecté dans les trois fichiers.

---

# 5. Nettoyage de la table des organisations

La table `non-profits_final.csv` contenait 33 colonnes.

Elle a d'abord été préparée pour pouvoir être fusionnée avec la table de qualité des données.

Le champ `EIN`, utilisé comme identifiant, a été converti en texte afin d'avoir le même format dans les deux tables.

---

# 6. Nettoyage de la table Quality

La table `nonprofit_quality.csv` contenait une colonne :

```text
Unnamed: 9
```

Cette colonne était presque entièrement vide :

```text
240 577 valeurs manquantes sur 240 585 lignes
```

Elle a donc été supprimée.

Le champ `EIN` a ensuite été converti au même format que celui de la table des organisations.

---

# 7. Problème rencontré avec les EIN

Lors du contrôle des identifiants, les résultats ont montré :

```text
Organisations :
240 585 EIN uniques
0 doublon

Quality :
240 578 EIN uniques
7 doublons
```

L'analyse des doublons a révélé une anomalie particulière autour de la valeur :

```text
INC
```

Huit lignes étaient concernées par cette anomalie et présentaient un décalage dans les informations.

Plutôt que d'inventer une correction ou de supprimer arbitrairement ces données, elles ont été conservées et traitées avec prudence.

---

# 8. Fusion des organisations et de la qualité des données

Les deux tables ont ensuite été fusionnées à partir de `EIN`.

Une jointure gauche (`left join`) a été utilisée afin de conserver l'ensemble des organisations.

```python
nonprofits_complet = nonprofits.merge(
    quality,
    on="EIN",
    how="left"
)
```

Résultat :

```text
240 585 lignes
41 colonnes
```

Sur les 240 585 organisations :

```text
240 577 disposent d'informations Quality
8 ne disposent pas d'informations Quality
```

---

# 9. Contrôle des données financières

Plusieurs variables financières ont été examinées :

- `ASSET_AMT`
- `INCOME_AMT`
- `REVENUE_AMT`
- `financial_metric`

Des valeurs négatives ont été détectées :

```text
INCOME_AMT   : 44 valeurs négatives
REVENUE_AMT  : 461 valeurs négatives
```

Ces valeurs n'ont pas été supprimées automatiquement.

En l'absence de dictionnaire de données permettant de déterminer avec certitude qu'elles étaient erronées, elles ont été conservées.

Des valeurs extrêmement élevées ont également été identifiées.

Là encore, aucune suppression arbitraire n'a été effectuée : les valeurs originales ont été conservées afin de ne pas déformer les données sources.

---

# 10. Contrôle de l'impact

La variable `impact_score` présente trois niveaux :

| Niveau | Nombre |
|---|---:|
| Low | 189 168 |
| Medium | 33 602 |
| High | 17 815 |

La variable numérique `impact_score_numeric` correspond exactement à ces trois niveaux :

```text
1 → Low
2 → Medium
3 → High
```

Elle a donc été conservée comme score numérique.

---

# 11. Contrôle de la qualité des données

Les variables de disponibilité des informations ont également été étudiées.

Les résultats montrent :

| Information | Disponible |
|---|---:|
| Mission | 100 % |
| Impact | 100 % |
| Informations de base | 63,22 % |
| Données financières | 47,74 % |

Cette étape a permis d'identifier les principales dimensions où les données sont incomplètes.

Les informations concernant la mission et l'impact sont disponibles pour toutes les organisations, tandis que les informations financières et certaines informations de base sont beaucoup moins complètes.

---

# 12. Analyse de `impact_efficiency`

La variable `impact_efficiency` a été convertie en numérique afin de pouvoir être contrôlée.

L'analyse a montré une distribution très particulière :

- les organisations avec un impact faible présentent généralement une valeur proche de 1 ;
- les organisations avec un impact moyen ou élevé présentent généralement des valeurs extrêmement faibles.

La corrélation avec `financial_metric` était très faible :

```text
-0,0344
```

Cette variable n'a donc pas été retenue comme indicateur principal pour la suite du projet.

Elle n'a pas été supprimée de la table complète, mais elle n'a pas été intégrée à la table analytique finale.

---

# 13. Création de la table analytique Organisations

Après les contrôles, seules les variables nécessaires à la suite du projet ont été conservées.

La table finale `organisations` contient :

```text
240 585 lignes × 17 colonnes
```

Les colonnes ont été renommées en français :

```text
identifiant
nom_organisation
ville
etat
montant_actifs
montant_revenus
chiffre_affaires
indicateur_financier
niveau_impact
score_impact
score_confiance
qualite_donnees
champs_manquants
mission_disponible
donnees_financieres_disponibles
impact_disponible
informations_base_disponibles
```

L'identifiant des organisations est unique :

```text
240 585 identifiants uniques
0 doublon
```

---

# 14. Nettoyage de la table Grants

La table `grants.csv` contenait :

```text
75 337 lignes × 22 colonnes
```

Une colonne d'index inutile :

```text
Unnamed: 0
```

a été supprimée.

La table contient désormais 21 colonnes avant l'ajout de l'indicateur d'anomalie.

---

## Conversion des dates

Les colonnes suivantes ont été converties au format `datetime` :

```text
post_date
close_date
last_updated_date
archive_date
```

Elles ont ensuite été renommées :

```text
date_publication
date_cloture
date_mise_a_jour
date_archivage
```

---

## Contrôle des montants

Les variables financières ont été contrôlées :

```text
award_ceiling
award_floor
estimated_total_program_funding
```

Aucune valeur négative n'a été détectée pour ces trois variables.

Une incohérence a toutefois été identifiée :

```text
montant_minimal > montant_maximal
```

Une seule ligne était concernée.

Plutôt que de modifier les montants d'origine, une nouvelle variable de contrôle a été créée :

```text
montants_incoherents
```

Elle permet d'identifier cette anomalie sans modifier la donnée source.

---

## Contrôle des dates

Les dates ont également été comparées.

Aucune date de clôture antérieure à la date de publication n'a été détectée.

Aucune date d'archivage antérieure à la date de publication n'a été détectée.

---

## Valeurs manquantes

Plusieurs variables présentent des valeurs manquantes, notamment :

```text
numero_opportunite
categorie_opportunite
type_financement
secteur_financement
numero_cfda
beneficiaires_eligibles
type_beneficiaire
code_agence
nom_agence
date_publication
date_cloture
date_mise_a_jour
date_archivage
montant_maximal
montant_minimal
financement_total_estime
nombre_attributions_prevu
financement_complementaire_requis
url_information
```

Ces valeurs manquantes n'ont pas été remplacées artificiellement.

Aucune suppression massive de lignes n'a été effectuée uniquement en raison de valeurs manquantes.

---

# 15. Renommage des colonnes de Grants

Toutes les colonnes de la table `grants` ont été renommées en français.

La table finale contient :

```text
identifiant_opportunite
titre_opportunite
numero_opportunite
categorie_opportunite
type_financement
secteur_financement
numero_cfda
beneficiaires_eligibles
type_beneficiaire
code_agence
nom_agence
date_publication
date_cloture
date_mise_a_jour
date_archivage
montant_maximal
montant_minimal
financement_total_estime
nombre_attributions_prevu
financement_complementaire_requis
url_information
montants_incoherents
```

---

# 16. Tables finales

À la fin de la phase de nettoyage, deux tables principales ont été préparées.

| Table | Lignes | Colonnes |
|---|---:|---:|
| `organisations` | 240 585 | 17 |
| `grants` | 75 337 | 22 |

Les noms des fichiers destinés à Power BI sont :

```text
organisations.csv
subventions.csv
```

Le DataFrame `grants` reste utilisé en Python, tandis que le fichier exporté porte le nom français `subventions.csv`.

---

# 17. Export pour Power BI

Les données nettoyées sont exportées avec :

```python
organisations.to_csv(
    "organisations.csv",
    index=False,
    encoding="utf-8-sig"
)

grants.to_csv(
    "subventions.csv",
    index=False,
    encoding="utf-8-sig"
)
```

Les deux fichiers constituent les sources propres destinées à la prochaine phase du projet.

---

# 18. État actuel du projet

### Phase 1 — Importation
**Terminée**

### Phase 2 — Audit des données
**Terminée**

### Phase 3 — Nettoyage
**Terminée**

### Phase 4 — Fusion des données
**Terminée**

### Phase 5 — Structuration des tables analytiques
**Terminée**

### Phase 6 — Export des données propres
**Terminée**

### Phase 7 — Analyse et visualisation Power BI
**À venir**

---

# 19. Prochaine étape

La prochaine phase du projet sera réalisée dans **Power BI**.

Les fichiers :

```text
organisations.csv
subventions.csv
```

seront importés afin de construire le modèle de données, les indicateurs et les visualisations nécessaires au suivi et à l'analyse.

Cette phase permettra notamment d'exploiter les informations relatives :

- aux organisations ;
- à leur situation financière ;
- à leur niveau d'impact ;
- à la qualité des données ;
- aux opportunités de financement ;
- aux secteurs de financement ;
- aux agences ;
- aux montants disponibles.

---

# 20. Technologies utilisées

- **Python**
- **Pandas**
- **NumPy**
- **Matplotlib**
- **Seaborn**
- **Power BI**
- **Visual Studio Code**
- **Git / GitHub**

---

# 21. Auteur

**Fabrice BOMISSO**

**Data Analyst | Data Science | Business Intelligence**

Projet réalisé dans le cadre d'un portfolio professionnel en Data Analytics et Business Intelligence.