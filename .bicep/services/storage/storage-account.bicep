param storageAccountName string
param storageBlobName string

param storageAccountSkuName string

param allowedIpAddresses array = []

param location string = resourceGroup().location

param webAppSubnetID string

param containerAppSubnetID string = ''

param managedIdentityId string
param managedIdentityPrincipalId string

resource stgAccount 'Microsoft.Storage/storageAccounts@2025-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    publicNetworkAccess: 'Enabled'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
        blob: {
          enabled: true
        }
      }
    }

    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
      ipRules: [
        for ip in allowedIpAddresses: {
          // Remove CIDR suffix if /32 is specified
          value: endsWith(ip, '/32') ? split(ip, '/')[0] : ip
          action: 'Allow'
      }]
      virtualNetworkRules: concat([
        {
          action: 'Allow'
          id: webAppSubnetID
          state: 'Succeeded'
        }
      ], !empty(containerAppSubnetID) ? [
        {
          action: 'Allow'
          id: containerAppSubnetID
          state: 'Succeeded'
        }
      ] : [])
    }
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: stgAccount
  name: 'default'
}

resource blobStg 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: storageBlobName
  properties: {
    publicAccess: 'None'
  }
}

// Ensure you have Owner role to run this IAM assignment
//Assign Storage Blob Data Contributor Role to Managed Identity
//Refer to https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles for other role definition IDs
resource storageBlobDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(stgAccount.id, 'Storage Blob Data Contributor', managedIdentityPrincipalId)
  scope: stgAccount
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'ba92f5b4-2d11-453d-a403-e96b0029c9fe' // Storage Blob Data Contributor
    )
    principalId: managedIdentityPrincipalId
  }
}

output storageAccountBlobUrl string = stgAccount.properties.primaryEndpoints.blob
output storageAccountId string = stgAccount.id
output storageAccountName string = stgAccount.name
output storageBlobName string = blobStg.name