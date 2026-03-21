[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$TemplatePath,

    [Parameter(Mandatory)]
    [string]$PackagePath,

    [Parameter(Mandatory)]
    [string]$Version,

    [Parameter(Mandatory)]
    [string]$OutputPath,

    [string]$Timestamp = [DateTimeOffset]::UtcNow.ToString("o")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Write-Utf8File([string]$Path, [string]$Content) {
    $encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function Get-RepositoryInfo([string]$RepositoryUrl) {
    $uri = [Uri]$RepositoryUrl
    if ($uri.Host -ne "github.com") {
        throw "Unsupported repository host in '$RepositoryUrl'."
    }

    $segments = $uri.AbsolutePath.Trim("/") -split "/"
    if ($segments.Length -ne 2) {
        throw "Repository URL '$RepositoryUrl' must point to the GitHub repository root."
    }

    return @{
        Owner = $segments[0]
        Name = $segments[1]
    }
}

function Get-PropertyValue($Object, [string]$Name) {
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $null
    }

    return $property.Value
}

function Get-ArrayValue($Object, [string]$Name) {
    $value = Get-PropertyValue -Object $Object -Name $Name
    if ($null -eq $value) {
        return @()
    }

    return @($value)
}

function Get-PackageManifest([string]$ArchivePath) {
    $archive = [System.IO.Compression.ZipFile]::OpenRead($ArchivePath)
    try {
        $manifestEntry = $archive.Entries | Where-Object { $_.FullName -eq "plugin.json" } | Select-Object -First 1
        if ($null -eq $manifestEntry) {
            throw "Plugin package '$ArchivePath' does not contain 'plugin.json'."
        }

        $reader = [System.IO.StreamReader]::new($manifestEntry.Open(), [System.Text.UTF8Encoding]::UTF8, $true)
        try {
            return $reader.ReadToEnd() | ConvertFrom-Json
        }
        finally {
            $reader.Dispose()
        }
    }
    finally {
        $archive.Dispose()
    }
}

$resolvedPackagePath = (Resolve-Path $PackagePath).Path
$assetName = [System.IO.Path]::GetFileName($resolvedPackagePath)
$hash = (Get-FileHash -Path $resolvedPackagePath -Algorithm SHA256).Hash.ToLowerInvariant()
$packageSize = (Get-Item $resolvedPackagePath).Length

$template = Get-Content $TemplatePath -Raw | ConvertFrom-Json
$manifest = Get-PackageManifest -ArchivePath $resolvedPackagePath
$repositoryUrl = [string](Get-PropertyValue $template "repositoryUrl")
if ([string]::IsNullOrWhiteSpace($repositoryUrl)) {
    $repositoryUrl = [string](Get-PropertyValue $template "projectUrl")
}

if ([string]::IsNullOrWhiteSpace($repositoryUrl)) {
    throw "Template is missing repositoryUrl/projectUrl."
}

$repo = Get-RepositoryInfo -RepositoryUrl $repositoryUrl
$downloadUrl = "https://raw.githubusercontent.com/$($repo.Owner)/$($repo.Name)/main/$assetName"
$manifestVersion = [string](Get-PropertyValue $manifest "version")
if ([string]::IsNullOrWhiteSpace($manifestVersion)) {
    throw "Plugin manifest inside '$resolvedPackagePath' is missing 'version'."
}

if ($manifestVersion -ne $Version) {
    throw "Requested version '$Version' does not match package manifest version '$manifestVersion'."
}

$sharedContracts = @(
    Get-ArrayValue -Object $manifest -Name "sharedContracts" |
        ForEach-Object {
            [pscustomobject][ordered]@{
                id = [string](Get-PropertyValue $_ "id")
                version = [string](Get-PropertyValue $_ "version")
                assemblyName = [string](Get-PropertyValue $_ "assemblyName")
            }
        }
)

$tags = @(
    Get-ArrayValue -Object $template -Name "tags" |
        Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } |
        ForEach-Object { [string]$_ }
)

$entry = [pscustomobject][ordered]@{
    id = [string](Get-PropertyValue $manifest "id")
    name = [string](Get-PropertyValue $manifest "name")
    description = [string](Get-PropertyValue $manifest "description")
    author = [string](Get-PropertyValue $manifest "author")
    version = $manifestVersion
    apiVersion = [string](Get-PropertyValue $manifest "apiVersion")
    sharedContracts = $sharedContracts
    minHostVersion = [string](Get-PropertyValue $template "minHostVersion")
    downloadUrl = $downloadUrl
    sha256 = $hash
    packageSizeBytes = $packageSize
    iconUrl = [string](Get-PropertyValue $template "iconUrl")
    releaseTag = "v$manifestVersion"
    releaseAssetName = $assetName
    projectUrl = [string](Get-PropertyValue $template "projectUrl")
    readmeUrl = [string](Get-PropertyValue $template "readmeUrl")
    homepageUrl = [string](Get-PropertyValue $template "homepageUrl")
    repositoryUrl = [string](Get-PropertyValue $template "repositoryUrl")
    tags = $tags
    publishedAt = $Timestamp
    updatedAt = $Timestamp
    releaseNotes = [string](Get-PropertyValue $template "releaseNotes")
}

$directory = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($directory)) {
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
}

$json = $entry | ConvertTo-Json -Depth 20
Write-Utf8File -Path $OutputPath -Content ($json + [Environment]::NewLine)
Write-Host "Generated market sync metadata at '$OutputPath'."
