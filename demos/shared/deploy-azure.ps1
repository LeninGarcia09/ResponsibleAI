# ==============================================================================
# Azure Deployment Script for RAI Demos
# ==============================================================================
# This PowerShell script automates the deployment of Azure resources for both
# Healthcare and Financial RAI demos using Bicep templates.
#
# Prerequisites:
# - Azure CLI installed: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
# - Azure subscription with contributor access
# - Logged in to Azure CLI: az login
#
# Usage:
#   .\deploy-azure.ps1 -Demo "Healthcare" -Environment "dev"
#   .\deploy-azure.ps1 -Demo "Financial" -Environment "dev"
#   .\deploy-azure.ps1 -Demo "Both" -Environment "dev"
# ==============================================================================

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Healthcare", "Financial", "Both")]
    [string]$Demo,

    [Parameter(Mandatory=$false)]
    [ValidateSet("dev", "test", "prod")]
    [string]$Environment = "dev",

    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus",

    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId
)

# ==============================================================================
# Functions
# ==============================================================================

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "=" * 80 -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "=" * 80 -ForegroundColor Cyan
}

function Write-Step {
    param([string]$Message)
    Write-Host "▶ $Message" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Deploy-Demo {
    param(
        [string]$DemoName,
        [string]$ResourceGroupName,
        [string]$BicepFile
    )

    Write-Header "Deploying $DemoName Demo"

    # Check if Bicep file exists
    if (-not (Test-Path $BicepFile)) {
        Write-Error-Custom "Bicep file not found: $BicepFile"
        return $false
    }

    # Create resource group
    Write-Step "Creating resource group: $ResourceGroupName"
    az group create `
        --name $ResourceGroupName `
        --location $Location `
        --tags "Environment=$Environment" "Demo=$DemoName" "Purpose=RAI-Demo"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Failed to create resource group"
        return $false
    }
    Write-Success "Resource group created"

    # Get current user's object ID for Key Vault access
    Write-Step "Getting current user's Azure AD object ID"
    $objectId = az ad signed-in-user show --query id -o tsv
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Failed to get user object ID"
        return $false
    }
    Write-Success "Object ID: $objectId"

    # Deploy Bicep template
    Write-Step "Deploying Azure resources (this may take 10-15 minutes)..."
    $deploymentName = "$DemoName-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    az deployment group create `
        --name $deploymentName `
        --resource-group $ResourceGroupName `
        --template-file $BicepFile `
        --parameters environment=$Environment adminObjectId=$objectId `
        --output json > deployment-output.json

    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Deployment failed"
        return $false
    }
    Write-Success "Resources deployed successfully"

    # Parse deployment outputs
    Write-Step "Retrieving deployment outputs"
    $outputs = Get-Content deployment-output.json | ConvertFrom-Json
    $outputs = $outputs.properties.outputs

    # Save outputs to .env file
    $envFile = "../../demos/$($DemoName.ToLower())/.env"
    Write-Step "Saving configuration to $envFile"
    
    $envContent = @"
# Azure Configuration for $DemoName RAI Demo
# Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# Deployment: $deploymentName

AZURE_SUBSCRIPTION_ID=$SubscriptionId
AZURE_RESOURCE_GROUP=$ResourceGroupName
AZURE_LOCATION=$Location

"@

    if ($DemoName -eq "Healthcare") {
        $envContent += @"
# Azure OpenAI
OPENAI_ENDPOINT=$($outputs.openAIEndpoint.value)
OPENAI_DEPLOYMENT_NAME=$($outputs.openAIDeploymentName.value)
OPENAI_EMBEDDING_DEPLOYMENT=$($outputs.openAIEmbeddingDeploymentName.value)

# Azure AI Search
SEARCH_ENDPOINT=$($outputs.searchEndpoint.value)
SEARCH_NAME=$($outputs.searchName.value)

# Azure AI Services
LANGUAGE_ENDPOINT=$($outputs.languageEndpoint.value)
CONTENT_SAFETY_ENDPOINT=$($outputs.contentSafetyEndpoint.value)

# Storage
STORAGE_ACCOUNT_NAME=$($outputs.storageAccountName.value)
MEDICAL_DOCS_CONTAINER=$($outputs.medicalDocsContainerName.value)
AUDIT_LOGS_CONTAINER=$($outputs.auditLogsContainerName.value)

# Key Vault
KEY_VAULT_NAME=$($outputs.keyVaultName.value)
KEY_VAULT_URI=$($outputs.keyVaultUri.value)

# Monitoring
LOG_ANALYTICS_WORKSPACE_ID=$($outputs.logAnalyticsWorkspaceId.value)
"@
    }
    elseif ($DemoName -eq "Financial") {
        $envContent += @"
# Azure Machine Learning
ML_WORKSPACE_NAME=$($outputs.mlWorkspaceName.value)
ML_WORKSPACE_ID=$($outputs.mlWorkspaceId.value)
COMPUTE_INSTANCE_NAME=$($outputs.computeInstanceName.value)
COMPUTE_CLUSTER_NAME=$($outputs.computeClusterName.value)

# Storage
STORAGE_ACCOUNT_NAME=$($outputs.storageAccountName.value)
DATASETS_CONTAINER=$($outputs.datasetsContainerName.value)
MODELS_CONTAINER=$($outputs.modelsContainerName.value)
FAIRNESS_REPORTS_CONTAINER=$($outputs.fairnessReportsContainerName.value)
AUDIT_LOGS_CONTAINER=$($outputs.auditLogsContainerName.value)

# Key Vault
KEY_VAULT_NAME=$($outputs.keyVaultName.value)
KEY_VAULT_URI=$($outputs.keyVaultUri.value)

# Container Registry
CONTAINER_REGISTRY_NAME=$($outputs.containerRegistryName.value)
CONTAINER_REGISTRY_LOGIN_SERVER=$($outputs.containerRegistryLoginServer.value)

# Application Insights
APP_INSIGHTS_NAME=$($outputs.appInsightsName.value)
APP_INSIGHTS_INSTRUMENTATION_KEY=$($outputs.appInsightsInstrumentationKey.value)
APP_INSIGHTS_CONNECTION_STRING=$($outputs.appInsightsConnectionString.value)

# Monitoring
LOG_ANALYTICS_WORKSPACE_ID=$($outputs.logAnalyticsWorkspaceId.value)
"@
    }

    $envContent | Out-File -FilePath $envFile -Encoding utf8
    Write-Success "Configuration saved to $envFile"

    # Retrieve API keys from Key Vault
    Write-Step "Retrieving API keys from Key Vault"
    $keyVaultName = $outputs.keyVaultName.value
    
    if ($DemoName -eq "Healthcare") {
        $openAIKey = az keyvault secret show --vault-name $keyVaultName --name "openai-api-key" --query value -o tsv
        $searchKey = az keyvault secret show --vault-name $keyVaultName --name "search-api-key" --query value -o tsv
        $languageKey = az keyvault secret show --vault-name $keyVaultName --name "language-api-key" --query value -o tsv
        $contentSafetyKey = az keyvault secret show --vault-name $keyVaultName --name "contentsafety-api-key" --query value -o tsv
        $storageConnStr = az keyvault secret show --vault-name $keyVaultName --name "storage-connection-string" --query value -o tsv

        Add-Content -Path $envFile -Value @"

# API Keys (retrieved from Key Vault)
OPENAI_API_KEY=$openAIKey
SEARCH_API_KEY=$searchKey
LANGUAGE_API_KEY=$languageKey
CONTENT_SAFETY_API_KEY=$contentSafetyKey
STORAGE_CONNECTION_STRING=$storageConnStr
"@
    }
    elseif ($DemoName -eq "Financial") {
        $storageConnStr = az keyvault secret show --vault-name $keyVaultName --name "storage-connection-string" --query value -o tsv

        Add-Content -Path $envFile -Value @"

# Connection Strings (retrieved from Key Vault)
STORAGE_CONNECTION_STRING=$storageConnStr
"@
    }

    Write-Success "API keys retrieved and saved"

    # Clean up deployment output file
    Remove-Item deployment-output.json -Force

    Write-Success "$DemoName deployment complete!"
    return $true
}

