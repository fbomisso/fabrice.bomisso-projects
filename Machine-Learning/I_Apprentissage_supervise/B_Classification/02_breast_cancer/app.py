import streamlit as st
import joblib
import pandas as pd
from sklearn.datasets import load_breast_cancer

st.set_page_config(
    page_title="Classification des tumeurs du sein",
    page_icon="🧬",
    layout="wide"
)

# Chargement du modèle
modele = joblib.load("modele_logistique_final.pkl")

# Chargement du dataset
data = load_breast_cancer()

# Noms des variables
variables = [
    "mean radius",
    "mean texture",
    "mean perimeter",
    "mean area",
    "mean smoothness",
    "mean compactness",
    "mean concavity",
    "mean concave points",
    "mean symmetry",
    "mean fractal dimension",
    "radius error",
    "texture error",
    "perimeter error",
    "area error",
    "smoothness error",
    "compactness error",
    "concavity error",
    "concave points error",
    "symmetry error",
    "fractal dimension error",
    "worst radius",
    "worst texture",
    "worst perimeter",
    "worst area",
    "worst smoothness",
    "worst compactness",
    "worst concavity",
    "worst concave points",
    "worst symmetry",
    "worst fractal dimension"
]

# Vérification de la compatibilité du modèle
if not hasattr(modele, "n_features_in_"):
    st.error("Le modèle ne possède pas l'attribut n_features_in_.")
    st.stop()

if modele.n_features_in_ != len(variables):
    st.error(
        f"Le modèle attend {modele.n_features_in_} variables, "
        f"mais l'application en fournit {len(variables)}."
    )
    st.stop()

if hasattr(modele, "feature_names_in_"):
    if list(modele.feature_names_in_) != variables:
        st.error(
            "Les noms ou l'ordre des variables du modèle "
            "ne correspondent pas à ceux de l'application."
        )
        st.stop()

# Titre
st.title("🧬 Classification des tumeurs du sein")

st.write(
    "Cette application utilise une régression logistique optimisée "
    "pour classer une observation comme Malignant ou Benign."
)

st.info(
    "⚠️ Cette application est destinée à la démonstration du modèle "
    "de Machine Learning et ne constitue pas un outil de diagnostic médical."
)

# Sélection de l'observation
st.subheader("🧪 Test avec une observation du dataset")

st.write(
    "Sélectionnez une observation réelle du dataset "
    "pour tester le modèle final."
)

index = st.number_input(
    "Index de l'observation",
    min_value=0,
    max_value=len(data.data) - 1,
    value=0,
    step=1
)

index = int(index)

# Création de l'observation
observation = pd.DataFrame(
    [data.data[index]],
    columns=variables
)

# Affichage des caractéristiques
st.subheader("📋 Caractéristiques de l'observation")

col1, col2 = st.columns(2)

for i, variable in enumerate(variables):

    if i < 15:
        with col1:
            st.number_input(
                variable,
                value=float(observation.iloc[0, i]),
                format="%.6f",
                disabled=True,
                key=f"feature_{i}"
            )
    else:
        with col2:
            st.number_input(
                variable,
                value=float(observation.iloc[0, i]),
                format="%.6f",
                disabled=True,
                key=f"feature_{i}"
            )

# Initialisation du résultat
if "resultat" not in st.session_state:
    st.session_state.resultat = None

# Bouton de prédiction
if st.button(
    "🔍 Effectuer la prédiction",
    type="primary",
    use_container_width=True
):

    classe_reelle = int(data.target[index])

    prediction = int(
        modele.predict(observation)[0]
    )

    probabilites = modele.predict_proba(observation)[0]

    probabilites_par_classe = dict(
        zip(modele.classes_, probabilites)
    )

    probabilite_malignant = float(
        probabilites_par_classe.get(0, 0.0)
    )

    probabilite_benign = float(
        probabilites_par_classe.get(1, 0.0)
    )

    st.session_state.resultat = {
        "index": index,
        "classe_reelle": classe_reelle,
        "prediction": prediction,
        "probabilite_malignant": probabilite_malignant,
        "probabilite_benign": probabilite_benign
    }

# Affichage du résultat
if st.session_state.resultat is not None:

    resultat = st.session_state.resultat

    classe_reelle = resultat["classe_reelle"]
    prediction = resultat["prediction"]
    probabilite_malignant = resultat["probabilite_malignant"]
    probabilite_benign = resultat["probabilite_benign"]

    st.subheader("🎯 Résultat de la prédiction")

    if prediction == 0:
        st.error("🔴 Classe prédite : Malignant")
    else:
        st.success("🟢 Classe prédite : Benign")

    # Probabilités
    st.subheader("📊 Probabilités")

    col1, col2 = st.columns(2)

    with col1:
        st.metric(
            "Probabilité Malignant",
            f"{probabilite_malignant:.2%}"
        )

    with col2:
        st.metric(
            "Probabilité Benign",
            f"{probabilite_benign:.2%}"
        )

    # Confiance
    st.subheader("📈 Confiance du modèle")

    probabilite_classe_predite = max(
        probabilite_malignant,
        probabilite_benign
    )

    st.progress(
        probabilite_classe_predite
    )

    st.write(
        f"Probabilité de la classe prédite : "
        f"**{probabilite_classe_predite:.2%}**"
    )

    # Validation
    st.subheader("🔎 Validation de la prédiction")

    col1, col2 = st.columns(2)

    with col1:
        st.write("**Classe réelle**")

        if classe_reelle == 0:
            st.error("🔴 Malignant")
        else:
            st.success("🟢 Benign")

    with col2:
        st.write("**Classe prédite**")

        if prediction == 0:
            st.error("🔴 Malignant")
        else:
            st.success("🟢 Benign")

    # Comparaison
    if prediction == classe_reelle:
        st.success(
            "✅ La prédiction est correcte."
        )
    else:
        st.error(
            "❌ La prédiction est incorrecte."
        )

    # Récapitulatif
    st.subheader("📋 Récapitulatif")

    recapitulatif = pd.DataFrame(
        {
            "Classe": [
                "Malignant",
                "Benign"
            ],
            "Probabilité": [
                f"{probabilite_malignant:.2%}",
                f"{probabilite_benign:.2%}"
            ]
        }
    )

    st.table(recapitulatif)