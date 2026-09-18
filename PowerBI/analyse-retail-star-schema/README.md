# Retail Analytics 2024 | Star Schema, Audit DAX & Dashboard Power BI

## 📌 Overview

Projet Power BI complet sur un an de ventes retail : 1 000 000 transactions, 2,75 Md€ de CA, 100 000 clients, 500 magasins, 2 000 commerciaux et 50 campagnes marketing.

Le cœur du projet n'est pas uniquement le dashboard final, mais surtout la démarche d'audit qui l'a précédé. Six bugs DAX réels ont été diagnostiqués par recoupement systématique entre les exports du dashboard et un recalcul indépendant sur les données sources. Une hypothèse métier concernant le segment client « Churn Risk » a également été testée puis invalidée. Enfin, une découverte analytique a permis de nuancer une conclusion établie plus tôt dans le projet.

## 🎯 Business Problem

Avant de présenter des chiffres à un comité de direction, il faut s'assurer qu'ils sont exacts et pas seulement qu'ils s'affichent correctement.

Ce projet documente cette démarche. Chaque mesure DAX suspecte a été comparée à un recalcul indépendant sur les données sources avant validation. Les conclusions intuitives, notamment sur les segments à risque et les écarts de performance entre rôles, ont également été vérifiées avant d'être présentées comme des faits.

## ❓ Analytical Questions

* Les chiffres affichés dans le dashboard sont-ils fiables et peut-on les recouper indépendamment ?
* Le segment client « Churn Risk » reflète-t-il un véritable comportement d'achat ou simplement une étiquette arbitraire ?
* L'écart de chiffre d'affaires observé entre les rôles commerciaux traduit-il une différence de performance individuelle ?
* Où se situe la vraie variance actionnable dans ce dataset : campagnes, catégories ou segments ?
* Quelle est la dynamique temporelle réelle du CA sur l'année ?

## 📊 Dataset

* **Source** : `[INFORMATION À CONFIRMER]`
* **Modèle en étoile** : 1 table de faits (`fact_sales`) et 6 dimensions.
* **Volumétrie réelle dans Power BI** : `fact_sales` = 1 000 000 lignes, `dim_customers` = 100 000 clients répartis sur 10 segments, `dim_products` = 210 produits répartis sur 6 catégories, `dim_stores` = 500 magasins répartis sur 3 types, `dim_salespersons` = 2 000 commerciaux répartis sur 4 rôles, `dim_campaigns` = 50 campagnes et `dim_dates` = 366 jours couvrant uniquement l'année 2024.
* **Point de vigilance documenté** : les fichiers CSV utilisés pour les vérifications hors Power BI ne contiennent que 400 000 lignes, soit un échantillon de 40 %. Le ratio exact de 2,5 a été confirmé sur plusieurs métriques. Le volume des CSV ne correspond donc pas au volume réel du modèle Power BI. Ce point a été documenté afin d'éviter de reproduire cette erreur de comparaison.

## 🔎 Data Quality

| Anomalie                                   | Détection                                                                                                                                         | Traitement                                                                                                                  | Impact                                                                                                                                                                                           |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Homonymie commerciaux (`salesperson_name`) | 21 noms sur 2 000 correspondent à des personnes différentes, par exemple 2 « William Clark » distincts                                            | Regroupement sur la clé unique `salesperson_sk` ; création de `salesperson_display = nom (ID)` dans Power Query             | Sans correction, « Meilleur Commercial » désignait un artefact de fusion. Les 3 « Michael Davis » cumulés représentaient 1,62 M€, alors que le véritable n°1 était Nicole Simpson avec 737 804 € |
| Homonymie produits (`product_name`)        | « Running Shoes » regroupait 4 produits distincts, avec 3 marques et 2 catégories                                                                 | Création de `product_display = nom (ID)` ; `brand` seul ne suffisait pas, car 2 « Running Shoes » de marque Puma existaient | Le Top 10 Produits affichait un faux n°1 cumulant 20,9 M€ contre 5,6 M€ pour le véritable n°1                                                                                                    |
| `store_name` non unique                    | 500 magasins pour seulement 50 noms distincts, soit environ 10 occurrences par nom                                                                | Vérification effectuée : structure de franchise légitime et non anomalie. Création de `store_display` par prévention        | Aucun impact sur les visuels actuels, la carte utilise `store_location`                                                                                                                          |
| Espace parasite sur `store_type`           | « Supermarkets » avec un espace final détecté lors de la comparaison des valeurs distinctes du CSV brut                                           | Application de `Text.Trim()` dans Power Query                                                                               | Sans correction, le donut de répartition affichait 4 segments au lieu de 3                                                                                                                       |
| Échantillon CSV à 40 % du volume réel      | Écart entre la volumétrie annoncée de 1M de lignes et les 400K lignes des CSV fournis                                                             | Vérification avec `COUNTROWS` et recoupement sur plusieurs métriques, avec un ratio exact de 2,5                            | Aucune duplication réelle. L'erreur de comparaison a été identifiée et documentée comme piège méthodologique                                                                                     |
| Segment « Churn Risk » non comportemental  | Test RFM direct : fréquence d'achat avec un écart de 0,7 % et récence individuelle moyenne avec un écart de 1,4 % par rapport aux autres segments | Aucune correction de donnée. Conclusion documentée comme limite du dataset                                                  | Évite de déclencher à tort une action de rétention marketing basée sur ce label                                                                                                                  |

