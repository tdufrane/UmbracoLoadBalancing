@description('Specify the SQL Server name')
@minLength(1)
@maxLength(63)
param sqlServerName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Allowed IP addresses for SQL Server access (CIDR format)')
param allowedIpAddresses array = []

@description('SQL Server administrator username')
param sqlAdminUsername string

@description('SQL Server administrator password')
@secure()
param sqlAdminPassword string

@description('Virtual Network resource ID for SQL Server integration')
param vnetId string = ''

@description('Subnet name within the VNet for SQL Server integration')
param webSubnetName string = ''

@description('Container App Subnet name within the VNet for SQL Server integration')
param containerAppSubnetName string = ''

// SQL Server Resource - SQL Authentication
resource sqlServer 'Microsoft.Sql/servers@2024-11-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
    minimalTlsVersion: '1.2'
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
    administrators: null
  }
}

// Firewall rules for allowed IP addresses only
resource sqlServerFirewallRules 'Microsoft.Sql/servers/firewallRules@2024-11-01-preview' = [for (ip, index) in allowedIpAddresses: {
  name: 'AllowedIP-${index}'
  parent: sqlServer
  properties: {
    startIpAddress: contains(ip, '/') ? split(ip, '/')[0] : ip
    endIpAddress: contains(ip, '/') ? split(ip, '/')[0] : ip
  }
}]

// Virtual Network Rule for SQL Server - App Services Subnet
resource sqlServerVnetRule 'Microsoft.Sql/servers/virtualNetworkRules@2024-11-01-preview' = if (!empty(vnetId) && !empty(webSubnetName)) {
  parent: sqlServer
  name: 'vnet-rule-${webSubnetName}'
  properties: {
    ignoreMissingVnetServiceEndpoint: false
    virtualNetworkSubnetId: '${vnetId}/subnets/${webSubnetName}'
  }
}

// Virtual Network Rule for SQL Server - Container App Subnet
resource sqlServerVnetRuleContainerApp 'Microsoft.Sql/servers/virtualNetworkRules@2024-11-01-preview' = if (!empty(vnetId) && !empty(containerAppSubnetName)) {
  parent: sqlServer
  name: 'vnet-rule-${containerAppSubnetName}'
  properties: {
    ignoreMissingVnetServiceEndpoint: false
    virtualNetworkSubnetId: '${vnetId}/subnets/${containerAppSubnetName}'
  }
}

// Outputs
@description('The resource ID of the SQL Server')
output sqlServerId string = sqlServer.id

@description('The name of the SQL Server')
output sqlServerName string = sqlServer.name

@description('The FQDN of the SQL Server')
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName

@description('The location of the SQL Server')
output location string = sqlServer.location

@description('The resource group name of the SQL Server')
output resourceGroupName string = resourceGroup().name
