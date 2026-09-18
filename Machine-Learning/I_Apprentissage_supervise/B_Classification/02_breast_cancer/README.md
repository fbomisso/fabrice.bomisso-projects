# 🧬 Classification des tumeurs du sein | De l'analyse à la prédiction

## Présentation

Ce projet porte sur la **classification de tumeurs du sein** à partir de caractéristiques numériques issues du jeu de données **Breast Cancer Wisconsin** disponible dans `scikit-learn`.

L'objectif est de construire un modèle capable de distinguer deux classes :

* 🔴 **Malignant** : tumeur maligne
* 🟢 **Benign** : tumeur bénigne

Le projet couvre les principales étapes d'un projet de Machine Learning supervisé, depuis l'exploration et la préparation des données jusqu'à la comparaison des modèles, l'optimisation des hyperparamètres, l'évaluation et l'intégration du modèle final dans une application Streamlit.

**Problématique :** comment construire un modèle de classification suffisamment performant pour distinguer les observations Malignant et Benign à partir de caractéristiques morphologiques des tumeurs ?

**Solution :** une approche comparative de plusieurs algorithmes de classification, suivie de la sélection d'une **régression logistique optimisée** intégrant une standardisation des variables et une recherche du meilleur hyperparamètre `C`.

> ⚠️ **Avertissement médical :** ce projet est exclusivement destiné à la démonstration d'une démarche de Machine Learning. Il ne constitue pas un outil de diagnostic médical et ne doit pas être utilisé pour prendre une décision clinique.

---

## 🎯 Objectifs du projet

* Explorer le jeu de données Breast Cancer Wisconsin
* Comprendre la structure et la distribution des variables
* Analyser les relations entre les caractéristiques et la cible
* Préparer les données pour la modélisation
* Standardiser les variables explicatives
* Construire une baseline de classification
* Comparer plusieurs algorithmes de classification
* Optimiser les modèles avec `GridSearchCV`
* Évaluer les performances avec plusieurs métriques
* Analyser les matrices de confusion et les courbes ROC
* Sélectionner le meilleur modèle
* Sauvegarder le pipeline final avec Joblib
* Intégrer le modèle dans une application Streamlit
* Tester le modèle sur des observations réelles du dataset

---

## 📊 Jeu de données

### Source

Le projet utilise le jeu de données **Breast Cancer Wisconsin (Diagnostic)** disponible directement via `scikit-learn` avec :

```python
sklearn.datasets.load_breast_cancer
```

### Taille du dataset

Le dataset contient :

* **569 observations**
* **30 variables explicatives**
* **1 variable cible**
* **31 colonnes au total après ajout de la cible**

Les 30 caractéristiques décrivent différentes propriétés morphologiques des noyaux cellulaires observés dans les tumeurs.

---

## 🧬 Variables utilisées

Les variables sont organisées autour de trois groupes de mesures.

### Mesures moyennes

* `mean radius`
* `mean texture`
* `mean perimeter`
* `mean area`
* `mean smoothness`
* `mean compactness`
* `mean concavity`
* `mean concave points`
* `mean symmetry`
* `mean fractal dimension`

### Erreurs standard

* `radius error`
* `texture error`
* `perimeter error`
* `area error`
* `smoothness error`
* `compactness error`
* `concavity error`
* `concave points error`
* `symmetry error`
* `fractal dimension error`

### Mesures des valeurs extrêmes

* `worst radius`
* `worst texture`
* `worst perimeter`
* `worst area`
* `worst smoothness`
* `worst compactness`
* `worst concavity`
* `worst concave points`
* `worst symmetry`
* `worst fractal dimension`

### Variable cible

La cible est codée selon la convention du dataset :

| Valeur | Classe       |
| -----: | ------------ |
|    `0` | 🔴 Malignant |
|    `1` | 🟢 Benign    |

---

## 🔄 Méthodologie

Le projet suit le pipeline suivant :

**Données → Exploration → Préparation → Standardisation → Baseline → Modélisation → Optimisation → Évaluation → Comparaison → Sélection → Sauvegarde → Application Streamlit**

---

# 01. Exploration des données

L'analyse exploratoire a permis de vérifier :

* les dimensions du dataset ;
* les types de données ;
* les valeurs manquantes ;
* la distribution des variables ;
* la distribution des classes ;
* les corrélations entre les variables ;
* les relations entre les caractéristiques et la variable cible.

Le dataset présente également une forte corrélation entre plusieurs variables morphologiques.

