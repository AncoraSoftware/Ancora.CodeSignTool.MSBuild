param (
    [string]$Version = "latest",
    [string]$OutDir
)

$ErrorActionPreference = 'Stop'

$owner = "AncoraSoftware"
$repo = "CodeSignTool-Mirror"

function Get-Release {
    param([string]$Version)

    $uri = if ($Version -eq "latest") {
        "https://api.github.com/repos/$owner/$repo/releases/latest"
    } else {
        "https://api.github.com/repos/$owner/$repo/releases/tags/$Version"
    }

    try {
        Write-Output "Fetching release info from $uri..."
        return Invoke-RestMethod -Uri $uri -Headers @{ "User-Agent" = "PowerShell" }
    } catch {
        Write-Error "Failed to retrieve release info for version '$Version'."
        Write-Error "Details: $($_.Exception.Message)"
        exit 2
    }
}

function Download-And-Extract {
    param (
        [object]$Asset,
        [string]$OutDir
    )

    if (-not $Asset -or -not $Asset.browser_download_url) {
        Write-Error "Release does not contain a downloadable asset."
        exit 3
    }

    # Sanitize OutDir: remove quotes and trailing slashes
    if ($OutDir) {
        $OutDir = $OutDir.Trim('"').TrimEnd('\','/')
        $parent = Split-Path $OutDir -Parent
        if ($parent -and -not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent | Out-Null
        }
        if (Test-Path $OutDir) {
            Remove-Item -Recurse -Force $OutDir
        }
    }
    $zipPath = Join-Path $OutDir $Asset.name
    
    try {
        New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
        Write-Output "Downloading $($Asset.browser_download_url)..."
        Invoke-WebRequest -Uri $Asset.browser_download_url -OutFile $zipPath -Headers @{ "User-Agent" = "PowerShell" }
    } catch {
        Write-Error "Failed to download asset: $($Asset.name)"
        Write-Error "Details: $($_.Exception.Message)"
        exit 4
    }

    try {
        Expand-Archive -Path $zipPath -DestinationPath $OutDir -Force
        Write-Output "Extracted to: $OutDir"
        
        # Delete the downloaded archive after successful extraction
        Remove-Item -Path $zipPath -Force
        Write-Output "Deleted download archive: $($Asset.name)"
    } catch {
        Write-Error "Failed to extract zip archive."
        Write-Error "Details: $($_.Exception.Message)"
        exit 5
    }
}

try {
    $release = Get-Release -Version $Version

    $asset = $release.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1
    if (-not $asset) {
        Write-Error "No .zip file found in release '$Version'."
        exit 6
    }

    if (-not $OutDir) {
        $OutDir = Join-Path $PSScriptRoot "CodeSignTool"
    }
    Download-And-Extract -Asset $asset -OutDir $OutDir
} catch {
    Write-Error "Unexpected error: $($_.Exception.Message)"
    exit 99
}
