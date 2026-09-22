# Global Superstore | Analyse de la performance commerciale avec Power BI

## 📌 Présentation du projet

Ce projet consiste à concevoir un tableau de bord interactif avec **Power BI** pour analyser la performance commerciale de Global Superstore sur la période **2011 à 2014**.

L'analyse porte sur plusieurs dimensions complémentaires : **rentabilité, marchés, clients, produits, logistique et évolution temporelle**.

L'objectif est de transformer les données de ventes en indicateurs permettant de comprendre les principaux facteurs associés à la performance commerciale et d'identifier les zones nécessitant une analyse plus approfondie.

---

## 🎯 Objectifs

Le tableau de bord cherche notamment à répondre aux questions suivantes :

* Quelle est la performance commerciale globale ?
* Comment les remises sont-elles associées à la rentabilité ?
* Quels marchés présentent les différents niveaux de marge ?
* Quelles sous-catégories de produits contribuent le plus à la marge ?
* Quels segments clients présentent les différents niveaux de rentabilité ?
* Comment les coûts logistiques évoluent-ils selon la taille des commandes ?
* Comment le chiffre d'affaires et la marge évoluent-ils dans le temps ?
* Où se concentrent les commandes déficitaires ?

---

## 🧪 Hypothèses d'analyse

L'analyse a été construite autour de plusieurs hypothèses :

1. **Une augmentation du niveau de remise est associée à une dégradation du taux de marge.**
2. **La rentabilité varie selon les marchés géographiques.**
3. **Les commandes de plus grande taille présentent un coût logistique relatif plus faible.**
4. **La contribution à la marge varie selon les segments clients et les catégories de produits.**

Ces hypothèses sont confrontées aux données à travers les différents axes du tableau de bord. Les résultats décrivent des associations observées dans les données et ne constituent pas, à eux seuls, des preuves de causalité.

---

## 📊 Quelques chiffres clés

| Indicateur                  |          Valeur |
| --------------------------- | --------------: |
| Chiffre d'affaires          |    **12,64 M$** |
| Marge nette                 |     **1,47 M$** |
| Taux de marge               |     **11,61 %** |
| Commandes déficitaires      |     **24,47 %** |
| Chiffre d'affaires à risque |     **2,36 M$** |
| Transactions analysées      |      **51 291** |
| Période                     | **2011 à 2014** |

---

# 📊 Dashboard

## 💰 Analyse de la rentabilité

Cette page permet d'étudier la relation entre les ventes, les remises et la rentabilité. L'analyse montre notamment une dégradation progressive du taux de marge lorsque le niveau de remise augmente. Les sous-catégories sont également comparées afin d'identifier les différences de contribution à la performance.

Les données montrent un taux de marge de **17,23 % sans remise**, contre **-5,53 % pour les remises de 10 à 20 %** et **-45,25 % pour les remises de 30 à 40 %**.

![Analyse de la rentabilité](screenshots/Analyse%20de%20la%20rentabilit%C3%A9.png)

---

## 🌍 Analyse des marchés

Cette page analyse la performance commerciale selon les marchés géographiques. Elle permet de comparer les niveaux de marge et la proportion de commandes déficitaires afin de faire ressortir les différences de performance entre les zones.

Dans les données analysées, les taux de marge observés varient de **5,01 % pour EMEA** à **26,62 % pour le Canada**. La proportion de commandes déficitaires atteint **30,84 % sur EMEA**.

![Analyse des marchés](screenshots/Analyse%20des%20march%C3%A9s.png)

---

## 🚚 Analyse logistique

Cette page examine les volumes de commandes selon le mode d'expédition ainsi que le coût logistique relatif selon la taille des commandes.

**Standard Class** représente le volume d'expédition le plus important avec environ **15,2 K commandes**. Le coût logistique relatif passe de **11,14 % pour les commandes de taille 1 à 9,99 % pour les commandes de 11 unités ou plus** dans les regroupements utilisés pour l'analyse.

![Analyse logistique](screenshots/Analyse%20logistique.png)

---

## 📅 Analyse temporelle

Cette page permet de suivre l'évolution du chiffre d'affaires et de la marge sur la période 2011 à 2014. Les indicateurs temporels permettent notamment d'observer la croissance du chiffre d'affaires et l'évolution de la marge au fil des années.

Sur la période analysée, le chiffre d'affaires atteint **12,64 M$**, avec une croissance du chiffre d'affaires de **51,54 %**.

![Analyse temporelle](screenshots/Analyse%20temporelle.png)

---

# 🔎 Principaux résultats

### Rentabilité et remises

L'analyse des tranches de remise montre une association nette entre les niveaux de remise élevés et des taux de marge plus faibles.

