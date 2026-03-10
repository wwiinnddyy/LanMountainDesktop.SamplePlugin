[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PackageName,

    [Parameter(Mandatory)]
    [string]$Version,

    [Parameter(Mandatory)]
    [string]$ReleaseTag,

    [Parameter(Mandatory)]
    [string]$Md5,

    [Parameter(Mandatory)]
    [string]$Sha256,

    [Parameter(Mandatory)]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Utf8File([string]$Path, [string]$Content) {
    $encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

$notes = @"
# LanMountainDesktop Sample Plugin $ReleaseTag

## 中文

- 发布包：$PackageName
- 正式分发源：GitHub Release 资产
- 仓库根目录的同名 `.laapp` 仍保留为市场回退源
- 插件介绍仍以仓库根目录 `README.md` 为准

## English

- Package: $PackageName
- Canonical distribution: GitHub Release asset
- The repository-root `.laapp` remains the market fallback
- `README.md` in the repository root remains the canonical plugin introduction

<!-- LANAIRAPP_PKG_MD5 {`"$PackageName`":`"$Md5`"} -->
<!-- LANAIRAPP_PKG_SHA256 {`"$PackageName`":`"$Sha256`"} -->
"@

$directory = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($directory)) {
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
}

Write-Utf8File -Path $OutputPath -Content ($notes.Trim() + [Environment]::NewLine)
Write-Host "Generated release notes at '$OutputPath'."
