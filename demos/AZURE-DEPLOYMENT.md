# Azure Deployment Guide for RAI Demos

## Overview

This guide walks through deploying Azure infrastructure for the Healthcare and Financial RAI demos using Infrastructure as Code (Bicep templates).

## What Gets Deployed

### Healthcare Demo Resources

| Resource | Purpose | Estimated Cost/Month |
|----------|---------|---------------------|
| Azure OpenAI (GPT-4) | Clinical reasoning with RAG | $100-150 |
| Azure AI Search | Medical knowledge base indexing | $30-50 |
| Azure AI Language | PII detection for HIPAA compliance | $20-30 |
| Azure AI Content Safety | Harmful content filtering | $10-20 |
| Storage Account | Medical documents and audit logs | $5-10 |
| Key Vault | Secure API key management | $2-5 |
| Log Analytics | Monitoring and compliance | $5-10 |
| **Total** | | **~$175-275/month** |

### Financial Demo Resources

| Resource | Purpose | Estimated Cost/Month |
|----------|---------|---------------------|
| Azure ML Workspace | Model training and monitoring | $0 (base) |
| Compute Instance (DS3v2) | Interactive development | $60-80 (8hrs/day) |
| Compute Cluster (Low Priority) | Batch training jobs | $20-40 (minimal usage) |
| Application Insights | Model monitoring | $10-20 |
| Storage Account | Model artifacts and datasets | $10-20 |
| Container Registry | Custom ML environments | $5-10 |
| Key Vault | Secure credential management | $2-5 |
| Log Analytics | Monitoring and compliance | $5-10 |
| **Total** | | **~$112-185/month** |

### Combined Total Estimate
**~$287-460/month** for both demos running simultaneously

## Prerequisites

### Required Software
- **Azure CLI** (v2.50+): https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
  ```powershell
  # Windows (PowerShell)
  winget install Microsoft.AzureCLI
  
  # Verify installation
  az --version
  ```

- **Azure Subscription** with Contributor role
  - Sign up for free: https://azure.microsoft.com/en-us/free/
  - $200 credit for 30 days (enough to run these demos)

### Required Permissions
- **Subscription Contributor** role (to create resource groups and resources)
- **Azure AD User** with access to query object ID (for Key Vault access policies)

## Deployment Options

### Option 1: Automated Deployment (Recommended)

Use the PowerShell deployment script that handles everything:

```powershell
# Navigate to deployment scripts
cd demos/shared

# Deploy Healthcare demo only
.\deploy-azure.ps1 -Demo "Healthcare" -Environment "dev"

# Deploy Financial demo only
.\deploy-azure.ps1 -Demo "Financial" -Environment "dev"

# Deploy both demos
.\deploy-azure.ps1 -Demo "Both" -Environment "dev"

# Deploy to specific subscription
.\deploy-azure.ps1 -Demo "Both" -Environment "dev" -SubscriptionId "your-sub-id"

# Deploy to different region
.\deploy-azure.ps1 -Demo "Healthcare" -Environment "dev" -Location "westus2"
```

**What the script does:**
1. ✅ Verifies Azure CLI installation and login
2. ✅ Creates resource groups with proper tags
3. ✅ Deploys Bicep templates
4. ✅ Retrieves API keys from Key Vault
5. ✅ Generates `.env` configuration files
6. ✅ Provides cleanup commands

**Estimated time**: 10-15 minutes per demo

### Option 2: Manual Deployment

If you prefer manual control:

#### Step 1: Login to Azure
```powershell
az login
az account set --subscription "<your-subscription-name-or-id>"
```

#### Step 2: Get Your Azure AD Object ID
```powershell
$objectId = az ad signed-in-user show --query id -o tsv
Write-Host "Your Object ID: $objectId"
```

#### Step 3: Deploy Healthcare Demo
```powershell
# Create resource group
az group create `
  --name "rg-healthcare-rai-dev" `
  --location "eastus" `
  --tags "Environment=dev" "Demo=Healthcare" "Purpose=RAI-Demo"

# Deploy Bicep template
az deployment group create `
  --name "healthcare-deployment" `
  --resource-group "rg-healthcare-rai-dev" `
  --template-file "demos/01-healthcare/setup/azure-resources.bicep" `
  --parameters environment=dev adminObjectId=$objectId
