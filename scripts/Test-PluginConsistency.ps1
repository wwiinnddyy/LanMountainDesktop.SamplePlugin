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
$manifestPath = Join-Path $RepositoryRoot "airapp.json"

$csprojContent = [System.IO.File]::ReadAllText($csprojPath)
$csprojMatch = [System.Text.RegularExpressions.Regex]::Match(
    $csprojContent,
    "<Version>(?<version>.*?)</Version>",
    [System.Text.RegularExpressions.RegexOptions]::Singleline)
if (-not $csprojMatch.Success) {
    throw "Missing <Version> in '$csprojPath'."
}

if ($csprojContent -match 'LanMountainDesktop\.PluginSdk') {
    throw "AirApps must not reference the retired LanMountainDesktop.PluginSdk."
}

# 包目录隔离有两条合法写法：csproj 的 RestorePackagesPath，或 NuGet.config 的 globalPackagesFolder。
# 只认前者是 PluginSdk 时代的口径；本仓迁到 AirApp SDK 时换成了后者，这条判据从此一直红着，
# 直到六家 CI 第一次跑到这一步才暴露（此前它们都停在还原层）。
$nugetConfigPath = Join-Path $RepositoryRoot "NuGet.config"
$nugetConfigContent = if (Test-Path $nugetConfigPath) { [System.IO.File]::ReadAllText($nugetConfigPath) } else { "" }
$isolatedInCsproj = $csprojContent.Contains("<RestorePackagesPath>")
$isolatedInNuGetConfig = $nugetConfigContent.Contains('key="globalPackagesFolder"') -and $nugetConfigContent.Contains(".nuget/packages")
if (-not ($isolatedInCsproj -or $isolatedInNuGetConfig)) {
    throw "Packages must stay inside the repository: set RestorePackagesPath in the csproj or globalPackagesFolder in NuGet.config."
}

$csprojVersion = Get-VersionCore $csprojMatch.Groups["version"].Value
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$manifestVersion = Get-VersionCore $manifest.version
$manifestApiVersion = Get-VersionCore $manifest.apiVersion

if ($csprojVersion -ne $manifestVersion) {
    throw "Version mismatch. csproj=$csprojVersion airapp.json=$manifestVersion"
}

$sdkReference = [System.Text.RegularExpressions.Regex]::Match(
    $csprojContent,
    '<PackageReference\s+Include="LanMountainDesktop\.AirAppSdk"\s+Version="(?<v>[^"]+)"')
if (-not $sdkReference.Success) {
    throw "csproj must reference LanMountainDesktop.AirAppSdk."
}

# airapp.json 的 apiVersion 是"这个轻应用绑哪条 SDK 线"的唯一声明，csproj 必须引用同一条。
# 钉字面量的写法每次抬版本线都会变成假红灯（1.0.1 那次三家 CI 全撞在这上面）。
if ((Get-VersionCore $sdkReference.Groups["v"].Value) -ne $manifestApiVersion) {
    throw "SDK line mismatch. csproj AirAppSdk=$($sdkReference.Groups['v'].Value) airapp.json apiVersion=$($manifest.apiVersion)"
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
