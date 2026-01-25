# OpenKodo installer for Windows
# Usage: irm https://raw.githubusercontent.com/paxtone-io/openkodo/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$Repo = "paxtone-io/openkodo"
$BinaryName = "kodo.exe"

function Write-Info { param($Message) Write-Host "→ $Message" -ForegroundColor Green }
function Write-Warn { param($Message) Write-Host "⚠ $Message" -ForegroundColor Yellow }
function Write-Err { param($Message) Write-Host "✗ $Message" -ForegroundColor Red; exit 1 }

# Detect architecture
function Get-Target {
    $arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
    switch ($arch) {
        "X64" { return "x86_64-pc-windows-msvc" }
        "Arm64" { return "aarch64-pc-windows-msvc" }
        default { Write-Err "Unsupported architecture: $arch" }
    }
}

# Get latest release version
function Get-LatestVersion {
    $response = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest"
    return $response.tag_name
}

function Install-Kodo {
    Write-Info "Installing OpenKodo (古道)..."

    $target = Get-Target
    Write-Info "Detected: Windows ($target)"

    # Get latest version
    Write-Info "Fetching latest release..."
    $version = Get-LatestVersion

    if (-not $version) {
        Write-Err "Failed to get latest version"
    }

    Write-Info "Latest version: $version"

    # Construct download URL
    $filename = "kodo-$target.zip"
    $url = "https://github.com/$Repo/releases/download/$version/$filename"

    Write-Info "Downloading from: $url"

    # Create temp directory
    $tmpDir = New-Item -ItemType Directory -Path (Join-Path $env:TEMP "kodo-install-$(Get-Random)")

    try {
        # Download
        $zipPath = Join-Path $tmpDir $filename
        Invoke-WebRequest -Uri $url -OutFile $zipPath

        # Extract
        Write-Info "Extracting..."
        Expand-Archive -Path $zipPath -DestinationPath $tmpDir

        # Install to user's local bin
        $installDir = Join-Path $env:LOCALAPPDATA "Programs\kodo"
        if (-not (Test-Path $installDir)) {
            New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        }

        Write-Info "Installing to $installDir..."
        Copy-Item (Join-Path $tmpDir $BinaryName) -Destination $installDir -Force

        # Add to PATH if not already there
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$installDir*") {
            Write-Info "Adding to PATH..."
            [Environment]::SetEnvironmentVariable("Path", "$userPath;$installDir", "User")
            $env:Path = "$env:Path;$installDir"
        }

        # Verify
        Write-Info "Installation complete!"
        Write-Host ""
        & (Join-Path $installDir $BinaryName) --version
        Write-Host ""
        Write-Info "Run 'kodo init' in your project to get started."
        Write-Warn "You may need to restart your terminal for PATH changes to take effect."

    } finally {
        Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue
    }
}

Install-Kodo