## 🧹 Data Preparation

Des colonnes d'affichage désambiguïsées ont été créées dans **Power Query** pour les dimensions présentant un risque d'homonymie : `product_display`, `salesperson_display` et `store_display`, toutes au format `nom (ID)`.

Le champ `store_type` a été nettoyé avec `Text.Trim()`.

Des colonnes calculées ont également été créées pour la frise chronologique des campagnes : `Date Début Campagne` via `LOOKUPVALUE` et `Jours Depuis Debut Annee` via `DATEDIFF`. Ces éléments ont été créés sous forme de colonnes plutôt que de mesures puisqu'ils ne dépendent d'aucun contexte de filtre.

## 🧱 Data Model

Le modèle repose sur un schéma en étoile classique avec `fact_sales` reliée à 6 dimensions.

Un point particulier concerne `dim_campaigns` et `dim_dates`. La table `dim_campaigns` référence `dim_dates` deux fois avec `start_date_sk` et `end_date_sk`. Cette configuration crée une ambiguïté puisque Power BI ne permet qu'une seule relation active entre deux tables.

La décision retenue a donc été de ne créer aucune relation active entre ces deux tables et de récupérer la date de début avec `LOOKUPVALUE` dans une colonne calculée.

La conséquence est assumée et documentée : le slicer Période ne filtre pas les visuels construits uniquement sur `dim_campaigns`, notamment la frise des campagnes. Ce comportement est cohérent avec le besoin métier, puisqu'un calendrier de campagne ne doit pas être modifié par un filtre de période appliqué à d'autres éléments du rapport.

## 📐 Analytical Approach : 6 bugs DAX diagnostiqués et corrigés

| Bug                                         | Symptôme                                                                                      | Cause racine                                                                                                                        | Correctif                                                                                                         |
| ------------------------------------------- | --------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `CA Campagnes Connues`                      | La mesure renvoyait le grand total de 2,75 Md€ pour les 50 campagnes au lieu d'un CA distinct | Un filtre `CALCULATE` sur une colonne remplace le contexte de filtre existant au lieu de s'y ajouter                                | Ajout de `KEEPFILTERS()` pour forcer l'intersection                                                               |
| `Meilleur Commercial` / `CA par Commercial` | Un « meilleur vendeur » qui n'existait pas individuellement apparaissait dans le résultat     | Regroupement sur `salesperson_name`, qui n'est pas unique, au lieu de `salesperson_sk`                                              | Regroupement sur la clé technique et résolution du libellé uniquement à l'affichage avec `LOOKUPVALUE`            |
| `ROI Campagne %`                            | 957 765,98 % affiché au niveau agrégé                                                         | Le DAX multipliait déjà par 100 et le format natif « Pourcentage » multipliait une seconde fois                                     | Suppression du `*100` dans le DAX et ajout d'un garde-fou `HASONEVALUE` pour bloquer l'affichage au niveau agrégé |
| `Croissance QoQ %`                          | Les 3 mois d'un même trimestre affichaient 3 valeurs différentes                              | Asymétrie de granularité : le CA courant restait au grain du visuel, soit 1 mois, alors que la période de référence couvrait 3 mois | Création de `CA Trimestre Courant` pour forcer l'élargissement au trimestre entier                                |
| `Croissance MoM %`                          | -83,68 % en décembre, interprétable à tort comme un effondrement de l'activité                | Comparaison avec un mois incomplet, 26 jours sur 31                                                                                 | Ajout d'un garde-fou bloquant l'affichage sur les mois non comparables : janvier, février et décembre             |
| `Métrique Dynamique`                        | La carte affichait littéralement « € #,##0.00 » au lieu d'un montant                          | Confusion entre le corps de la mesure et la propriété de formatage dynamique `fx`                                                   | Séparation des deux objets : calcul d'un côté et formatage de l'autre                                             |

