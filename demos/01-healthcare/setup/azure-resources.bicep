// ==============================================================================
// Azure Resources for Healthcare RAI Demo
// ==============================================================================
// This Bicep template deploys the Azure infrastructure needed for the
// Healthcare Clinical Decision Support RAI demo.
//
// Resources Deployed:
// - Azure OpenAI Service (GPT-4 for clinical reasoning)
// - Azure AI Search (for RAG - medical knowledge base)
// - Azure AI Language (PII detection for HIPAA compliance)
// - Azure AI Content Safety (harmful content filtering)
// - Storage Account (for medical documents, audit logs)
// - Key Vault (for secure API key management)
// - Log Analytics Workspace (for monitoring and compliance)
//
// Estimated Monthly Cost: ~$150-250 (assuming moderate usage)
// ==============================================================================

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Base name for all resources (will be suffixed)')
param baseName string = 'healthcare-rai'

@description('Environment (dev, test, prod)')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

@description('Your Azure AD object ID (for Key Vault access)')
param adminObjectId string

// ==============================================================================
// Variables
// ==============================================================================

var uniqueSuffix = uniqueString(resourceGroup().id)
var openAIName = '${baseName}-openai-${uniqueSuffix}'
var searchName = '${baseName}-search-${uniqueSuffix}'
var languageName = '${baseName}-language-${uniqueSuffix}'
var contentSafetyName = '${baseName}-contentsafety-${uniqueSuffix}'
var storageName = replace('${baseName}${uniqueSuffix}', '-', '')
var keyVaultName = '${baseName}-kv-${uniqueSuffix}'
var logAnalyticsName = '${baseName}-logs-${uniqueSuffix}'

// ==============================================================================
// Log Analytics Workspace (for monitoring and audit trails)
// ==============================================================================

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
  tags: {
    Environment: environment
    Purpose: 'RAI-Monitoring'
    Demo: 'Healthcare'
  }
}

// ==============================================================================
// Azure OpenAI Service (GPT-4 for clinical reasoning)
// ==============================================================================

resource openAI 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: openAIName
  location: location
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: openAIName
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
    disableLocalAuth: false
  }
  tags: {
    Environment: environment
    Purpose: 'Clinical-AI-Reasoning'
    Demo: 'Healthcare'
  }
}

// Deploy GPT-4 model
resource gpt4Deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAI
  name: 'gpt-4'
  sku: {
    name: 'Standard'
    capacity: 10 // 10K TPM
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4'
      version: '0613'
    }
    versionUpgradeOption: 'OnceCurrentVersionExpired'
    raiPolicyName: 'Microsoft.Default'
  }
}

// Deploy text-embedding-ada-002 for RAG
resource embeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAI
  name: 'text-embedding-ada-002'
  dependsOn: [gpt4Deployment]
  sku: {
    name: 'Standard'
    capacity: 5 // 5K TPM
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-ada-002'
      version: '2'
    }
    versionUpgradeOption: 'OnceCurrentVersionExpired'
  }
}

// Enable diagnostics for OpenAI
resource openAIDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'openai-diagnostics'
  scope: openAI
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// ==============================================================================
// Azure AI Search (for RAG - medical knowledge base)
// ==============================================================================

resource search 'Microsoft.Search/searchServices@2023-11-01' = {
  name: searchName
  location: location
  sku: {
    name: 'basic' // Use 'standard' for production
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
    networkRuleSet: {
      ipRules: []
    }
    encryptionWithCmk: {
      enforcement: 'Unspecified'
    }
    disableLocalAuth: false
    authOptions: {
      apiKeyOnly: {}
    }
  }
  tags: {
    Environment: environment
    Purpose: 'Medical-Knowledge-Base'
    Demo: 'Healthcare'
  }
}

// ==============================================================================
// Azure AI Language (PII detection for HIPAA compliance)
// ==============================================================================

resource language 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: languageName
  location: location
  kind: 'TextAnalytics'
  sku: {
    name: 'S' // Standard tier for PII detection
  }
  properties: {
    customSubDomainName: languageName
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
    disableLocalAuth: false
  }
  tags: {
    Environment: environment
    Purpose: 'PII-Detection-HIPAA'
    Demo: 'Healthcare'
  }
}

// Enable diagnostics for Language service
resource languageDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'language-diagnostics'
  scope: language
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// ==============================================================================
// Azure AI Content Safety (harmful content filtering)
// ==============================================================================

resource contentSafety 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: contentSafetyName
  location: location
  kind: 'ContentSafety'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: contentSafetyName
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
    disableLocalAuth: false
  }
  tags: {
    Environment: environment
    Purpose: 'Content-Filtering'
    Demo: 'Healthcare'
  }
}

// ==============================================================================
// Storage Account (for medical documents and audit logs)
// ==============================================================================

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    encryption: {
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
  tags: {
    Environment: environment
    Purpose: 'Medical-Documents-Audit'
    Demo: 'Healthcare'
  }
}

// Create blob containers
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storage
  name: 'default'
}

resource medicalDocsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: 'medical-documents'
  properties: {
    publicAccess: 'None'
  }
}

resource auditLogsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: 'audit-logs'
  properties: {
    publicAccess: 'None'
  }
}

// ==============================================================================
// Key Vault (for secure API key management)
// ==============================================================================

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: true
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: adminObjectId
        permissions: {
          keys: ['all']
          secrets: ['all']
          certificates: ['all']
        }
      }
    ]
  }
  tags: {
    Environment: environment
    Purpose: 'Secret-Management'
    Demo: 'Healthcare'
  }
}

// Store API keys in Key Vault
resource openAIKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'openai-api-key'
  properties: {
    value: openAI.listKeys().key1
  }
}

resource searchKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'search-api-key'
  properties: {
    value: search.listAdminKeys().primaryKey
  }
}

resource languageKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'language-api-key'
  properties: {
    value: language.listKeys().key1
  }
}

resource contentSafetyKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'contentsafety-api-key'
  properties: {
    value: contentSafety.listKeys().key1
  }
}

resource storageKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'storage-connection-string'
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${storage.listKeys().keys[0].value};EndpointSuffix=${az.environment().suffixes.storage}'
  }
}

// ==============================================================================
// Outputs
// ==============================================================================

output resourceGroupName string = resourceGroup().name
output location string = location

output openAIEndpoint string = openAI.properties.endpoint
output openAIDeploymentName string = gpt4Deployment.name
output openAIEmbeddingDeploymentName string = embeddingDeployment.name

output searchEndpoint string = 'https://${search.name}.search.windows.net'
output searchName string = search.name

output languageEndpoint string = language.properties.endpoint
output contentSafetyEndpoint string = contentSafety.properties.endpoint

output storageAccountName string = storage.name
output medicalDocsContainerName string = medicalDocsContainer.name
output auditLogsContainerName string = auditLogsContainer.name

output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri

output logAnalyticsWorkspaceId string = logAnalytics.id

// ==============================================================================
// Next Steps:
// 1. Deploy: az deployment group create --resource-group <rg-name> --template-file azure-resources.bicep --parameters adminObjectId=<your-object-id>
// 2. Retrieve secrets: az keyvault secret show --vault-name <kv-name> --name openai-api-key --query value -o tsv
// 3. Update .env file with endpoints and keys
// 4. Run Jupyter notebook with real Azure AI services
// ==============================================================================
