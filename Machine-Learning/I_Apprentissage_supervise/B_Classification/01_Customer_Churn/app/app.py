import streamlit as st
import pandas as pd
import numpy as np
import joblib
from pathlib import Path
import plotly.graph_objects as go


st.set_page_config(
    page_title="Churn Prediction",
    page_icon="⚠️",
    layout="wide",
    initial_sidebar_state="collapsed"
)


st.markdown("""
<style>
    .metric-card {
        background-color: #f0f2f6;
        padding: 20px;
        border-radius: 10px;
        margin: 10px 0;
    }

    .high-risk {
        background-color: #ffe5e5;
        border-left: 5px solid #d62728;
        padding: 20px;
        border-radius: 10px;
    }

    .medium-risk {
        background-color: #fff5e5;
        border-left: 5px solid #ff7f0e;
        padding: 20px;
        border-radius: 10px;
    }

    .low-risk {
        background-color: #e5f5e5;
        border-left: 5px solid #2ca02c;
        padding: 20px;
        border-radius: 10px;
    }
</style>
""", unsafe_allow_html=True)


st.title("🎯 Telco Customer Churn Prediction")
st.markdown("**Prédisez le risque de churn et identifiez les actions de rétention prioritaires**")


@st.cache_resource
def load_artifacts():
    base_path = Path(__file__).parent.parent / "models"
    model = joblib.load(base_path / "churn_model.pkl")
    preprocessor = joblib.load(base_path / "preprocessor.pkl")
    feature_names = joblib.load(base_path / "feature_names.pkl")

    # Thresholds calculés depuis le dataset d'entraînement
    thresholds = {
        "q75_monthly": 89.05,
        "q25_monthly": 20.05
    }

    return model, preprocessor, feature_names, thresholds


try:
    model, preprocessor, feature_names, thresholds = load_artifacts()
except FileNotFoundError:
    st.error("⚠️ Les fichiers du modèle n'ont pas été trouvés.")
    st.stop()


st.markdown("---")


with st.sidebar:
    st.header("📋 Profil du client")

    st.subheader("Démographie")
    gender = st.selectbox("Genre", ["Male", "Female"])
    senior_citizen = st.selectbox(
        "Senior Citizen",
        [0, 1],
        format_func=lambda x: "Oui" if x == 1 else "Non"
    )
    partner = st.selectbox(
        "Partner",
        ["Yes", "No"],
        format_func=lambda x: "Oui" if x == "Yes" else "Non"
    )
    dependents = st.selectbox(
        "Dependents",
        ["Yes", "No"],
        format_func=lambda x: "Oui" if x == "Yes" else "Non"
    )

    st.subheader("Services")
    tenure = st.slider("Ancienneté (mois)", 0, 72, 12)
    internet_service = st.selectbox(
        "Internet Service",
        ["DSL", "Fiber optic", "No"]
    )
    monthly_charges = st.number_input(
        "Charges mensuelles ($)",
        0.0,
        150.0,
        50.0
    )
    contract = st.selectbox(
        "Contract",
        ["Month-to-month", "One year", "Two year"]
    )

    st.subheader("Paiement")
    payment_method = st.selectbox(
        "Payment Method",
        [
            "Electronic check",
            "Mailed check",
            "Bank transfer (automatic)",
            "Credit card (automatic)"
        ]
    )
    paperless_billing = st.selectbox(
        "Paperless Billing",
        ["Yes", "No"],
        format_func=lambda x: "Oui" if x == "Yes" else "Non"
    )

    st.subheader("Services additionnels")
    online_security = st.selectbox(
        "Online Security",
        ["Yes", "No", "No internet service"]
    )
    tech_support = st.selectbox(
        "Tech Support",
        ["Yes", "No", "No internet service"]
    )
    online_backup = st.selectbox(
        "Online Backup",
        ["Yes", "No", "No internet service"]
    )
    device_protection = st.selectbox(
        "Device Protection",
        ["Yes", "No", "No internet service"]
    )
    streaming_tv = st.selectbox(
        "Streaming TV",
        ["Yes", "No", "No internet service"]
    )
    streaming_movies = st.selectbox(
        "Streaming Movies",
        ["Yes", "No", "No internet service"]
    )

    st.subheader("Téléphone")
    phone_service = st.selectbox(
        "Phone Service",
        ["Yes", "No"]
    )
    multiple_lines = st.selectbox(
        "Multiple Lines",
        ["Yes", "No", "No phone service"]
    )