```

#### Step 4: Deploy Financial Demo
```powershell
# Create resource group
az group create `
  --name "rg-financial-rai-dev" `
  --location "eastus" `
  --tags "Environment=dev" "Demo=Financial" "Purpose=RAI-Demo"

# Deploy Bicep template
az deployment group create `
  --name "financial-deployment" `
  --resource-group "rg-financial-rai-dev" `
  --template-file "demos/02-financial/setup/azure-resources.bicep" `
  --parameters environment=dev adminObjectId=$objectId
```

#### Step 5: Retrieve Configuration

```powershell
# Get Key Vault name
$kvName = az deployment group show `
  --name "healthcare-deployment" `
  --resource-group "rg-healthcare-rai-dev" `
  --query properties.outputs.keyVaultName.value -o tsv

# Retrieve API keys
az keyvault secret show --vault-name $kvName --name "openai-api-key" --query value -o tsv
az keyvault secret show --vault-name $kvName --name "search-api-key" --query value -o tsv
```

## Post-Deployment Configuration

### 1. Verify Deployment

```powershell
# List all resources in Healthcare demo
az resource list --resource-group "rg-healthcare-rai-dev" --output table

# List all resources in Financial demo
az resource list --resource-group "rg-financial-rai-dev" --output table
```

### 2. Update Jupyter Notebooks

Both demos will have `.env` files created automatically (if using the automated script).

**Healthcare demo** (`.../demos/01-healthcare/.env`):
```bash
OPENAI_ENDPOINT=https://healthcare-rai-openai-xxxxx.openai.azure.com/
OPENAI_API_KEY=xxxxx
OPENAI_DEPLOYMENT_NAME=gpt-4
SEARCH_ENDPOINT=https://healthcare-rai-search-xxxxx.search.windows.net
SEARCH_API_KEY=xxxxx
# ... (other keys)
```

**Financial demo** (`.../demos/02-financial/.env`):
```bash
ML_WORKSPACE_NAME=financial-rai-mlw-xxxxx
STORAGE_ACCOUNT_NAME=financialraixxxxx
# ... (other config)
```

### 3. Test Azure Integration

#### Healthcare Demo - Test RAG with Azure OpenAI

Create a new cell in [healthcare-rai-demo.ipynb](../../demos/01-healthcare/notebooks/healthcare-rai-demo.ipynb):

```python
from azure.identity import DefaultAzureCredential
from azure.ai.openai import AzureOpenAI
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Initialize Azure OpenAI client
client = AzureOpenAI(
    api_key=os.getenv("OPENAI_API_KEY"),
    api_version="2024-02-01",
    azure_endpoint=os.getenv("OPENAI_ENDPOINT")
)

# Test GPT-4 deployment
response = client.chat.completions.create(
    model=os.getenv("OPENAI_DEPLOYMENT_NAME"),
    messages=[
        {"role": "system", "content": "You are a helpful medical AI assistant."},
        {"role": "user", "content": "What are the key symptoms of acute coronary syndrome?"}
    ]
)

print("✓ Azure OpenAI connection successful!")
print(f"Response: {response.choices[0].message.content}")
```

#### Financial Demo - Test Azure ML Connection

Create a new cell in [loan-fairness-demo.ipynb](../../demos/02-financial/notebooks/loan-fairness-demo.ipynb):

```python
from azure.ai.ml import MLClient
from azure.identity import DefaultAzureCredential
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Initialize Azure ML client
ml_client = MLClient(
    credential=DefaultAzureCredential(),
    subscription_id=os.getenv("AZURE_SUBSCRIPTION_ID"),
    resource_group_name=os.getenv("AZURE_RESOURCE_GROUP"),
    workspace_name=os.getenv("ML_WORKSPACE_NAME")
)

# List compute instances
computes = ml_client.compute.list()
print("✓ Azure ML connection successful!")
print(f"Available computes: {[c.name for c in computes]}")
```

## Cost Management

### Monitor Costs

1. **Azure Portal**: https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/overview
2. **Set up budget alerts**:
   ```powershell
   # Set budget alert at $100/month
   az consumption budget create `
     --amount 100 `
     --budget-name "rai-demos-budget" `
     --category Cost `
     --time-grain Monthly `
     --time-period-start-date "2026-01-01" `
     --time-period-end-date "2026-12-31" `
     --resource-group "rg-healthcare-rai-dev"
   ```

### Cost-Saving Tips

