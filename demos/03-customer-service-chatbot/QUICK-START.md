# Quick Start Guide - Customer Service Chatbot Safety Demo

## 5-Minute Setup

### Step 1: Azure Resources (10 minutes)

#### Option A: Azure Portal
1. **Azure OpenAI** ([Create](https://portal.azure.com/#create/Microsoft.CognitiveServicesOpenAI))
   - Deploy GPT-4 or GPT-3.5-Turbo model
   - Copy: Endpoint, API Key, Deployment Name

2. **Azure AI Content Safety** ([Create](https://portal.azure.com/#create/Microsoft.CognitiveServicesContentSafety))
   - Copy: Endpoint, API Key

#### Option B: Azure CLI (faster)
```bash
# Login
az login

# Create resource group
az group create --name rg-chatbot-safety-demo --location eastus

# Create OpenAI resource
az cognitiveservices account create \
  --name openai-chatbot-demo \
  --resource-group rg-chatbot-safety-demo \
  --kind OpenAI \
  --sku S0 \
  --location eastus

# Deploy GPT-4
az cognitiveservices account deployment create \
  --name openai-chatbot-demo \
  --resource-group rg-chatbot-safety-demo \
  --deployment-name gpt-4 \
  --model-name gpt-4 \
  --model-version "0613" \
  --model-format OpenAI \
  --sku-capacity 10 \
  --sku-name "Standard"

# Create Content Safety resource
az cognitiveservices account create \
  --name contentsafety-chatbot-demo \
  --resource-group rg-chatbot-safety-demo \
  --kind ContentSafety \
  --sku S0 \
  --location eastus

# Get keys
az cognitiveservices account keys list \
  --name openai-chatbot-demo \
  --resource-group rg-chatbot-safety-demo

az cognitiveservices account keys list \
  --name contentsafety-chatbot-demo \
  --resource-group rg-chatbot-safety-demo
```

### Step 2: Local Setup (5 minutes)

```bash
# Navigate to demo directory
cd demos/03-customer-service-chatbot

# Create virtual environment
python -m venv venv

# Activate (Windows)
venv\Scripts\activate
# Activate (Mac/Linux)
source venv/bin/activate

# Install dependencies
pip install -r setup/requirements.txt

# Optional: Enhanced PII detection
python -m spacy download en_core_web_lg
```

### Step 3: Configuration (2 minutes)

```bash
# Copy template
cp setup/.env.template .env

# Edit .env with your Azure credentials
# Windows: notepad .env
# Mac/Linux: nano .env
```

Required values:
```bash
AZURE_OPENAI_ENDPOINT=https://openai-chatbot-demo.openai.azure.com/
AZURE_OPENAI_API_KEY=your_key_from_step_1
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4
CONTENT_SAFETY_ENDPOINT=https://contentsafety-chatbot-demo.cognitiveservices.azure.com/
CONTENT_SAFETY_KEY=your_key_from_step_1
```

### Step 4: Run (1 minute)

```bash
# Launch Jupyter
jupyter notebook notebooks/customer-service-safety-demo.ipynb

# Or use VS Code
code notebooks/customer-service-safety-demo.ipynb
```

### Step 5: Execute

1. **Run Setup Cells** (cells 1-5):
   - Install packages (if not already done)
   - Import libraries
   - Initialize Azure clients
   - Generate synthetic data
   - Create knowledge bases

2. **Run Baseline Tests** (cells 6-11):
   - See 6 vulnerability demonstrations
   - Understand risks without protection

3. **Run Protected Tests** (cells 12-18):
   - See same exploits with Azure safety tools
   - Compare side-by-side results

4. **Review Metrics** (cells 19-21):
   - Groundedness scores
   - Safety violation rates
   - PII anonymization stats

## Troubleshooting

### Issue: "ModuleNotFoundError"
```bash
pip install --upgrade -r setup/requirements.txt
```

### Issue: "AuthenticationError"
- Verify API keys in `.env` are correct
- Check endpoint URLs have no trailing slashes
- Ensure OpenAI deployment name matches your resource

### Issue: Content Safety Rate Limit
- Free tier: 1 request/second
- If hitting limits, add delays:
```python
import time
time.sleep(1)  # Between requests
```

### Issue: Presidio Not Detecting PII
```bash
# Install spaCy model
python -m spacy download en_core_web_lg

# Restart Jupyter kernel
# Jupyter: Kernel → Restart
```

### Issue: Import Error for Azure AI Evaluation
```bash
# Evaluation SDK is optional for this demo
# Core demo works without it
# To use: Create AI Studio project and add connection string
```

## What You'll See

### Baseline (Vulnerable) Chatbot
- ❌ Harmful content not filtered
- ❌ Jailbreak attempts succeed
- ❌ Hallucinated information
- ❌ PII stored in plaintext logs

### Protected Chatbot
- ✅ Content Safety blocks harmful inputs/outputs
- ✅ Prompt Shields detects jailbreak attempts
- ✅ Groundedness prevents hallucinations
- ✅ Presidio anonymizes PII before logging

### Metrics
- **Groundedness**: 4.2/5.0 (target: >4.0)
- **Harmful content rate**: 0.5% (target: <0.1%)
- **PII leaks**: 0 (target: 0)
- **Jailbreak success**: 0% (target: 0%)

## Next Steps

1. **Customize for your industry**:
   - Edit knowledge bases in cells 7-8
   - Add your company policies
   - Update customer data schema

2. **Add your test cases**:
   - Extend test cases in cells 10-15
   - Add industry-specific attacks
   - Test compliance requirements

3. **Integrate with your app**:
   - Extract `protected_chatbot()` function
   - Add to your API layer
   - Connect to your RAG system

4. **Production deployment**:
   - Review [README.md](README.md) production checklist
   - Set up continuous monitoring
   - Configure alerting thresholds

## Cost Estimate

### Pay-as-you-go (running this demo once):
- **Azure OpenAI**: ~$0.50 (50 requests @ GPT-4)
- **Content Safety**: ~$0.10 (100 text analyses)
- **Total**: ~$0.60 per complete run

### Monthly (production with 10K daily conversations):
- **Azure OpenAI**: ~$750/month (300K requests @ GPT-4)
- **Content Safety**: ~$300/month (600K analyses - input + output)
- **Total**: ~$1,050/month

**Savings Tip**: Use GPT-3.5-Turbo for development (5x cheaper)

## Support

- **Azure Documentation**: [aka.ms/ai-safety](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/)
- **Issues**: Submit to repository
- **Questions**: Review [README.md](README.md) FAQ section

---

**Ready to start?** Run Step 1 above to create your Azure resources!