**Point de vigilance méthodologique :** une première extrapolation erronée avait laissé penser que le bug de double comptage du ROI concernait également les valeurs de chaque campagne. Une vérification manuelle a permis de confirmer que ce n'était pas le cas. Cette autocorrection est conservée dans la documentation afin de montrer que les résultats ont été vérifiés à plusieurs niveaux.

### Investigation RFM : hypothèse testée et invalidée

Le segment client « Churn Risk » pouvait sembler préoccupant pour une direction marketing.

Trois niveaux de vérification ont été appliqués. La première étape a consisté à comparer la fréquence moyenne des transactions par segment. L'écart observé était de seulement 0,7 %. La deuxième étape a porté sur la récence moyenne calculée au niveau de chaque client, afin d'éviter le biais lié à la taille des groupes. Le résultat montre que le segment Churn Risk, avec une récence moyenne de 42,37 jours, ne se distingue pas significativement des segments High Value et Loyal Customer.

La conclusion repose donc sur les données observées et non sur le nom du segment : le label « Churn Risk » ne correspond à aucune différence mesurable de comportement d'achat.

### Découverte tardive : l'écart de CA par rôle commercial est un effet d'effectif

La création d'un donut « Effectif par Rôle » sur la Page 5 a permis de répondre à une question restée ouverte pendant l'audit.

L'écart de CA entre les rôles, d'environ 16,3 %, suit le même classement et une amplitude quasiment identique à l'écart d'effectif entre ces rôles, lui aussi proche de 16,3 %.

La conclusion est donc différente de l'hypothèse initiale : il ne s'agit pas d'une différence de performance individuelle, mais d'un effet de volume. Plus un rôle compte de commerciaux, plus son CA cumulé est élevé.

Cette découverte a permis de nuancer et de corriger une conclusion précédente du projet.

## 📊 Dashboard

### Page 1 : Vue Générale

**Objectif :** proposer une synthèse globale et pilotable.

**KPI :** Métrique Dynamique pilotée par un slicer déconnecté, CA cumulé YTD de 2,75 Md€, CA du mois en cours de 371 M€, basé sur le dernier mois complet, avec une tendance de -12,19 %, et nombre de transactions.

**Analyses :** évolution mensuelle du CA avec une courbe et répartition du CA par type de magasin avec un donut comprenant 3 segments après nettoyage de `store_type`.

**Insights :** une zone de texte présente le « Segment à Surveiller » avec un ton neutre. Le CA de ce segment reste comparable à celui des 9 autres segments, avec un écart inférieur à 2 %.

![Vue Générale](screenshots/01-vue-generale.jpg)

### Page 2 : Ventes & Produits

**Objectif :** analyser la performance par catégorie et par produit.

**KPI :** intégrés au tableau catégorie × mois.

**Analyses :** matrice Catégorie × Mois avec mise en forme conditionnelle, Top 10 Produits par CA basé sur `product_display` et non sur `product_name` seul, ainsi qu'une carte géographique des ventes.

**Insights :** l'évolution du Top 5 Produits au fil du temps montre des courbes quasiment superposées toute l'année. Il s'agit d'une nouvelle confirmation du motif d'uniformité observé à plusieurs niveaux du dataset.

![Ventes & Produits](screenshots/02-ventes-produits.jpg)

### Page 3 : Clients & CRM

