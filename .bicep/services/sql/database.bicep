@description('SQL Server name')
param sqlServerName string

@description('Database name')
param databaseName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Database SKU name - S1 (Standard) or S2 (Standard)')
@allowed(['S1', 'S2'])
param sqlDatabaseTier string = 'S1'

// Reference to existing SQL Server
resource sqlServer 'Microsoft.Sql/servers@2024-11-01-preview' existing = {
  name: sqlServerName
}

// S1 Standard Tier Database - Cost-effective for Umbraco
resource database 'Microsoft.Sql/servers/databases@2024-11-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: sqlDatabaseTier
    tier: 'Standard'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 21474836480 // 20 GB
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
  }
}

// Outputs
@description('The resource ID of the database')
output databaseId string = database.id

@description('The name of the database')
output databaseName string = database.name

@description('The connection string for the database')
output connectionString string = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${databaseName};Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'