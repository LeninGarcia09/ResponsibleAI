# Deploy Azure Resources for Customer Service Chatbot Safety Demo
# This script deploys Azure OpenAI and Azure AI Content Safety using Bicep

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "rg-chatbot-safety-demo",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$false)]
    [string]$BaseName = "chatbot-safety-demo",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("gpt-4", "gpt-4-32k", "gpt-35-turbo", "gpt-35-turbo-16k")]
    [string]$GptModel = "gpt-4",
    
    [Parameter(Mandatory=$false)]
    [int]$DeploymentCapacity = 10
)

Write-Host "🚀 Azure Deployment - Customer Service Chatbot Safety Demo" -ForegroundColor Cyan
Write-Host "=" * 70

# Check if Azure CLI is installed
Write-Host "`n📋 Checking prerequisites..." -ForegroundColor Yellow
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Host "✅ Azure CLI version: $($azVersion.'azure-cli')" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI not found. Please install: https://aka.ms/install-azure-cli" -ForegroundColor Red
    exit 1
}

# Check if logged in
Write-Host "`n🔐 Checking Azure login status..." -ForegroundColor Yellow
$account = az account show 2>$null
if (-not $account) {
    Write-Host "⚠️  Not logged in to Azure. Running 'az login'..." -ForegroundColor Yellow
    az login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Login failed" -ForegroundColor Red
        exit 1
    }
}

$accountInfo = az account show | ConvertFrom-Json
Write-Host "✅ Logged in as: $($accountInfo.user.name)" -ForegroundColor Green
Write-Host "   Subscription: $($accountInfo.name)" -ForegroundColor Gray

# Create resource group
Write-Host "`n📦 Creating resource group..." -ForegroundColor Yellow
Write-Host "   Name: $ResourceGroupName" -ForegroundColor Gray
Write-Host "   Location: $Location" -ForegroundColor Gray

$rgExists = az group exists --name $ResourceGroupName
if ($rgExists -eq "true") {
    Write-Host "✅ Resource group already exists" -ForegroundColor Green
} else {
    az group create --name $ResourceGroupName --location $Location --output none
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Resource group created" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to create resource group" -ForegroundColor Red
        exit 1
    }
}

# Deploy Bicep template
Write-Host "`n🏗️  Deploying Azure resources..." -ForegroundColor Yellow
Write-Host "   This may take 3-5 minutes..." -ForegroundColor Gray
Write-Host "   - Azure OpenAI ($GptModel deployment)" -ForegroundColor Gray
Write-Host "   - Azure AI Content Safety" -ForegroundColor Gray

$bicepFile = Join-Path $PSScriptRoot "azure-resources.bicep"

$deploymentName = "chatbot-safety-$(Get-Date -Format 'yyyyMMddHHmmss')"

$deployment = az deployment group create `
    --resource-group $ResourceGroupName `
    --name $deploymentName `
    --template-file $bicepFile `
    --parameters baseName=$BaseName location=$Location gptModel=$GptModel deploymentCapacity=$DeploymentCapacity `
    --query "properties.outputs" `
    --output json | ConvertFrom-Json

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Deployment failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Deployment complete!" -ForegroundColor Green

# Extract outputs
Write-Host "`n📝 Configuration:" -ForegroundColor Cyan
Write-Host "=" * 70

$openAiEndpoint = $deployment.openAiEndpoint.value
$openAiKey = $deployment.openAiKey.value
$openAiDeployment = $deployment.openAiDeploymentName.value
$contentSafetyEndpoint = $deployment.contentSafetyEndpoint.value
$contentSafetyKey = $deployment.contentSafetyKey.value

Write-Host "`nAzure OpenAI:" -ForegroundColor Yellow
Write-Host "  Endpoint: $openAiEndpoint" -ForegroundColor Gray
Write-Host "  Deployment: $openAiDeployment" -ForegroundColor Gray
Write-Host "  Key: $($openAiKey.Substring(0, 8))..." -ForegroundColor Gray

Write-Host "`nAzure AI Content Safety:" -ForegroundColor Yellow
Write-Host "  Endpoint: $contentSafetyEndpoint" -ForegroundColor Gray
Write-Host "  Key: $($contentSafetyKey.Substring(0, 8))..." -ForegroundColor Gray

# Generate .env file
$envFilePath = Join-Path (Split-Path $PSScriptRoot -Parent) ".env"
$envContent = @"
# Azure OpenAI Configuration
AZURE_OPENAI_ENDPOINT=$openAiEndpoint
AZURE_OPENAI_API_KEY=$openAiKey
AZURE_OPENAI_DEPLOYMENT_NAME=$openAiDeployment
AZURE_OPENAI_API_VERSION=2024-02-15-preview

# Azure AI Content Safety Configuration
CONTENT_SAFETY_ENDPOINT=$contentSafetyEndpoint
CONTENT_SAFETY_KEY=$contentSafetyKey

# Optional: Azure AI Studio (for Evaluation SDK)
# AZURE_AI_PROJECT_CONNECTION_STRING=your_project_connection_string_here
"@

$envContent | Out-File -FilePath $envFilePath -Encoding UTF8 -Force

Write-Host "`n✅ Created .env file: $envFilePath" -ForegroundColor Green

# Summary
Write-Host "`n📊 Deployment Summary:" -ForegroundColor Cyan
Write-Host "=" * 70
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Gray
Write-Host "Location: $Location" -ForegroundColor Gray
Write-Host "Deployment Name: $deploymentName" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ All resources deployed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Review the generated .env file" -ForegroundColor Gray
Write-Host "2. Install Python dependencies: pip install -r setup/requirements.txt" -ForegroundColor Gray
Write-Host "3. Run the notebook: jupyter notebook notebooks/customer-service-safety-demo.ipynb" -ForegroundColor Gray
Write-Host ""
Write-Host "💰 Estimated cost (pay-as-you-go):" -ForegroundColor Cyan
Write-Host "   - Azure OpenAI: ~`$0.01 per 1K tokens (GPT-4)" -ForegroundColor Gray
Write-Host "   - Content Safety: ~`$1.00 per 1K text operations" -ForegroundColor Gray
Write-Host "   - Demo run: ~`$0.60 for complete notebook execution" -ForegroundColor Gray
Write-Host ""
Write-Host "🗑️  To delete resources: az group delete --name $ResourceGroupName --yes --no-wait" -ForegroundColor Yellow
