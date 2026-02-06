# Demo Setup Guide
## Healthcare Clinical Decision Support & Financial Loan Decision System

**Purpose**: Complete setup instructions for running RAI demos  
**Estimated Setup Time**: 30-45 minutes  
**Last Updated**: January 23, 2026

---

## Prerequisites

### Required Software
- **Python 3.10+**: https://www.python.org/downloads/
- **Azure CLI**: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
- **Azure Subscription**: With appropriate permissions to create resources
- **Git**: For cloning repositories
- **Jupyter**: `pip install jupyter` or use VS Code with Jupyter extension

### Azure Resources Required

#### Demo 1: Healthcare Clinical Decision Support
- Azure OpenAI Service (GPT-4 deployment)
- Azure AI Search
- Azure AI Language (for Content Safety)
- Azure AI Studio (for Responsible AI Dashboard)

#### Demo 2: Financial Loan Decision System
- Azure Machine Learning workspace
- Azure Storage Account
- Compute instance for training

---

## Directory Structure

```
ResponsibleAI/
├── demos/
│   ├── 01-healthcare/
│   │   ├── setup/
│   │   │   ├── requirements.txt
│   │   │   ├── azure-setup.sh
│   │   │   └── config.json
│   │   ├── data/
│   │   │   ├── generate_patient_data.py
│   │   │   └── sample_data/
│   │   ├── notebooks/
│   │   │   └── healthcare-rai-demo.ipynb
│   │   └── README.md
│   │
│   ├── 02-financial/
│   │   ├── setup/
│   │   │   ├── requirements.txt
│   │   │   ├── azure-setup.sh
│   │   │   └── config.json
│   │   ├── data/
│   │   │   ├── generate_loan_data.py
│   │   │   └── sample_data/
│   │   ├── notebooks/
│   │   │   └── loan-fairness-demo.ipynb
│   │   └── README.md
│   │
│   └── shared/
│       ├── rai_utils.py
│       └── visualization_utils.py
```

---

## Quick Start

### Step 1: Clone and Navigate
```bash
cd c:\Users\lesalgad\Github\lgarcias09\ResponsibleAI
```

### Step 2: Set Up Python Environment
```bash
# Create virtual environment
python -m venv rai-demos-env

# Activate (Windows PowerShell)
.\rai-demos-env\Scripts\Activate.ps1

# Activate (Windows CMD)
.\rai-demos-env\Scripts\activate.bat
```

### Step 3: Install Dependencies
```bash
# For Healthcare Demo
pip install -r demos/01-healthcare/setup/requirements.txt

# For Financial Demo
pip install -r demos/02-financial/setup/requirements.txt
```

### Step 4: Configure Azure
```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Run setup scripts (creates Azure resources)
cd demos/01-healthcare/setup
.\azure-setup.sh

cd ../../02-financial/setup
.\azure-setup.sh
```

### Step 5: Generate Synthetic Data
```bash
# Healthcare data
cd ../demos/01-healthcare/data
python generate_patient_data.py

# Financial data
cd ../../02-financial/data
python generate_loan_data.py
```

### Step 6: Update Configuration
Edit `config.json` files with your Azure resource details:
- OpenAI endpoints and keys
- Search service endpoints
- Storage account connections

### Step 7: Launch Jupyter Notebooks
```bash
# From ResponsibleAI root
jupyter notebook demos/01-healthcare/notebooks/healthcare-rai-demo.ipynb
```

---

## Azure Resource Costs (Estimated)

| Resource | Demo | Monthly Cost (Dev/Test) |
|----------|------|------------------------|
| Azure OpenAI (GPT-4) | Healthcare | $50-150 |
| Azure AI Search (Basic) | Healthcare | $75 |
| Azure AI Language | Healthcare | $0-50 (pay-as-you-go) |
| Azure ML Workspace | Financial | $0 (workspace itself) |
| Compute Instance (Standard_DS3_v2) | Financial | $150-200 (8hrs/day) |

**Total Estimated**: $275-475/month for both demos running part-time

**Cost Optimization**:
- Stop compute instances when not in use
- Use free tier for AI services where available
- Delete resources after demo sessions

---

## Troubleshooting

### Issue: Azure OpenAI quota exceeded
**Solution**: Request quota increase via Azure Portal or use existing deployment

### Issue: Python package conflicts
**Solution**: Use fresh virtual environment; verify Python version 3.10+

### Issue: Azure authentication errors
**Solution**: Run `az login` again; check subscription access permissions

### Issue: Data generation takes too long
**Solution**: Reduce sample size in generate_*.py scripts (default: 10,000 records)

---

## Next Steps

1. ✅ Complete setup (this guide)
2. ✅ Generate synthetic data
3. ✅ Run notebooks cell-by-cell to verify
4. 📹 Record demo videos (see video recording tips below)
5. 🎯 Schedule stakeholder demo sessions

---

## Video Recording Tips

### Recording Setup
- **Tool**: OBS Studio (free) or Camtasia
- **Resolution**: 1920x1080 (1080p)
- **Format**: MP4, H.264 codec
- **Audio**: Clear microphone; test levels before recording

### Demo Flow
1. **Intro (2 min)**: Problem statement, use case, architecture overview
2. **Setup Context (3 min)**: Show data, explain RAI requirements
3. **Live Demo (15-20 min)**: Execute notebook cells with narration
4. **RAI Highlights (5 min)**: Emphasize fairness, transparency, accountability
5. **Takeaways (2 min)**: Key lessons, next steps, resources

### Recording Best Practices
- Script key talking points (don't read verbatim)
- Zoom in on important code/visualizations
- Pause between sections for easy editing
- Record in segments (easier to fix mistakes)
- Keep videos under 30 minutes (attention span)

---

## Support & Resources

### Documentation
- Microsoft Responsible AI: https://www.microsoft.com/en-us/ai/responsible-ai
- Fairlearn Docs: https://fairlearn.org/
- AIF360 Guide: https://aif360.res.ibm.com/

### Internal Support
- RAI Architecture Program Office Hours: [Add Teams link]
- Teams Channel: [Add channel]
- GitHub Issues: [Add repo link]

### External Resources
- Azure OpenAI: https://learn.microsoft.com/en-us/azure/ai-services/openai/
- Azure ML: https://learn.microsoft.com/en-us/azure/machine-learning/

---

**Questions?** Contact the RAI Architecture Program team or join office hours.