def prepare_input(
    gender,
    senior_citizen,
    partner,
    dependents,
    tenure,
    internet_service,
    monthly_charges,
    contract,
    payment_method,
    paperless_billing,
    online_security,
    tech_support,
    online_backup,
    device_protection,
    streaming_tv,
    streaming_movies,
    phone_service,
    multiple_lines,
    thresholds
):

    partner_int = 1 if partner == "Yes" else 0
    dependents_int = 1 if dependents == "Yes" else 0
    paperless_int = 1 if paperless_billing == "Yes" else 0
    phone_int = 1 if phone_service == "Yes" else 0

    num_services = sum([
        1 if online_security == "Yes" else 0,
        1 if online_backup == "Yes" else 0,
        1 if device_protection == "Yes" else 0,
        1 if tech_support == "Yes" else 0,
        1 if streaming_tv == "Yes" else 0,
        1 if streaming_movies == "Yes" else 0
    ])

    data = pd.DataFrame({
        "gender": [gender],
        "SeniorCitizen": [senior_citizen],
        "Partner": [partner_int],
        "Dependents": [dependents_int],
        "tenure": [tenure],
        "PhoneService": [phone_int],
        "MultipleLines": [multiple_lines],
        "InternetService": [internet_service],
        "OnlineSecurity": [online_security],
        "OnlineBackup": [online_backup],
        "DeviceProtection": [device_protection],
        "TechSupport": [tech_support],
        "StreamingTV": [streaming_tv],
        "StreamingMovies": [streaming_movies],
        "Contract": [contract],
        "PaperlessBilling": [paperless_int],
        "PaymentMethod": [payment_method],
        "MonthlyCharges": [monthly_charges],
        "TotalCharges": [tenure * monthly_charges],
        "tenure_years": [tenure / 12],
        "is_new_customer": [1 if tenure <= 6 else 0],
        "is_young_customer": [1 if tenure <= 12 else 0],
        "high_monthly_charges": [
            1 if monthly_charges > thresholds["q75_monthly"] else 0
        ],
        "low_monthly_charges": [
            1 if monthly_charges < thresholds["q25_monthly"] else 0
        ],
        "num_services": [num_services],
        "has_multiple_services": [1 if num_services >= 2 else 0],
        "has_tech_support": [1 if tech_support == "Yes" else 0],
        "has_security": [1 if online_security == "Yes" else 0],
        "is_automatic_payment": [
            1 if payment_method in [
                "Bank transfer (automatic)",
                "Credit card (automatic)"
            ] else 0
        ],
        "is_long_contract": [
            1 if contract in ["One year", "Two year"] else 0
        ],
        "risky_profile": [
            1 if (tenure <= 6) and (contract == "Month-to-month") else 0
        ]
    })

    return data


col1, col2 = st.columns([3, 1])


with col2:
    if st.button(
        "🔮 PRÉDIRE",
        key="predict",
        use_container_width=True
    ):

        input_data = prepare_input(
            gender,
            senior_citizen,
            partner,
            dependents,
            tenure,
            internet_service,
            monthly_charges,
            contract,
            payment_method,
            paperless_billing,
            online_security,
            tech_support,
            online_backup,
            device_protection,
            streaming_tv,
            streaming_movies,
            phone_service,
            multiple_lines,
            thresholds
        )

        input_processed = preprocessor.transform(input_data)
        risk_score = model.predict_proba(input_processed)[0][1]

        st.session_state.risk_score = risk_score
        st.session_state.input_data = input_data