Cette situation constitue un point important pour l'interprétation des coefficients de la régression logistique.

---

# 02. Préparation des données

Les variables explicatives ont été séparées de la variable cible.

Le dataset a ensuite été divisé en deux parties :

* **80 % pour l'entraînement**
* **20 % pour le test**

La séparation a été réalisée avec une **stratification sur la variable cible** afin de conserver une répartition comparable des classes dans les deux ensembles.

### Répartition

| Ensemble     | Observations | Variables |
| ------------ | -----------: | --------: |
| Entraînement |          455 |        30 |
| Test         |          114 |        30 |
| Total        |          569 |        30 |

---

# 03. Standardisation

La standardisation est particulièrement importante pour plusieurs modèles étudiés dans ce projet, notamment la régression logistique, le KNN et le SVM.

Un `StandardScaler` a donc été utilisé.

La transformation est ajustée uniquement sur le jeu d'entraînement avant d'être appliquée au jeu de test.

Le pipeline final intègre directement cette étape afin d'éviter toute différence entre le traitement utilisé pendant l'entraînement et celui utilisé lors des prédictions.

---

# 04. Baseline

Une `DummyClassifier` utilisant la stratégie `most_frequent` a été utilisée comme modèle de référence.

Cette baseline permet de disposer d'un niveau de performance minimal auquel comparer les modèles de Machine Learning.

La baseline obtient une Accuracy d'environ **63,16 %**.

Cette étape permet de vérifier que les modèles entraînés apportent une réelle valeur ajoutée par rapport à une stratégie naïve.

---

# 05. Modélisation

Plusieurs algorithmes de classification ont été étudiés :

* Régression logistique
* KNN
* Arbre de décision
* Random Forest
* SVM

Les modèles ont été évalués à partir de plusieurs métriques :

* Accuracy
* Précision
* Rappel
* F1-score
* ROC-AUC

Cette comparaison permet d'éviter de sélectionner un modèle uniquement sur la base de l'Accuracy.

---

# 06. Optimisation de la régression logistique

La régression logistique a été intégrée dans un pipeline comprenant :

```text
StandardScaler → LogisticRegression
```

La recherche du meilleur hyperparamètre `C` a été réalisée avec `GridSearchCV`.

### Grille testée

```text
C = [0.001, 0.01, 0.1, 1, 10, 100]
```

La validation croisée stratifiée utilise :

* **5 folds**
* `shuffle=True`
* `random_state=42`
* métrique d'optimisation : **ROC-AUC**

### Meilleur paramètre

| Paramètre  |      Valeur |
| ---------- | ----------: |
| `C`        |       **1** |
| ROC-AUC CV | **99,59 %** |

Le modèle final est donc une **régression logistique avec `C = 1`**, précédée d'une standardisation.

---

# 07. Évaluation du modèle final

La régression logistique optimisée obtient les performances suivantes sur le jeu de test :

| Métrique      |    Résultat |
| ------------- | ----------: |
| **Accuracy**  | **98,25 %** |
| **Précision** | **98,61 %** |
| **Rappel**    | **98,61 %** |
| **F1-score**  | **98,61 %** |
| **ROC-AUC**   | **99,54 %** |

Le modèle classe correctement :

**112 observations sur 114**

avec seulement :

**2 erreurs de classification.**

La validation croisée confirme également la stabilité du modèle avec une ROC-AUC moyenne d'environ **99,59 %**, très proche de la ROC-AUC obtenue sur le jeu de test.

---

# 08. Matrice de confusion

La matrice de confusion du modèle final montre :

| Classe réelle / prédite | Malignant | Benign |
| ----------------------- | --------: | -----: |
| **Malignant**           |    **41** |  **1** |
| **Benign**              |     **1** | **71** |

Le modèle identifie donc correctement :

* **41 cas Malignant sur 42**
* **71 cas Benign sur 72**

Il produit :

* **1 faux négatif**
* **1 faux positif**

Cette matrice montre que le modèle présente une classification équilibrée entre les deux classes sur le jeu de test.

---

# 09. Comparaison des modèles

Les différents modèles optimisés ont été comparés sur le jeu de test.

