// Azure Bicep template for Customer Service Chatbot Safety Demo
// Deploys: Azure OpenAI, Azure AI Content Safety
// Region: East US (adjust as needed)

@description('Base name for all resources')
param baseName string = 'chatbot-safety-demo'

@description('Location for all resources')
param location string = 'eastus'

@description('OpenAI SKU (Standard or Premium)')
@allowed([
  'S0'
])
param openAiSku string = 'S0'

@description('Content Safety SKU')
@allowed([
  'S0'
])
param contentSafetySku string = 'S0'

@description('GPT model to deploy')
@allowed([
  'gpt-4'
  'gpt-4-32k'
  'gpt-35-turbo'
  'gpt-35-turbo-16k'
])
param gptModel string = 'gpt-4'

@description('GPT model version')
param gptModelVersion string = '0613'

@description('Deployment capacity (tokens per minute / 1000)')
param deploymentCapacity int = 10

// Variables
var uniqueSuffix = uniqueString(resourceGroup().id)
var openAiName = '${baseName}-openai-${uniqueSuffix}'
var contentSafetyName = '${baseName}-safety-${uniqueSuffix}'
var gptDeploymentName = 'gpt-4'

// Azure OpenAI Resource
resource openAi 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: openAiName
  location: location
  kind: 'OpenAI'
  sku: {
    name: openAiSku
  }
  properties: {
    customSubDomainName: openAiName
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// GPT Deployment
resource gptDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAi
  name: gptDeploymentName
  properties: {
    model: {
      format: 'OpenAI'
      name: gptModel
      version: gptModelVersion
    }
  }
  sku: {
    name: 'Standard'
    capacity: deploymentCapacity
  }
}

// Azure AI Content Safety Resource
resource contentSafety 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: contentSafetyName
  location: location
  kind: 'ContentSafety'
  sku: {
    name: contentSafetySku
  }
  properties: {
    customSubDomainName: contentSafetyName
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// Outputs for easy configuration
output openAiEndpoint string = openAi.properties.endpoint
output openAiKey string = openAi.listKeys().key1
output openAiDeploymentName string = gptDeploymentName
output contentSafetyEndpoint string = contentSafety.properties.endpoint
output contentSafetyKey string = contentSafety.listKeys().key1

output configurationInstructions string = '''
Copy the following values to your .env file:

AZURE_OPENAI_ENDPOINT=${openAi.properties.endpoint}
AZURE_OPENAI_API_KEY=${openAi.listKeys().key1}
AZURE_OPENAI_DEPLOYMENT_NAME=${gptDeploymentName}
AZURE_OPENAI_API_VERSION=2024-02-15-preview

CONTENT_SAFETY_ENDPOINT=${contentSafety.properties.endpoint}
CONTENT_SAFETY_KEY=${contentSafety.listKeys().key1}
'''
