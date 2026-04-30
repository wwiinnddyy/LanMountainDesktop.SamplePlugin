[CmdletBinding()]
param(
    [string]$FeedPath,
    [string]$CoreContractsProjectPath,
    [string]$PluginSdkProjectPath,
    [string]$SharedContractProjectPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($FeedPath)) {
    $scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    $FeedPath = Join-Path (Resolve-Path (Join-Path $scriptRoot "..")).Path "packages"
}

if ([string]::IsNullOrWhiteSpace($PluginSdkProjectPath)) {
    $PluginSdkProjectPath = (Resolve-Path "..\LanMountainDesktop\LanMountainDesktop.PluginSdk\LanMountainDesktop.PluginSdk.csproj").Path
}

if ([string]::IsNullOrWhiteSpace($CoreContractsProjectPath)) {
    $CoreContractsProjectPath = (Resolve-Path "..\LanMountainDesktop\LanMountainDesktop.Shared.Contracts\LanMountainDesktop.Shared.Contracts.csproj").Path
}

function Pack-Project([string]$ProjectPath, [string]$OutputDirectory) {
    if (-not (Test-Path $ProjectPath)) {
        throw "Project '$ProjectPath' was not found."
    }

    dotnet pack $ProjectPath -c Release -o $OutputDirectory -p:ContinuousIntegrationBuild=true | Out-Host
}

New-Item -ItemType Directory -Force -Path $FeedPath | Out-Null
Pack-Project -ProjectPath $CoreContractsProjectPath -OutputDirectory $FeedPath
Pack-Project -ProjectPath $PluginSdkProjectPath -OutputDirectory $FeedPath

# SharedContractProjectPath is optional - only pack if provided and exists
if (-not [string]::IsNullOrWhiteSpace($SharedContractProjectPath)) {
    if (Test-Path $SharedContractProjectPath) {
        Pack-Project -ProjectPath $SharedContractProjectPath -OutputDirectory $FeedPath
    } else {
        Write-Host "Shared contract project not found at '$SharedContractProjectPath', skipping."
    }
}

Write-Host "Local package feed initialized at '$FeedPath'."
