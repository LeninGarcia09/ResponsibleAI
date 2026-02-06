# 🏦 Financial Services — Loan Decision Fairness Demo

[![Fairlearn](https://img.shields.io/badge/Fairlearn-Microsoft-blue)](https://fairlearn.org/)
[![SHAP](https://img.shields.io/badge/SHAP-Explainability-green)](https://shap.readthedocs.io/)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11%2B-blue)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](../../LICENSE)

## 📋 Overview

An end-to-end demonstration of **bias detection, mitigation, and explainability** in AI-powered loan approval systems using Microsoft's Responsible AI tools.

This demo uses a synthetic dataset of **10,000 loan applications** with intentionally injected bias (gender and age penalties) to show how Microsoft Fairlearn can detect and correct unfair lending patterns — and how SHAP can generate transparent adverse action notices required by the **Equal Credit Opportunity Act (ECOA)**.

## 🎯 What You'll Learn

| Section | Topic | Description |
|---------|-------|-------------|
| 1 | **Data Exploration** | Explore demographics, financial profiles, and compare fair vs. biased model outcomes |
| 2 | **Bias Detection** | Calculate disparate impact ratios and identify 80% rule violations |
| 3 | **GridSearch Mitigation** | Apply Fairlearn GridSearch with Demographic Parity constraint |
| 4 | **Equalized Odds** | Apply ExponentiatedGradient with Equalized Odds constraint |
| 5 | **Scorecard** | Compare all models on fairness and accuracy metrics |
| 6 | **SHAP Explainability** | Generate adverse action notices with feature-level explanations |
| 7 | **Monitoring Dashboard** | Build a production fairness monitoring dashboard |

## ⚖️ RAI Principles Demonstrated

| Principle | Implementation | Tools |
|-----------|---------------|-------|
| **Fairness** | Disparate impact detection, 80% rule compliance, constrained optimization | Fairlearn |
| **Transparency** | SHAP explanations for every denial, adverse action notices | SHAP, InterpretML |
| **Accountability** | Audit logs, fairness monitoring, trend tracking | Plotly dashboards |
| **Reliability** | Accuracy maintained while improving fairness | scikit-learn |
| **Privacy** | 100% synthetic data, no real PII | Faker |

## 🚀 Quick Start

### 1. Set up the environment

```bash
# From the repo root
cd demos/02-financial

# Create virtual environment (or use the shared rai-demos-env)
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r setup/requirements.txt
```

### 2. Generate synthetic data

```bash
cd data
python generate_loan_data.py --num_applications 10000 --output_dir ./sample_data
cd ..
```

### 3. Run the notebook

```bash
cd notebooks
jupyter notebook loan-fairness-demo.ipynb
```

Or open directly in **VS Code** with the Jupyter extension.

## 📁 Project Structure

```
02-financial/
├── README.md                          ← You are here
├── data/
│   ├── generate_loan_data.py          # Synthetic data generator
│   └── sample_data/
│       └── loan_applications.csv      # 10,000 synthetic applications
├── notebooks/
│   └── loan-fairness-demo.ipynb       # Main demo notebook
└── setup/
    ├── requirements.txt               # Python dependencies
    └── azure-resources.bicep          # Azure infrastructure (optional)
```

## 🔧 Key Technologies

- **[Microsoft Fairlearn](https://fairlearn.org/)** — GridSearch, ExponentiatedGradient, MetricFrame
- **[SHAP](https://shap.readthedocs.io/)** — LinearExplainer for model transparency
- **[scikit-learn](https://scikit-learn.org/)** — LogisticRegression, StandardScaler, train/test split
- **[Plotly](https://plotly.com/python/)** — Interactive visualizations and dashboards
- **[Faker](https://faker.readthedocs.io/)** — Synthetic data generation

## 📊 Key Results

The demo shows how Fairlearn transforms a biased model into a fair one:

| Model | Disparate Impact | Passes 80% Rule | Accuracy |
|-------|-----------------|------------------|----------|
| Biased Baseline | ~0.76 | ❌ FAIL | N/A |
| Fairlearn GridSearch | ~0.98 | ✅ PASS | ~87% |
| Fairlearn Equalized Odds | ~0.97 | ✅ PASS | ~86% |

> *Results are approximate and depend on random seed. Run the notebook to see exact values.*

## 📚 References

- [Microsoft Responsible AI](https://www.microsoft.com/en-us/ai/responsible-ai)
- [Fairlearn Documentation](https://fairlearn.org/)
- [SHAP Documentation](https://shap.readthedocs.io/)
- [InterpretML](https://interpret.ml/)
- [ECOA — Consumer Financial Protection Bureau](https://www.consumerfinance.gov/compliance/supervision-examinations/equal-credit-opportunity-act/)
- [Azure ML Responsible AI](https://learn.microsoft.com/en-us/azure/machine-learning/concept-responsible-ai)

## ⚠️ Disclaimer

This demo uses **100% synthetic data** generated with Faker. No real personal information is used. The biased model is intentionally constructed for educational purposes to demonstrate bias detection and mitigation techniques. This is not production-ready without additional security hardening, compliance review, and legal validation.

---

**Part of the [Responsible AI Demos Portfolio](../../README.md)** | Made with ❤️ by Microsoft
