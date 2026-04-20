@description('Specify the Virtual Network name')
param vnetName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Address space for the Virtual Network')
param addressPrefixes array = [
  '10.0.0.0/16'
]

param webSubnetName string = 'wa-subnet'
param acaSubnetName string = 'aca-subnet'

// Virtual Network Resource

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }

    subnets: [
      {
        name: webSubnetName
        properties: {
          addressPrefix: '10.0.1.0/24'

          natGateway: null

          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.Sql'
            }
            {
              service: 'Microsoft.KeyVault'
            }
            {
              service: 'Microsoft.Web'
            }
          ]

          delegations: [
            {
              name: 'Microsoft.Web.serverFarms'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: acaSubnetName
        properties: {
          addressPrefix: '10.0.2.0/23'
          
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.Sql'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          
          delegations: [
            {
              name: 'Microsoft.App.environments'
              properties: {
                serviceName: 'Microsoft.App/environments'
              }
            }
          ]
        }
      }
    ]
  }
}



// Outputs
@description('The resource ID of the Virtual Network')
output vnetId string = virtualNetwork.id

@description('The name of the Virtual Network')
output vnetName string = virtualNetwork.name

@description('The address space of the Virtual Network')
output addressSpace array = virtualNetwork.properties.addressSpace.addressPrefixes

@description('The App Services subnet details')
output appServicesSubnet object = {
  name: virtualNetwork.properties.subnets[0].name
  id: '${virtualNetwork.id}/subnets/${virtualNetwork.properties.subnets[0].name}'
  addressPrefix: virtualNetwork.properties.subnets[0].properties.addressPrefix
}

@description('The Container App subnet details')
output containerAppSubnet object = {
  name: virtualNetwork.properties.subnets[1].name
  id: '${virtualNetwork.id}/subnets/${virtualNetwork.properties.subnets[1].name}'
  addressPrefix: virtualNetwork.properties.subnets[1].properties.addressPrefix
}

@description('The location of the Virtual Network')
output location string = virtualNetwork.location

@description('The resource group name of the Virtual Network')
output resourceGroupName string = resourceGroup().name