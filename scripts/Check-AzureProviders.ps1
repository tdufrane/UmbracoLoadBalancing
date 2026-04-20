# Check and register Azure resource providers required by bicep files
param(
    [Parameter(Mandatory = $false)]
    [switch]$RegisterMissing
)

Write-Host "`nChecking Azure Resource Providers..." -ForegroundColor Cyan
Write-Host "====================================`n" -ForegroundColor Cyan

# List of providers used in bicep files
$requiredProviders = @(
    'Microsoft.App',                    # Container Apps
    'Microsoft.Authorization',          # Role Assignments
    'Microsoft.Cache',                  # Redis Enterprise
    'Microsoft.ContainerRegistry',      # Azure Container Registry
    'Microsoft.ContainerService',       # Kubernetes/Container Services
    'Microsoft.Insights',               # Application Insights
    'Microsoft.ManagedIdentity',        # Managed Identities
    'Microsoft.Network',                # Virtual Networks
    'Microsoft.OperationalInsights',    # Log Analytics
    'Microsoft.SignalRService',         # Azure SignalR
    'Microsoft.Sql',                    # SQL Server
    'Microsoft.Storage',                # Storage Accounts
    'Microsoft.Web'                     # App Service
)

$notRegistered = @()

foreach ($provider in $requiredProviders) {
    $state = az provider show --namespace $provider --query "registrationState" -o tsv 2>$null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [!] $provider - Not found/Error" -ForegroundColor Red
        continue
    }
    
    if ($state -eq "Registered") {
        Write-Host "  [OK] $provider - Registered" -ForegroundColor Green
    }
    elseif ($state -eq "Registering") {
        Write-Host "  [...] $provider - Registering..." -ForegroundColor Yellow
        $notRegistered += $provider
    }
    else {
        Write-Host "  [X] $provider - Not Registered ($state)" -ForegroundColor Red
        $notRegistered += $provider
    }
}

if ($notRegistered.Count -eq 0) {
    Write-Host "`nOK - All required resource providers are registered!" -ForegroundColor Green
    exit 0
}

Write-Host "`nWARNING: $($notRegistered.Count) provider(s) need registration:" -ForegroundColor Yellow
$notRegistered | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }

if ($RegisterMissing) {
    Write-Host "`nRegistering missing providers..." -ForegroundColor Cyan
    
    foreach ($provider in $notRegistered) {
        Write-Host "  Registering $provider..." -ForegroundColor Yellow
        az provider register --namespace $provider
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  OK - $provider registration initiated" -ForegroundColor Green
        }
        else {
            Write-Host "  ERROR - Failed to register $provider" -ForegroundColor Red
        }
    }
    
    Write-Host "`nNOTE: Provider registration can take several minutes." -ForegroundColor Yellow
    Write-Host "   Run this script again to check status." -ForegroundColor Yellow
}
else {
    Write-Host "`nTo register missing providers, run:" -ForegroundColor Cyan
    Write-Host "  .\scripts\Check-AzureProviders.ps1 -RegisterMissing" -ForegroundColor White
    Write-Host ""
}

exit ($notRegistered.Count)