| Modèle                                 |    Accuracy |   Précision |       Rappel |    F1-score |     ROC-AUC |
| -------------------------------------- | ----------: | ----------: | -----------: | ----------: | ----------: |
| 🥇 **Régression logistique optimisée** | **98,25 %** | **98,61 %** |  **98,61 %** | **98,61 %** | **99,54 %** |
| 🥈 KNN optimisé                        |     97,37 % |     96,00 % | **100,00 %** |     97,96 % |     99,44 % |
| 🥉 SVM optimisé                        |     97,37 % |     97,26 % |      98,61 % |     97,93 % |     99,27 % |
| Random Forest optimisé                 |     95,61 % |     95,89 % |      97,22 % |     96,55 % |     99,24 % |
| Arbre de décision optimisé             |     91,23 % |     95,59 % |      90,28 % |     92,86 % |     96,56 % |

### Analyse

La **régression logistique optimisée** obtient les meilleures performances globales dans cette expérimentation.

Elle présente notamment :

* la meilleure Accuracy ;
* le meilleur F1-score ;
* la meilleure ROC-AUC test ;
* un rappel élevé ;
* une bonne stabilité entre validation croisée et test.

Le KNN présente néanmoins un rappel de **100 %**, ce qui constitue une caractéristique intéressante lorsque la priorité est de limiter les faux négatifs.

Le SVM obtient également d'excellentes performances, mais reste légèrement inférieur à la régression logistique sur les principales métriques.

---

# 10. Courbe ROC

La courbe ROC permet d'évaluer la capacité du modèle à distinguer les deux classes pour différents seuils de décision.

La régression logistique optimisée obtient une **ROC-AUC de 99,54 %** sur le jeu de test.

---

# 11. Interprétation du modèle

La régression logistique présente l'avantage supplémentaire d'être relativement interprétable grâce à ses coefficients.

L'analyse des coefficients du modèle final montre notamment l'importance de plusieurs caractéristiques morphologiques.

Parmi les coefficients les plus importants figurent notamment :

* `worst texture`
* `radius error`
* `worst concave points`
* `worst area`
* `mean compactness`
* `compactness error`

Cependant, plusieurs variables présentent une forte multicolinéarité.

Les coefficients doivent donc être interprétés comme des contributions conditionnelles au modèle et non comme des mesures indépendantes d'importance biologique.

---

# 12. Sélection du modèle final

À l'issue de la comparaison, le modèle retenu est :

**Pipeline de standardisation + régression logistique optimisée**

### Configuration

```text
StandardScaler()
        ↓
LogisticRegression(
    C=1,
    max_iter=1000,
    random_state=42
)
```

Le pipeline complet a été sauvegardé avec Joblib.

---

# 13. Sauvegarde du modèle

Le modèle final est enregistré dans :

```text
modele_logistique_final.pkl
```

Le fichier contient le pipeline complet, incluant :

* la standardisation ;
* la régression logistique ;
* les paramètres du modèle.

Une vérification du modèle sauvegardé a également été réalisée.

Après rechargement du fichier, les prédictions obtenues sont identiques à celles du modèle original.

Cela confirme que l'artefact sauvegardé est réutilisable pour effectuer des prédictions.

---

# 14. Application Streamlit

Le modèle final a été intégré dans une application Streamlit.

L'application permet de :

1. charger automatiquement le modèle ;
2. sélectionner une observation du dataset ;
3. afficher les 30 caractéristiques ;
4. effectuer une prédiction ;
5. afficher la classe prédite ;
6. afficher les probabilités associées aux deux classes ;
7. afficher la confiance du modèle ;
8. comparer la classe prédite à la classe réelle.

### Parcours utilisateur

**Sélection d'une observation → Affichage des caractéristiques → Prédiction → Probabilités → Validation**

> ⚠️ L'application est destinée à la démonstration du modèle de Machine Learning. Elle ne constitue pas un outil de diagnostic médical.

---

# 15. Structure du projet

```text
02_breast_cancer/
│
├── app.py
├── breast_cancer.ipynb
├── modele_logistique_final.pkl
├── requirements.txt
├── .gitignore
└── README.md
```

---

# 16. Technologies utilisées

| Domaine                  | Technologies                                   |
| ------------------------ | ---------------------------------------------- |
| Langage                  | Python                                         |
| Manipulation des données | Pandas, NumPy                                  |
| Visualisation            | Matplotlib, Seaborn                            |
| Machine Learning         | Scikit-learn                                   |
| Modèle final             | Régression logistique                          |
| Optimisation             | GridSearchCV                                   |
| Prétraitement            | StandardScaler                                 |
| Évaluation               | Accuracy, Precision, Recall, F1-score, ROC-AUC |
| Sauvegarde               | Joblib                                         |
| Application              | Streamlit                                      |
| Environnement            | Jupyter Notebook, VS Code                      |

