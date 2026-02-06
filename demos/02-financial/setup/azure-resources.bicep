// ==============================================================================
// Azure Resources for Financial Loan Fairness Demo
// ==============================================================================
// This Bicep template deploys the Azure infrastructure needed for the
// Financial Services Loan Decision Fairness RAI demo.
//
// Resources Deployed:
// - Azure Machine Learning Workspace (for model training & monitoring)
// - Azure Machine Learning Compute (for Fairlearn/AIF360 training)
// - Application Insights (for ML model monitoring)
// - Storage Account (for model artifacts, datasets, audit logs)
// - Key Vault (for secure credential management)
// - Container Registry (for custom ML environments)
// - Log Analytics Workspace (for compliance monitoring)
//
// Estimated Monthly Cost: ~$125-225 (assuming moderate compute usage)
// ==============================================================================

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Base name for all resources (will be suffixed)')
param baseName string = 'financial-rai'

@description('Environment (dev, test, prod)')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

@description('Your Azure AD object ID (for Key Vault access)')
param adminObjectId string

@description('Compute instance VM size')
@allowed([
  'Standard_DS3_v2'
  'Standard_DS4_v2'
  'Standard_D4s_v3'
])
param computeVmSize string = 'Standard_DS3_v2'

// ==============================================================================
// Variables
// ==============================================================================

var uniqueSuffix = uniqueString(resourceGroup().id)
var mlWorkspaceName = '${baseName}-mlw-${uniqueSuffix}'
var storageName = replace('${baseName}${uniqueSuffix}', '-', '')
var keyVaultName = '${baseName}-kv-${uniqueSuffix}'
var appInsightsName = '${baseName}-appi-${uniqueSuffix}'
var containerRegistryName = replace('${baseName}${uniqueSuffix}', '-', '')
var logAnalyticsName = '${baseName}-logs-${uniqueSuffix}'
var computeInstanceName = '${baseName}-compute'
var computeClusterName = '${baseName}-cluster'

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
    Demo: 'Financial'
  }
}

// ==============================================================================
// Application Insights (for ML model monitoring)
// ==============================================================================

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  tags: {
    Environment: environment
    Purpose: 'ML-Monitoring'
    Demo: 'Financial'
  }
}

// ==============================================================================
// Storage Account (for ML artifacts, datasets, audit logs)
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
    Purpose: 'ML-Artifacts-Audit'
    Demo: 'Financial'
  }
}

// Create blob containers
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storage
  name: 'default'
}

resource datasetsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: 'datasets'
  properties: {
    publicAccess: 'None'
  }
}

resource modelsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: 'models'
  properties: {
    publicAccess: 'None'
  }
}

resource fairnessReportsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: 'fairness-reports'
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
// Key Vault (for secure credential management)
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
    Demo: 'Financial'
  }
}

// Store storage connection string
resource storageKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'storage-connection-string'
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${storage.listKeys().keys[0].value};EndpointSuffix=${az.environment().suffixes.storage}'
  }
}

// ==============================================================================
// Container Registry (for custom ML environments)
// ==============================================================================

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
  }
  tags: {
    Environment: environment
    Purpose: 'ML-Environments'
    Demo: 'Financial'
  }
}

// ==============================================================================
// Azure Machine Learning Workspace
// ==============================================================================

resource mlWorkspace 'Microsoft.MachineLearningServices/workspaces@2023-10-01' = {
  name: mlWorkspaceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    friendlyName: 'Financial RAI ML Workspace'
    description: 'Azure ML workspace for loan fairness model training and monitoring'
    storageAccount: storage.id
    keyVault: keyVault.id
    applicationInsights: appInsights.id
    containerRegistry: containerRegistry.id
    publicNetworkAccess: 'Enabled'
    v1LegacyMode: false
  }
  tags: {
    Environment: environment
    Purpose: 'ML-Training-Monitoring'
    Demo: 'Financial'
  }
}

// Grant workspace managed identity access to Key Vault
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-02-01' = {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: mlWorkspace.identity.principalId
        permissions: {
          secrets: ['get', 'list']
          certificates: ['get', 'list']
        }
      }
    ]
  }
}

// Enable diagnostics for ML workspace
resource mlWorkspaceDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'mlworkspace-diagnostics'
  scope: mlWorkspace
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
// Compute Instance (for interactive development)
// ==============================================================================

resource computeInstance 'Microsoft.MachineLearningServices/workspaces/computes@2023-10-01' = {
  parent: mlWorkspace
  name: computeInstanceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    computeType: 'ComputeInstance'
    properties: {
      vmSize: computeVmSize
      applicationSharingPolicy: 'Personal'
      computeInstanceAuthorizationType: 'personal'
      sshSettings: {
        sshPublicAccess: 'Disabled'
      }
      schedules: {
        computeStartStop: [
          {
            action: 'Stop'
            triggerType: 'Cron'
            cron: {
              startTime: '2024-01-01T17:00:00'
              timeZone: 'UTC'
              expression: '0 17 * * 1-5' // Stop at 5 PM on weekdays
            }
            status: 'Enabled'
          }
        ]
      }
    }
  }
}

// ==============================================================================
// Compute Cluster (for batch training jobs)
// ==============================================================================

resource computeCluster 'Microsoft.MachineLearningServices/workspaces/computes@2023-10-01' = {
  parent: mlWorkspace
  name: computeClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    computeType: 'AmlCompute'
    properties: {
      vmSize: computeVmSize
      vmPriority: 'LowPriority' // Use Low Priority for cost savings
      scaleSettings: {
        minNodeCount: 0
        maxNodeCount: 4
        nodeIdleTimeBeforeScaleDown: 'PT300S' // 5 minutes
      }
      remoteLoginPortPublicAccess: 'Disabled'
    }
  }
}

// ==============================================================================
// Outputs
// ==============================================================================

output resourceGroupName string = resourceGroup().name
output location string = location

output mlWorkspaceName string = mlWorkspace.name
output mlWorkspaceId string = mlWorkspace.id

output computeInstanceName string = computeInstance.name
output computeClusterName string = computeCluster.name

output storageAccountName string = storage.name
output datasetsContainerName string = datasetsContainer.name
output modelsContainerName string = modelsContainer.name
output fairnessReportsContainerName string = fairnessReportsContainer.name
output auditLogsContainerName string = auditLogsContainer.name

output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri

output containerRegistryName string = containerRegistry.name
output containerRegistryLoginServer string = containerRegistry.properties.loginServer

output appInsightsName string = appInsights.name
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsConnectionString string = appInsights.properties.ConnectionString

output logAnalyticsWorkspaceId string = logAnalytics.id

// ==============================================================================
// Next Steps:
// 1. Deploy: az deployment group create --resource-group <rg-name> --template-file azure-resources.bicep --parameters adminObjectId=<your-object-id>
// 2. Configure ML workspace: az ml workspace show --name <workspace-name> --resource-group <rg-name>
// 3. Upload datasets: az storage blob upload --account-name <storage-name> --container-name datasets --file loan_applications.csv
// 4. Run training pipeline with Fairlearn/AIF360 in Azure ML
// 5. Enable Model Data Collector for fairness monitoring
// ==============================================================================