**Objectif :** comprendre la base client par segment.

**KPI :** 100K clients actifs et panier moyen de 3K$.

**Analyses :** CA par segment client, carte géographique des clients, table détaillée par segment et table Fréquence/Récence pour l'analyse RFM.

**Insights :** la table RFM constitue la preuve directe de l'invalidation du segment « Churn Risk ». Sa fréquence et sa récence sont très proches de celles des autres segments.

![Clients & CRM](screenshots/03-clients-crm.jpg)

### Page 4 : Campagnes

**Objectif :** évaluer le retour sur investissement marketing.

**KPI :** budget campagne de 28 M$, CA Campagnes Connues de 3 Md$, meilleure campagne en ROI : Green Weekend Deals, campagne à réviser : Mid-Year Madness.

**Analyses :** Top 10 Campagnes par Multiple de Retour plutôt que par ROI brut pour améliorer la lisibilité. Une frise des campagnes 2024 a également été construite sous la forme d'un faux Gantt avec des barres empilées standard et un segment invisible permettant de positionner le début de chaque campagne.

**Insights :** le ROI par campagne varie de 54,78 % à 520,28 %, soit un facteur de variation de ×9,5. C'est la principale source de variance actionnable identifiée dans le dataset. Cette variation est principalement liée à la taille du budget engagé et non à une différence nette de performance intrinsèque entre les campagnes.

![Campagnes](screenshots/04-campagnes.jpg)

### Page 5 : Équipe Commerciale

**Objectif :** analyser la performance commerciale par individu et par rôle.

**KPI :** meilleur commercial : Nicole Simpson, SP01934 ; CA moyen par commercial : 1 M$ ; commerciaux actifs : 2K.

**Analyses :** Top 10 Commerciaux par CA basé sur `salesperson_display`, donut du CA par rôle et donut de l'effectif par rôle.

**Insights :** la comparaison des deux donuts montre que l'écart de CA par rôle, proche de 16 %, correspond principalement à un effet d'effectif et non à une différence de performance individuelle.

![Équipe Commerciale](screenshots/05-equipe-commerciale.jpg)

## 🔑 Key Insights

* **Observation :** le CA individuel des produits, catégories, marques et segments clients est quasiment identique à chaque niveau de granularité testé, avec des écarts compris entre 1,8 % et 2,5 %, confirmés sur 6 découpes indépendantes. **Interprétation :** ce résultat est cohérent avec une génération de données synthétique basée sur une distribution homogène plutôt qu'avec des dynamiques commerciales réellement contrastées. **Implication métier :** il n'est pas pertinent de rechercher des « champions » ou des « mauvais élèves » par catégorie ou par segment, car ce levier n'existe pas réellement dans ce dataset.
* **Observation :** l'écart de CA par rôle commercial, proche de 16 %, suit le même classement et la même amplitude que l'écart d'effectif. **Interprétation :** il s'agit d'un effet de volume et non d'une différence de performance individuelle. **Implication métier :** aucune conclusion RH ou managériale ne doit être tirée de cet écart brut.
* **Observation :** le ROI par campagne varie d'un facteur ×9,5 selon le budget engagé. **Interprétation :** il s'agit de la principale source de variance actionnable du dataset. **Implication métier :** l'optimisation doit se concentrer sur le ciblage des campagnes et la répartition des budgets plutôt que sur une réallocation entre catégories ou segments.
* **Observation :** le segment « Churn Risk » ne se distingue des 9 autres ni en CA, ni en fréquence d'achat, ni en récence individuelle. **Interprétation :** l'étiquette semble avoir été assignée en amont plutôt que calculée à partir du comportement réel. **Implication métier :** aucune action de rétention ne devrait être pilotée sur cette base tant qu'un véritable score RFM n'aura pas remplacé la catégorie actuelle.

## 💡 Business Recommendations

* Prioriser le budget marketing sur les campagnes ayant démontré un ROI élevé, notamment Green Weekend Deals et les campagnes présentant des caractéristiques similaires.
* Suspendre toute action de rétention basée sur le segment « Churn Risk » actuel tant qu'un véritable calcul RFM n'aura pas remplacé cette catégorie.
* Adapter les temps forts opérationnels, notamment les stocks, les effectifs et la publicité, à la saisonnalité observée avec un creux en janvier et décembre et un pic entre septembre et novembre.
* Ne pas tirer de conclusion RH à partir de l'écart de CA entre les rôles commerciaux, puisque cet écart est principalement lié à l'effectif.