---

# 17. Installation et utilisation

## 1. Cloner le dépôt

```bash
git clone https://github.com/fbomisso/fabrice.bomisso.git
```

## 2. Accéder au projet

```bash
cd fabrice.bomisso/Machine-Learning/I_Apprentissage_supervise/B_Classification/02_breast_cancer
```

## 3. Créer un environnement virtuel

```bash
python -m venv env
```

## 4. Activer l'environnement sous Windows

```powershell
env\Scripts\activate
```

## 5. Installer les dépendances

```powershell
pip install -r requirements.txt
```

## 6. Lancer l'application

```powershell
python -m streamlit run app.py
```

L'application sera accessible localement à :

```text
http://localhost:8501
```

---

# 18. Limites du projet

### Dataset de démonstration

Le modèle est entraîné sur le dataset Breast Cancer Wisconsin disponible dans `scikit-learn`.

Il s'agit d'un dataset destiné à l'apprentissage et à l'évaluation des méthodes de Machine Learning.

Il ne constitue pas une base de données clinique destinée à une utilisation médicale réelle.

### Taille du dataset

Le dataset contient seulement **569 observations**.

Les performances obtenues doivent donc être interprétées dans le contexte de ce jeu de données.

### Généralisation

Une excellente performance sur le jeu de test ne garantit pas automatiquement une performance équivalente sur de nouvelles données provenant d'un autre contexte.

Une validation externe sur des données indépendantes serait nécessaire avant toute utilisation réelle.

### Interprétation des coefficients

La multicolinéarité entre certaines variables limite l'interprétation directe des coefficients individuels de la régression logistique.

### Application Streamlit

L'application actuelle permet de tester le modèle sur les observations disponibles dans le dataset.

Elle constitue une démonstration technique et non une application clinique.

---

# 19. Perspectives d'amélioration

Plusieurs évolutions pourraient être envisagées :

* intégrer une interface permettant la saisie manuelle des 30 caractéristiques ;
* ajouter une visualisation plus détaillée des probabilités ;
* intégrer une courbe ROC interactive ;
* afficher une matrice de confusion directement dans l'application ;
* ajouter une analyse de l'importance des variables ;
* intégrer une méthode d'explicabilité comme SHAP ;
* tester le modèle sur un jeu de données externe ;
* mettre en place une validation externe ;
* ajouter une surveillance des performances après déploiement ;
* conteneuriser l'application avec Docker ;
* déployer l'application sur une infrastructure cloud.

---

# 20. Résultats clés

| Indicateur            |                            Résultat |
| --------------------- | ----------------------------------: |
| Observations          |                             **569** |
| Variables             |                              **30** |
| Jeu d'entraînement    |                             **455** |
| Jeu de test           |                             **114** |
| Meilleur modèle       | **Régression logistique optimisée** |
| Meilleur `C`          |                               **1** |
| Accuracy test         |                         **98,25 %** |
| Précision test        |                         **98,61 %** |
| Rappel test           |                         **98,61 %** |
| F1-score test         |                         **98,61 %** |
| ROC-AUC test          |                         **99,54 %** |
| ROC-AUC CV            |                         **99,59 %** |
| Prédictions correctes |                       **112 / 114** |
| Erreurs               |                               **2** |

---

# 21. Conclusion

Ce projet a permis de mettre en œuvre une démarche complète de **classification supervisée** appliquée à la distinction entre tumeurs Malignant et Benign.

Plusieurs algorithmes ont été étudiés et comparés avant de sélectionner la **régression logistique optimisée**.

Le modèle final, basé sur un pipeline combinant `StandardScaler` et `LogisticRegression`, obtient une Accuracy de **98,25 %**, un F1-score de **98,61 %** et une ROC-AUC de **99,54 %** sur le jeu de test.

La validation croisée confirme la stabilité du modèle avec une ROC-AUC moyenne de **99,59 %**.

L'intégration du modèle dans Streamlit permet enfin de transformer le résultat de l'expérimentation en une application interactive capable de réaliser des prédictions sur les observations du dataset.

Le projet illustre ainsi un parcours complet :

**Exploration → Préparation → Standardisation → Modélisation → Optimisation → Évaluation → Sélection → Sauvegarde → Application**

---

## 👨‍💻 Auteur

**Fabrice BOMISSO**

Projet personnel de Data Science orienté **Machine Learning, Data Analytics et aide à la décision**.

---

## 📄 Licence

Ce projet est distribué sous licence MIT.
