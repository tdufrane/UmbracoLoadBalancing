using 'main.bicep'
param yourname = 'TedDuFrane'
// Must contain a valid CIDR IP range
param allowedIpAddresses = ['107.10.75.49/32']
param sqlAdminPassword = '?aRandomPassw0rd1234!'

// Recommended Tiers
// param sqlDatabaseTier = 'S2'
// param redisTier = 'Balanced_B0'
// param webAppServicePlanTier = 'P0v3'

// Settings for Azure Trial
param sqlDatabaseTier = 'S1'
param redisTier = 'Balanced_B0'
param webAppServicePlanTier = 'B1'