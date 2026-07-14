[CmdletBinding()]
param(
    [string]$RepositoryRoot,
    [string]$PackagePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    $RepositoryRoot = (Resolve-Path (Join-Path $scriptRoot "..")).Path
}

function Get-VersionCore([string]$Value) {
    $candidate = $Value.Trim()
    if ($candidate.StartsWith("v", [System.StringComparison]::OrdinalIgnoreCase)) {
        $candidate = $candidate.Substring(1)
    }

    $core = ($candidate -split '[-+ ]', 2)[0]
    $parsed = $null
    if (-not [Version]::TryParse($core, [ref]$parsed)) {
        throw "Invalid version '$Value'."
    }

    return $candidate
}

function Get-ManifestFromPackage([string]$ArchivePath) {
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $archive = [System.IO.Compression.ZipFile]::OpenRead($ArchivePath)
    try {
        $entry = $archive.Entries | Where-Object { $_.FullName -eq "plugin.json" } | Select-Object -First 1
        if ($null -eq $entry) {
            throw "Plugin package '$ArchivePath' does not contain plugin.json."
        }

        $stream = $entry.Open()
        $reader = [System.IO.StreamReader]::new($stream, [System.Text.UTF8Encoding]::UTF8, $true)
        try {
            return $reader.ReadToEnd() | ConvertFrom-Json
        }
        finally {
            $reader.Dispose()
            $stream.Dispose()
        }
    }
    finally {
        $archive.Dispose()
    }
}

$csprojPath = Join-Path $RepositoryRoot "LanMountainDesktop.SamplePlugin.csproj"
$manifestPath = Join-Path $RepositoryRoot "plugin.json"

$csprojContent = [System.IO.File]::ReadAllText($csprojPath)
$csprojMatch = [System.Text.RegularExpressions.Regex]::Match(
    $csprojContent,
    "<Version>(?<version>.*?)</Version>",
    [System.Text.RegularExpressions.RegexOptions]::Singleline)
if (-not $csprojMatch.Success) {
    throw "Missing <Version> in '$csprojPath'."
}

if ($csprojContent -notmatch '<PackageReference\s+Include="LanMountainDesktop\.PluginSdk"\s+Version="5\.0\.0"') {
    throw "Sample plugin must reference LanMountainDesktop.PluginSdk 5.0.0."
}

if ($csprojContent -match 'LanMountainDesktop\.AirAppSdk') {
    throw "Production Plugin SDK projects must not reference LanMountainDesktop.AirAppSdk."
}

if ($csprojContent -notmatch '<RestorePackagesPath>\$\(MSBuildProjectDirectory\)\\\.nuget\\packages</RestorePackagesPath>') {
    throw "RestorePackagesPath must isolate packages under the repository .nuget/packages directory."
}

$csprojVersion = Get-VersionCore $csprojMatch.Groups["version"].Value
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$manifestVersion = Get-VersionCore $manifest.version
$manifestApiVersion = Get-VersionCore $manifest.apiVersion

if ($csprojVersion -ne $manifestVersion) {
    throw "Version mismatch. csproj=$csprojVersion plugin.json=$manifestVersion"
}

if ($manifestApiVersion -ne "5.0.0") {
    throw "API version mismatch. Expected plugin.json apiVersion=5.0.0, actual=$manifestApiVersion"
}

if ($manifest.id -ne "LanMountainDesktop.SamplePlugin") {
    throw "Plugin id mismatch. Expected LanMountainDesktop.SamplePlugin, actual=$($manifest.id)"
}

if ($manifest.entranceAssembly -ne "LanMountainDesktop.SamplePlugin.dll") {
    throw "Entrance assembly mismatch. Expected LanMountainDesktop.SamplePlugin.dll, actual=$($manifest.entranceAssembly)"
}

if ($manifest.runtime.mode -ne "in-proc") {
    throw "Runtime mode mismatch. Expected in-proc, actual=$($manifest.runtime.mode)"
}

$expectedAssetName = "$($manifest.id).$csprojVersion.laapp"

if ($PackagePath) {
    $resolvedPackagePath = Resolve-Path $PackagePath -ErrorAction Stop
    if ([System.IO.Path]::GetFileName($resolvedPackagePath) -ne $expectedAssetName) {
        throw "Package name mismatch. Expected '$expectedAssetName', actual '$([System.IO.Path]::GetFileName($resolvedPackagePath))'."
    }


    $packageManifest = Get-ManifestFromPackage -ArchivePath $resolvedPackagePath
    if ($packageManifest.id -ne $manifest.id -or
        $packageManifest.version -ne $manifest.version -or
        $packageManifest.apiVersion -ne $manifest.apiVersion -or
        $packageManifest.entranceAssembly -ne $manifest.entranceAssembly -or
        $packageManifest.runtime.mode -ne $manifest.runtime.mode) {
        throw "Package manifest does not match repository plugin.json."
    }
}

Write-Host "Plugin version: $csprojVersion"
Write-Host "Plugin API version: $manifestApiVersion"
Write-Host "Expected asset: $expectedAssetName"