if "risk_score" in st.session_state:
    risk_score = st.session_state.risk_score

    if risk_score >= 0.70:
        risk_category = "🔴 ÉLEVÉ"
        risk_color = "#d62728"
        css_class = "high-risk"

    elif risk_score >= 0.40:
        risk_category = "🟠 MOYEN"
        risk_color = "#ff7f0e"
        css_class = "medium-risk"

    else:
        risk_category = "🟢 FAIBLE"
        risk_color = "#2ca02c"
        css_class = "low-risk"

    st.markdown("---")
    st.subheader("📊 Résultats")

    col1, col2, col3 = st.columns(3)

    with col1:
        st.metric(
            "Score de risque",
            f"{risk_score * 100:.1f}%"
        )

    with col2:
        st.metric(
            "Catégorie",
            risk_category
        )

    with col3:
        fig = go.Figure(
            go.Indicator(
                mode="gauge+number",
                value=risk_score * 100,
                domain={"x": [0, 1], "y": [0, 1]},
                gauge={
                    "axis": {"range": [0, 100]},
                    "bar": {"color": risk_color},
                    "steps": [
                        {
                            "range": [0, 40],
                            "color": "#e5f5e5"
                        },
                        {
                            "range": [40, 70],
                            "color": "#fff5e5"
                        },
                        {
                            "range": [70, 100],
                            "color": "#ffe5e5"
                        }
                    ]
                }
            )
        )

        fig.update_layout(
            height=250,
            margin=dict(l=10, r=10, t=10, b=10)
        )

        st.plotly_chart(
            fig,
            use_container_width=True
        )

    st.markdown(
        f"<div class='{css_class}'>",
        unsafe_allow_html=True
    )

    if risk_score >= 0.70:
        st.subheader(
            "⚠️ RISQUE ÉLEVÉ - Action immédiate requise"
        )

        st.markdown("""
        **Profils observés** :
        - Nouveaux clients (< 6 mois) avec contrats mensuels
        - Clients en Fiber optic (41.9% de churn)
        - Paiement par chèque électronique (45.3% de churn)
        - Sans services additionnels (41.8% de churn)

        **Actions prioritaires** :
        1. ☎️ Contact proactif client (24h)
        2. 📊 Diagnostic qualité de service
        3. 🎁 Cross-sell OnlineSecurity/TechSupport
        4. 💳 Migration vers paiement automatique
        5. 📝 Proposition de contrat 1-2 ans
        """)

    elif risk_score >= 0.40:
        st.subheader(
            "🟠 RISQUE MOYEN - Rétention progressive"
        )

        st.markdown("""
        **Actions suggérées** :
        1. 📧 Email personnalisé avec offre services
        2. 💳 Incitation vers paiement automatique
        3. 📈 Proposition d'upgrade contrat progressif
        4. 👥 Suivi satisfaction régulier
        """)

    else:
        st.subheader(
            "✅ RISQUE FAIBLE - Client loyal"
        )

        st.markdown("""
        **Actions suggérées** :
        1. 🏆 Intégration VIP Loyalty Program
        2. 🎉 Offres anniversaire fidélité
        3. 📞 Feedback régulier satisfaction
        4. 🌟 Maintien qualité service
        """)

    st.markdown(
        "</div>",
        unsafe_allow_html=True
    )

    st.markdown("---")
    st.subheader("🔍 Profil du client")

    col1, col2, col3 = st.columns(3)

    with col1:
        st.metric(
            "Ancienneté",
            f"{tenure} mois"
        )
        st.metric(
            "Contrat",
            contract
        )

    with col2:
        st.metric(
            "Charges mensuelles",
            f"${monthly_charges:.2f}"
        )
        st.metric(
            "Internet",
            internet_service
        )

    with col3:
        st.metric(
            "Paiement",
            payment_method.split("(")[0].strip()
        )

        num_services = sum([
            1 if online_security == "Yes" else 0,
            1 if online_backup == "Yes" else 0,
            1 if device_protection == "Yes" else 0,
            1 if tech_support == "Yes" else 0,
            1 if streaming_tv == "Yes" else 0,
            1 if streaming_movies == "Yes" else 0
        ])

        st.metric(
            "Services",
            f"{num_services}/6"
        )

    st.markdown("---")
    st.subheader("⚡ Facteurs clés")

    factors = []

    if tenure <= 6:
        factors.append(
            ("🔴", "Nouveau client (≤ 6 mois)")
        )

    elif tenure <= 12:
        factors.append(
            ("🟠", "Client jeune (6-12 mois)")
        )

    else:
        factors.append(
            ("🟢", "Client établi (> 12 mois)")
        )

    if contract == "Month-to-month":
        factors.append(
            ("🔴", "Contrat mensuel (risque : 42.7%)")
        )

    elif contract == "One year":
        factors.append(
            ("🟢", "Contrat 1 an (risque : 11.3%)")
        )

    else:
        factors.append(
            ("🟢", "Contrat 2 ans (risque : 2.8%)")
        )

    if payment_method == "Electronic check":
        factors.append(
            ("🔴", "Chèque électronique (risque : 45.3%)")
        )

    elif payment_method.endswith("(automatic)"):
        factors.append(
            ("🟢", "Paiement automatique (risque : 15-17%)")
        )

    if internet_service == "Fiber optic":
        factors.append(
            ("🟠", "Fibre optique (risque : 41.9%)")
        )

    elif internet_service == "DSL":
        factors.append(
            ("🟢", "DSL (risque : 19.0%)")
        )

    num_services = sum([
        1 if online_security == "Yes" else 0,
        1 if online_backup == "Yes" else 0,
        1 if device_protection == "Yes" else 0,
        1 if tech_support == "Yes" else 0,
        1 if streaming_tv == "Yes" else 0,
        1 if streaming_movies == "Yes" else 0
    ])

    if num_services == 0:
        factors.append(
            ("🔴", "Pas de services (risque : 41%+)")
        )

    elif num_services >= 2:
        factors.append(
            ("🟢", "Services additionnels (protection)")
        )

    for emoji, text in factors:
        st.write(f"{emoji} {text}")


st.markdown("---")

st.markdown("""
#### ℹ️ À propos

**Modèle** : Random Forest
- Recall : 77.8% | F1-Score : 63.7% | ROC-AUC : 0.85
- Features : 34 variables (démographie, services, contrats, charges)
- Dataset : 7,043 clients Telco Customer Churn

**Recommandations** : Basées sur les profils réels du dataset.
""")