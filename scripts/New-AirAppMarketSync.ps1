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

$resolvedPackagePath = (Resolve-Path $PackagePath).Path
$assetName = [System.IO.Path]::GetFileName($resolvedPackagePath)
$hash = (Get-FileHash -Path $resolvedPackagePath -Algorithm SHA256).Hash.ToLowerInvariant()
$packageSize = (Get-Item $resolvedPackagePath).Length

$template = Get-Content $TemplatePath -Raw | ConvertFrom-Json
$repositoryUrl = [string](Get-PropertyValue $template "repositoryUrl")
if ([string]::IsNullOrWhiteSpace($repositoryUrl)) {
    $repositoryUrl = [string](Get-PropertyValue $template "projectUrl")
}

if ([string]::IsNullOrWhiteSpace($repositoryUrl)) {
    throw "Template is missing repositoryUrl/projectUrl."
}

$repo = Get-RepositoryInfo -RepositoryUrl $repositoryUrl
$downloadUrl = "https://raw.githubusercontent.com/$($repo.Owner)/$($repo.Name)/main/$assetName"

$entry = [pscustomobject][ordered]@{
    id = [string](Get-PropertyValue $template "id")
    name = [string](Get-PropertyValue $template "name")
    description = [string](Get-PropertyValue $template "description")
    author = [string](Get-PropertyValue $template "author")
    version = $Version
    apiVersion = [string](Get-PropertyValue $template "apiVersion")
    minHostVersion = [string](Get-PropertyValue $template "minHostVersion")
    downloadUrl = $downloadUrl
    sha256 = $hash
    packageSizeBytes = $packageSize
    iconUrl = [string](Get-PropertyValue $template "iconUrl")
    releaseTag = "v$Version"
    releaseAssetName = $assetName
    projectUrl = [string](Get-PropertyValue $template "projectUrl")
    readmeUrl = [string](Get-PropertyValue $template "readmeUrl")
    homepageUrl = [string](Get-PropertyValue $template "homepageUrl")
    repositoryUrl = [string](Get-PropertyValue $template "repositoryUrl")
    tags = @((Get-PropertyValue $template "tags"))
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