# ==============================================================================
# Main Script
# ==============================================================================

Write-Header "Azure RAI Demos Deployment Script"

# Check Azure CLI installation
Write-Step "Checking Azure CLI installation"
$azVersion = az version --query '\"azure-cli\"' -o tsv 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Azure CLI not found. Please install: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
}
Write-Success "Azure CLI version: $azVersion"

# Check if logged in
Write-Step "Checking Azure CLI login status"
$account = az account show 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Not logged in to Azure CLI. Please run: az login"
    exit 1
}
Write-Success "Logged in to Azure"

# Set subscription if provided
if ($SubscriptionId) {
    Write-Step "Setting active subscription to $SubscriptionId"
    az account set --subscription $SubscriptionId
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Failed to set subscription"
        exit 1
    }
}

# Get current subscription
$currentSub = az account show --query name -o tsv
$currentSubId = az account show --query id -o tsv
Write-Success "Active subscription: $currentSub ($currentSubId)"

# Deploy demos
$success = $true

if ($Demo -eq "Healthcare" -or $Demo -eq "Both") {
    $rgName = "rg-healthcare-rai-$Environment"
    $bicepFile = "../../demos/01-healthcare/setup/azure-resources.bicep"
    $success = $success -and (Deploy-Demo -DemoName "Healthcare" -ResourceGroupName $rgName -BicepFile $bicepFile)
}

if ($Demo -eq "Financial" -or $Demo -eq "Both") {
    $rgName = "rg-financial-rai-$Environment"
    $bicepFile = "../../demos/02-financial/setup/azure-resources.bicep"
    $success = $success -and (Deploy-Demo -DemoName "Financial" -ResourceGroupName $rgName -BicepFile $bicepFile)
}

# Summary
Write-Header "Deployment Summary"
if ($success) {
    Write-Success "All deployments completed successfully!"
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Review the .env files in each demo folder"
    Write-Host "2. Run the Jupyter notebooks to test Azure integration"
    Write-Host "3. Review costs in Azure Portal: https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/overview"
    Write-Host ""
    Write-Host "To delete resources later:" -ForegroundColor Yellow
    if ($Demo -eq "Healthcare" -or $Demo -eq "Both") {
        Write-Host "  az group delete --name rg-healthcare-rai-$Environment --yes --no-wait"
    }
    if ($Demo -eq "Financial" -or $Demo -eq "Both") {
        Write-Host "  az group delete --name rg-financial-rai-$Environment --yes --no-wait"
    }
} else {
    Write-Error-Custom "Some deployments failed. Please review the errors above."
    exit 1
}