| Tranche de remise |    CA total | Taux de marge |
| ----------------- | ----------: | ------------: |
| 0 %               | 6 992 734 $ |   **17,23 %** |
| 0 à 10 %          | 1 962 633 $ |    **9,86 %** |
| 10 à 20 %         | 1 757 296 $ |   **-5,53 %** |
| 20 à 30 %         |   701 367 $ |  **-23,68 %** |
| 30 à 40 %         |   474 711 $ |  **-45,25 %** |
| 40 à 50 %         |   371 624 $ | **-111,02 %** |

### Produits

Plusieurs sous-catégories présentent des niveaux de marge élevés, notamment :

* **Paper : 24,23 %**
* **Labels : 20,44 %**
* **Envelopes : 17,32 %**
* **Accessories : 17,30 %**
* **Copiers : 17,13 %**

La sous-catégorie **Tables** présente un taux de marge négatif de **-8,47 %** dans les données analysées.

### Marchés

Les taux de marge observés sont les suivants :

| Marché | Taux de marge |
| ------ | ------------: |
| Canada |   **26,62 %** |
| EU     |   **12,74 %** |
| US     |   **12,47 %** |
| APAC   |   **12,18 %** |
| Africa |   **11,34 %** |
| LATAM  |   **10,24 %** |
| EMEA   |    **5,01 %** |

La proportion de commandes déficitaires varie également selon les marchés, avec **30,84 % pour EMEA** contre **0 % pour Canada** dans les données analysées.

### Segments clients

Les taux de marge globaux observés sont :

| Segment     | Taux de marge |
| ----------- | ------------: |
| Consumer    |   **11,51 %** |
| Corporate   |   **11,54 %** |
| Home Office |   **11,99 %** |

Les différences entre segments restent relativement limitées sur l'ensemble du portefeuille analysé.

---

# 🧹 Qualité des données

Lors de la préparation des données, une anomalie a été identifiée sur la variable `Ship Date`.

La colonne était corrompue et ne contenait pas de dates exploitables. Elle a donc été **exclue du modèle** afin de ne pas introduire une information non fiable dans les analyses.

Les analyses temporelles reposent ainsi sur la dimension `Dim_Date` et la date disponible dans le modèle.

---

# 🏗️ Modélisation des données

Le modèle Power BI repose sur une **architecture en étoile (Star Schema)**.

### Table de faits

`Fact_Sales`

* 51 291 lignes
* Ventes
* Profit
* Quantité
* Remise
* Coût d'expédition
* Clés de liaison vers les dimensions

### Dimensions

`Dim_Customer`

* 4 874 lignes
* Client
* Nom du client
* Segment

`Dim_Product`

* 10 769 lignes
* Produit
* Nom du produit
* Catégorie
* Sous-catégorie

`Dim_Geography`

* 3 813 lignes
* Ville
* État
* Pays
* Région
* Marché

`Dim_ShippingProfile`

* 13 lignes
* Mode d'expédition
* Priorité de commande

`Dim_Date`

* 1 462 lignes
* Date
* Année
* Trimestre
* Mois
* Semaine
* Jour de la semaine
* Indicateur de week-end

Deux tables de référence complètent le modèle :

* `Ref_CountryMapping`
* `Ref_RegionCorrection`

Les dimensions sont reliées à la table de faits selon une logique de relations **1 → N**.

---

# 🧮 Mesures DAX principales

### Chiffre d'affaires total

```DAX
CA Total =
SUM(Fact_Sales[Sales])
```

### Marge nette

```DAX
Marge Nette =
SUM(Fact_Sales[Profit])
```

### Taux de marge

```DAX
Taux de Marge =
DIVIDE(
    [Marge Nette],
    [CA Total]
)
```

### Remise moyenne pondérée

```DAX
Remise Moyenne Pondérée =
DIVIDE(
    SUMX(
        Fact_Sales,
        Fact_Sales[Discount] * Fact_Sales[Sales]
    ),
    [CA Total]
)
```

---

# 🛠️ Technologies et outils

* **Power BI Desktop**
* **Power Query**
* **DAX**
* **Modélisation dimensionnelle**
* **Star Schema**
* **Git**
* **GitHub**

---

# 🎓 Compétences mobilisées

Ce projet met en pratique plusieurs compétences de Data Analytics et de Business Intelligence :

* Nettoyage et préparation des données
* Transformation des données avec Power Query
* Modélisation en étoile
* Création de mesures DAX
* Construction de KPI
* Analyse de rentabilité
* Analyse géographique
* Analyse des segments clients
* Analyse logistique
* Analyse temporelle
* Data Visualization
* Storytelling décisionnel

---

# 📁 Structure du projet

```text
Global Superstore/
│
├── Global Superstore.pbix
├── README.md
│
├── Data/
│   ├── Global Superstore.csv
│   └── GlobalSuperstore_StarSchema.xlsx
│
└── screenshots/
    ├── Analyse de la rentabilité.png
    ├── Analyse des marchés.png
    ├── Analyse logistique.png
    └── Analyse temporelle.png
```

---

# 👤 Auteur

**Fabrice Bomisso**

**Data Analyst | Power BI · Excel · Python | Data Visualization | Business Intelligence**
