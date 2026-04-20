//User defined Parameters
@minLength(5)
@maxLength(19)
param yourname string = 'defaultName'

param redisTier string
param webAppServicePlanTier string

param allowedIpAddresses array

@description('Location for all resources')
param location string = resourceGroup().location

// VNET

module vnet 'services/vnet/vnet.bicep' = {
  name: 'vnet'
  params: {
    vnetName: 'vnet-${toLower(yourname)}'
    location: location
  }
}

// Managed Identity

module managedIdentity 'services/managed-identity/managed-identity.bicep' = {
  name: 'managedIdentity'
  params: {
    managedIdentityName: 'mi-${toLower(yourname)}'
    location: location
  }
}

// Azure SQL

@description('SQL Server administrator password')
@secure()
param sqlAdminPassword string
param sqlServerName string = 'sql-${toLower(yourname)}-server'
param sqlAdminUsername string = '${yourname}sqladmin'
param databaseNameUmbraco string =  'UmbracoLoadBalancingTraining'
param sqlDatabaseTier string 


module sqlServer 'services/sql/sql-server.bicep' = {
  name: 'sqlServer'
  params: {
    location: location
    sqlServerName: sqlServerName
    allowedIpAddresses: allowedIpAddresses
    vnetId: vnet.outputs.vnetId
    webSubnetName: vnet.outputs.appServicesSubnet.name
    containerAppSubnetName: vnet.outputs.containerAppSubnet.name
    sqlAdminUsername: sqlAdminUsername
    sqlAdminPassword: sqlAdminPassword
  }
}

module sqlDatabase 'services/sql/database.bicep' = {
  name: 'sqlDatabase'
  params: {
    location: location
    sqlServerName: sqlServer.outputs.sqlServerName
    databaseName: databaseNameUmbraco
    sqlDatabaseTier: sqlDatabaseTier
  }
}

// Azure Storage Account

param storageAccountSkuName string = 'Standard_RAGRS'
param storageBlobName string = 'umbracoazure-training'

module storageAccount 'services/storage/storage-account.bicep' = {
  name: 'storageAccount'
  params: {
    location: location
    storageAccountName: 'stg${toLower(yourname)}lb'
    allowedIpAddresses: allowedIpAddresses
    webAppSubnetID: vnet.outputs.appServicesSubnet.id
    containerAppSubnetID: vnet.outputs.containerAppSubnet.id
    managedIdentityId: managedIdentity.outputs.managedIdentityId
    storageAccountSkuName: storageAccountSkuName
    storageBlobName: storageBlobName
    managedIdentityPrincipalId: managedIdentity.outputs.principalId
  }
}