# Customer Churn Prediction | From Data to Business Decision

## Présentation

Ce projet porte sur la prédiction du churn client dans le secteur des télécommunications.

L'objectif est d'identifier les clients susceptibles de quitter l'entreprise, d'analyser les principaux facteurs associés au churn et d'utiliser les résultats du modèle pour aider à prioriser les actions de fidélisation.

Le projet couvre les différentes étapes d'un projet de Data Science, depuis la préparation des données jusqu'à l'intégration du modèle dans une application Streamlit.

**Problématique :** comment identifier suffisamment tôt les clients présentant un risque élevé de churn afin de permettre aux équipes métier de cibler leurs actions de fidélisation ?

**Solution :** un modèle de classification basé sur un **Random Forest**, accompagné d'une analyse SHAP, d'une segmentation des clients selon leur niveau de risque et d'une application Streamlit permettant d'effectuer des prédictions individuelles.

---

## Objectifs du projet

- Analyser les facteurs associés au churn client
- Nettoyer et préparer les données
- Créer de nouvelles variables pour enrichir les données disponibles
- Comparer plusieurs modèles de classification
- Sélectionner le modèle le plus adapté à l'objectif de prédiction
- Interpréter les prédictions avec SHAP
- Attribuer un niveau de risque aux clients
- Identifier des pistes d'actions pour les équipes métier
- Intégrer le modèle dans une application Streamlit

---

## Dataset

**Source :** IBM Telco Customer Churn Dataset

**Dataset utilisé :** `WA_Fn-UseC_-Telco-Customer-Churn.csv`

**Taille :**

- 7 043 clients
- 21 variables initiales
- Variable cible : `Churn`

Le dataset contient notamment des informations concernant :

- le profil démographique ;
- l'ancienneté du client ;
- les services souscrits ;
- le type de contrat ;
- les méthodes de paiement ;
- les charges mensuelles et totales.

---

## Méthodologie

Le projet suit les principales étapes suivantes :

**Données → Nettoyage → EDA → Feature Engineering → Modélisation → Évaluation → SHAP → Segmentation → Recommandations métier → Application Streamlit**

---

## 01. Nettoyage des données

Avant la modélisation, plusieurs contrôles ont été effectués sur les données.

### Principales opérations

- Conversion de `TotalCharges` en variable numérique
- Transformation de `Churn` en variable binaire
- Traitement des valeurs manquantes
- Vérification des types de données
- Préparation des variables catégorielles et numériques

Les valeurs manquantes de `TotalCharges` correspondent aux clients ayant une ancienneté nulle. Leur traitement a donc été réalisé en tenant compte de cette situation.

---

## 02. Feature Engineering

De nouvelles variables ont été créées afin de mieux représenter certaines caractéristiques des clients.

Parmi les variables utilisées :

- `tenure_years`
- `is_new_customer`
- `is_young_customer`
- `high_monthly_charges`
- `low_monthly_charges`
- `num_services`
- `has_multiple_services`
- `has_tech_support`
- `has_security`
- `is_automatic_payment`
- `is_long_contract`
- `risky_profile`

Ces variables permettent notamment de prendre en compte l'ancienneté, le niveau d'équipement, le type d'engagement et certains profils associés à un risque de churn plus important.

---

## 03. Analyse exploratoire

L'analyse exploratoire a permis d'observer plusieurs différences de churn selon les caractéristiques des clients.

| Facteur | Observation |
| --- | --- |
| **Ancienneté** | Les clients les moins anciens présentent davantage de churn |
| **Contrat** | Les contrats `Month-to-month` sont davantage associés au churn |
| **Internet** | Le taux de churn est plus élevé chez les clients `Fiber optic` dans les données analysées |
| **Paiement** | `Electronic check` présente un taux de churn élevé |
| **Services** | Certains services additionnels sont associés à un churn plus faible |

Ces observations permettent de mieux comprendre les données avant la phase de modélisation.

Elles décrivent toutefois des associations observées dans le dataset et ne permettent pas, à elles seules, de conclure à une relation causale.