## 🛠️ Technologies

Power BI Desktop · Power Query (M) · DAX (`KEEPFILTERS`, `SUMMARIZE`, `HASONEVALUE`, `DATESBETWEEN`, `STARTOFQUARTER`, `ENDOFQUARTER`, `SELECTEDVALUE`, `LOOKUPVALUE`, mesures avec métrique dynamique) · Modélisation en étoile

## 📁 Project Structure

```text
analyse-retail-star-schema/
├── README_projet_retail.md
├── screenshots/
│   ├── 01-vue-generale.jpg
│   ├── 02-ventes-produits.jpg
│   ├── 03-clients-crm.jpg
│   ├── 04-campagnes.jpg
│   └── 05-equipe-commerciale.jpg
├── documentation/
│   └── Retail_Star_Schema_Documentation_Technique_v3.docx   # Journal complet de l'audit, sections 1 à 11
├── data/       # [À COMPLÉTER EN LOCAL]
├── pbix/       # [À COMPLÉTER EN LOCAL]
```

## ▶️ How to Explore

`[À COMPLÉTER EN LOCAL]` : préciser si le fichier `.pbix` sera publié tel quel dans `pbix/` ou si seuls les captures et la documentation seront disponibles.

## ⚠️ Limitations

* `dim_dates` ne couvre que l'année 2024. Les mesures de comparaison YoY sont donc structurellement inactives et renvoient `BLANK()`. Il ne s'agit pas d'un bug.
* Le ROI par campagne mesure un rapport CA attribué / budget et non un effet marginal réel. Le modèle attribue l'ensemble du CA d'une période à la campagne active, sans contrôle contrefactuel.
* Des homonymies structurelles existent dans 3 des 6 dimensions : commerciaux, produits et magasins. Elles ont été corrigées pour les visuels existants, mais doivent être revérifiées avant tout nouveau visuel utilisant un champ texte dont l'unicité n'est pas garantie.
* La distribution quasi uniforme observée à tous les niveaux testés est une caractéristique réelle du dataset, probablement liée à son caractère synthétique. Elle ne constitue pas une limite de l'analyse, mais ne doit pas être interprétée comme une absence de travail analytique.

## 🚧 Points en attente

* Page 1 : flèche de tendance colorée sur la carte « CA Mois En Cours », fonctionnalité identifiée mais non finalisée.
* Page 3 : signet `Focus_ChurnRisk` reliant un bouton de la Page 1 à la Page 3 avec un filtre sur Churn Risk. Configuration en pause, méthode de reprise documentée dans le projet.

## 🚀 Future Improvements

* Finaliser les deux points actuellement en attente.
* Remplacer le label « Churn Risk » par un véritable score RFM calculé, maintenant que l'hypothèse actuelle a été invalidée par les données.
* Étendre `dim_dates` à plusieurs années si le dataset évolue afin d'activer les mesures de comparaison YoY déjà préparées.

---

## 🎓 Skills Demonstrated

| Compétence        | Preuve                                                                                                                |
| ----------------- | --------------------------------------------------------------------------------------------------------------------- |
| Data Quality      | Diagnostic de 6 bugs DAX réels par recoupement entre le dashboard et un recalcul indépendant                          |
| DAX avancé        | Correction de plusieurs problèmes liés aux filtres, à la granularité temporelle, au formatage et aux clés non uniques |
| Power Query (M)   | Création de colonnes d'affichage désambiguïsées et nettoyage des données avec `Text.Trim`                             |
| Data Modeling     | Résolution d'une ambiguïté de modélisation entre `dim_campaigns` et `dim_dates` avec une décision documentée          |
| Statistics        | Analyse RFM basée sur la fréquence et la récence individuelle pour tester une hypothèse métier                        |
| Business Analysis | Distinction entre corrélation apparente et cause réelle dans l'analyse du CA par rôle                                 |
| Problem Solving   | Vérification et correction d'une première interprétation erronée au cours de l'audit                                  |