1. **Stop Compute Instances** when not in use:
   ```powershell
   az ml compute stop --name <compute-instance-name> `
     --resource-group <rg-name> --workspace-name <workspace-name>
   ```

2. **Use Low Priority VMs** for batch training (already configured in Bicep)

3. **Delete resources** when demos are complete:
   ```powershell
   # Delete Healthcare demo resources
   az group delete --name "rg-healthcare-rai-dev" --yes --no-wait

   # Delete Financial demo resources
   az group delete --name "rg-financial-rai-dev" --yes --no-wait
   ```

4. **Scheduled Auto-Shutdown**: Compute instances are configured to stop at 5 PM on weekdays automatically

## Troubleshooting

### Issue: Deployment Fails with "Quota Exceeded"

**Solution**: Request quota increase for Azure OpenAI or ML compute
```powershell
# Check current quotas
az vm list-usage --location eastus --output table

# Request quota increase via Azure Portal:
# https://portal.azure.com/#view/Microsoft_Azure_Support/HelpAndSupportBlade/~/overview
```

### Issue: "Unauthorized" when accessing Key Vault

**Solution**: Verify your object ID has access
```powershell
# Get your object ID
$objectId = az ad signed-in-user show --query id -o tsv

# Add access policy
az keyvault set-policy `
  --name <key-vault-name> `
  --object-id $objectId `
  --secret-permissions get list
```

### Issue: Azure OpenAI GPT-4 deployment fails

**Cause**: GPT-4 requires申请 access in some regions

**Solution**:
1. Apply for GPT-4 access: https://aka.ms/oai/access
2. Or use GPT-3.5-Turbo as alternative (edit Bicep file):
   ```bicep
   name: 'gpt-35-turbo'
   version: '0613'
   ```

### Issue: Compute Instance stuck in "Creating" state

**Solution**: Check compute quotas and regional availability
```powershell
# List available VM sizes in region
az vm list-sizes --location eastus --output table

# Try different region or VM size
az deployment group create ... --parameters computeVmSize=Standard_DS2_v2
```

## Security Best Practices

### 1. Use Managed Identities (Recommended)

Instead of storing API keys in `.env`, use Azure Managed Identity:

```python
from azure.identity import DefaultAzureCredential

# This automatically uses managed identity when running in Azure
credential = DefaultAzureCredential()
```

### 2. Enable Private Endpoints (Production)

For production deployments, enable private endpoints to restrict network access:

```bicep
// Add to Bicep template
properties: {
  publicNetworkAccess: 'Disabled'
  privateEndpointConnections: [...]
}
```

### 3. Rotate API Keys Regularly

```powershell
# Regenerate OpenAI key
az cognitiveservices account keys regenerate `
  --name <openai-account-name> `
  --resource-group <rg-name> `
  --key-name key1
```

### 4. Enable Audit Logging

All resources are configured with diagnostic settings sending logs to Log Analytics.

Query audit logs:
```kusto
// In Log Analytics workspace
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.COGNITIVESERVICES"
| where OperationName == "ChatCompletions"
| project TimeGenerated, OperationName, CallerIpAddress, ResultSignature
| order by TimeGenerated desc
```

## Next Steps

After successful deployment:

1. ✅ **Test Azure connectivity** using the notebook cells above
2. ✅ **Upload medical documents** to Azure AI Search (Healthcare demo)
3. ✅ **Train fairness-aware model** in Azure ML (Financial demo)
4. ✅ **Set up Model Monitoring** for continuous fairness tracking
5. ✅ **Create Power BI dashboards** for stakeholder reporting
6. ✅ **Present demos** to leadership using Jupyter notebooks with live Azure data

## Additional Resources

- **Azure OpenAI Service**: https://learn.microsoft.com/en-us/azure/ai-services/openai/
- **Azure Machine Learning**: https://learn.microsoft.com/en-us/azure/machine-learning/
- **Responsible AI Dashboard**: https://learn.microsoft.com/en-us/azure/machine-learning/concept-responsible-ai-dashboard
- **Azure Bicep Documentation**: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/
- **Azure Cost Management**: https://learn.microsoft.com/en-us/azure/cost-management-billing/

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review Azure service health: https://status.azure.com/
3. Contact Azure support: https://azure.microsoft.com/en-us/support/

---

**Estimated Total Setup Time**: 30-45 minutes for both demos  
**Estimated Monthly Cost**: $287-460 (or $0 with Azure free trial credits)