---

## 04. Modélisation

Deux modèles de classification ont été étudiés :

- **Logistic Regression**
- **Random Forest**

Le **Recall** a été particulièrement pris en compte. Dans ce contexte, manquer un client qui va réellement churner peut être plus problématique que de classer à risque un client qui restera finalement.

### Random Forest : modèle retenu

| Métrique | Résultat |
| --- | ---: |
| Accuracy | 79,0 % |
| Recall | **77,81 %** |
| F1-score | **63,75 %** |
| ROC-AUC | **0,85** |

Le Random Forest a été retenu pour la suite du projet.

Sur le jeu de test, il obtient un **Recall de 77,81 %**, ce qui signifie qu'il identifie une part importante des clients ayant réellement churné.

---

## 05. Explainability avec SHAP

SHAP a été utilisé pour analyser l'influence des variables dans les prédictions du modèle.

Les principales variables identifiées sont notamment :

1. `is_long_contract`
2. `InternetService_Fiber optic`
3. `tenure_years`
4. `tenure`
5. `Contract_Two year`

Les résultats montrent notamment l'importance de variables liées à l'engagement contractuel, à l'ancienneté et au service Internet.

L'analyse SHAP permet ainsi de compléter les métriques de performance avec une meilleure compréhension des prédictions du modèle.

---

## 06. Segmentation des clients à risque

Le modèle a été utilisé pour calculer un score de risque pour les **1 409 clients du jeu de test**.

Les clients ont ensuite été répartis en trois catégories :

| Catégorie | Clients | Churn réel | Score moyen | Ancienneté moyenne |
| --- | ---: | ---: | ---: | ---: |
| 🔴 **ÉLEVÉ** | 295 | **66,4 %** | 81,4 % | 8,1 mois |
| 🟠 **MOYEN** | 332 | **35,8 %** | 55,9 % | 23,6 mois |
| 🟢 **FAIBLE** | 782 | **7,5 %** | 15,5 % | 44,5 mois |

Le groupe **ÉLEVÉ** présente un taux de churn réel de **66,4 %**, contre **7,5 %** pour le groupe **FAIBLE**.

Cette différence permet de distinguer clairement plusieurs niveaux de risque sur le jeu de test.

---

## 07. Recommandations métier

Les résultats du modèle peuvent être utilisés pour aider à prioriser les actions de fidélisation.

### Risque élevé

Les clients de cette catégorie présentent plusieurs caractéristiques fréquemment associées au churn :

- faible ancienneté ;
- contrat `Month-to-month` ;
- paiement par `Electronic check` ;
- certains profils utilisant `Fiber optic` ;
- faible niveau de services additionnels.

**Actions possibles :**

- contacter le client de manière proactive ;
- vérifier son niveau de satisfaction ;
- proposer des services complémentaires adaptés ;
- encourager l'utilisation du paiement automatique ;
- proposer un contrat plus long lorsque cela correspond à son profil.

### Risque moyen

L'objectif est de surveiller ces clients et d'identifier les situations pouvant conduire à une augmentation du risque.

**Actions possibles :**

- suivi régulier ;
- analyse de la satisfaction ;
- proposition de services adaptés ;
- présentation d'offres ou de contrats plus engageants lorsque cela est pertinent.

### Risque faible

L'objectif est principalement de maintenir une bonne relation avec ces clients.

**Actions possibles :**

- programme de fidélisation ;
- suivi de satisfaction ;
- maintien de la qualité de service ;
- valorisation de la fidélité.

> **Important :** les recommandations présentées ici sont basées sur les tendances observées dans les données. Elles ne permettent pas de garantir qu'une action donnée réduira le churn. Leur efficacité doit être mesurée à partir de données métier et, lorsque cela est possible, au moyen d'expérimentations comme les tests A/B.

---

## 08. Application Streamlit

Le modèle a été intégré dans une application Streamlit permettant de saisir le profil d'un client et d'obtenir une estimation de son risque de churn.

