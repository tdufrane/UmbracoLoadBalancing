@description('Specify the Managed Identity name')
param managedIdentityName string

@description('Location for all resources')
param location string = resourceGroup().location

// User-Assigned Managed Identity Resource
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: managedIdentityName
  location: location
}

// Outputs
@description('The resource ID of the Managed Identity')
output managedIdentityId string = managedIdentity.id

@description('The name of the Managed Identity')
output managedIdentityName string = managedIdentity.name

@description('The principal ID of the Managed Identity')
output principalId string = managedIdentity.properties.principalId

@description('The client ID of the Managed Identity')
output clientId string = managedIdentity.properties.clientId

@description('The tenant ID of the Managed Identity')
output tenantId string = managedIdentity.properties.tenantId

@description('The location of the Managed Identity')
output location string = managedIdentity.location

@description('The resource group name of the Managed Identity')
output resourceGroupName string = resourceGroup().name