### Parcours utilisateur

**Saisie du profil → Prétraitement → Prédiction → Score de risque → Catégorie → Facteurs clés → Recommandations**

L'application permet notamment de renseigner :

- le profil démographique ;
- l'ancienneté ;
- le type de contrat ;
- le service Internet ;
- les charges mensuelles ;
- la méthode de paiement ;
- les services additionnels.

La prédiction est réalisée à partir des artefacts sauvegardés lors de l'entraînement du modèle.

---

## Artefacts du modèle

Les fichiers nécessaires à l'application sont stockés dans le dossier `models/` :

```text
models/
├── churn_model.pkl
├── preprocessor.pkl
├── feature_names.pkl
└── thresholds.pkl
```

- `churn_model.pkl` : modèle Random Forest
- `preprocessor.pkl` : pipeline de prétraitement
- `feature_names.pkl` : noms des variables finales
- `thresholds.pkl` : seuils utilisés pour certaines variables dérivées

Le modèle final utilise **42 features après preprocessing**.

---

## Structure du projet

```text
UserGenerator/
│
├── app/
│   └── app.py
│
├── models/
│   ├── churn_model.pkl
│   ├── preprocessor.pkl
│   ├── feature_names.pkl
│   └── thresholds.pkl
│
├── Telco-Customer-Churn.ipynb
├── WA_Fn-UseC_-Telco-Customer-Churn.csv
├── requirements.txt
├── README.md
└── .gitignore
```

---

## Technologies utilisées

| Domaine | Technologies |
| --- | --- |
| Langage | Python |
| Manipulation des données | Pandas, NumPy |
| Visualisation | Matplotlib, Seaborn |
| Machine Learning | Scikit-learn |
| Modèle final | Random Forest |
| Explainability | SHAP |
| Prétraitement | ColumnTransformer, StandardScaler, OneHotEncoder |
| Sauvegarde | Joblib |
| Application | Streamlit |
| Environnement | Jupyter Notebook, VS Code |

---

## Installation et utilisation

### 1. Cloner le projet

```bash
git clone <URL_DU_REPOSITORY>
cd UserGenerator
```

### 2. Créer un environnement virtuel

```bash
python -m venv env
```

### 3. Activer l'environnement sous Windows

```bash
env\Scripts\activate
```

### 4. Installer les dépendances

```bash
pip install -r requirements.txt
```

### 5. Lancer l'application

```bash
python -m streamlit run app/app.py
```

L'application est ensuite accessible localement à :

```text
http://localhost:8501
```

---

## Limites du projet

### `TotalCharges`

Dans l'application Streamlit, `TotalCharges` est estimé à partir de :

```text
tenure × MonthlyCharges
```

Cette valeur constitue une approximation utilisée pour la prédiction d'un nouveau profil.

Pour une utilisation en production, la valeur réelle provenant du système d'information client serait préférable.

### Données historiques

Le modèle est entraîné sur des données historiques. Les associations observées dans ces données ne doivent pas être interprétées automatiquement comme des relations causales.

### Recommandations métier

Les recommandations proposées constituent des pistes d'action. Leur impact réel doit être mesuré à partir de données métier et d'expérimentations.

### Données statiques

Le modèle n'est actuellement connecté ni à un système de données temps réel ni à un mécanisme automatique de réentraînement.

---

## Perspectives d'amélioration

Plusieurs évolutions sont possibles :

- intégration de données CRM en temps réel ;
- utilisation du véritable `TotalCharges` ;
- ajout de données comportementales ;
- suivi des performances du modèle après déploiement ;
- réentraînement automatique ;
- scoring des clients en batch ;
- intégration d'un dashboard de suivi du churn ;
- tests A/B pour mesurer l'efficacité des actions de rétention ;
- déploiement sur une infrastructure cloud.

---

## Auteur

**Fabrice BOMISSO**

Projet personnel de Data Science orienté **Machine Learning, Analytics et aide à la décision métier**.

---

## Licence

Ce projet est distribué sous licence MIT.
````
