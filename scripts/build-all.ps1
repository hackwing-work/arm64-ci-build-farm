[CmdletBinding()]
param([string]$Version = 'dev')

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$output = Join-Path $root 'dist'
New-Item -ItemType Directory -Force -Path $output | Out-Null
$commit = (git -C $root rev-parse --short HEAD 2>$null)
if (-not $commit) { $commit = 'none' }
$buildDate = [DateTime]::UtcNow.ToString('o')

foreach ($arch in @('amd64', 'arm64')) {
    $env:CGO_ENABLED = '0'
    $env:GOOS = 'linux'
    $env:GOARCH = $arch
    $target = Join-Path $output "build-info-linux-$arch"
    go build -trimpath -ldflags "-s -w -X main.version=$Version -X main.commit=$commit -X main.builtAt=$buildDate" -o $target ./cmd/build-info
    if ($LASTEXITCODE -ne 0) { throw "Build failed for linux/$arch" }
    Write-Host "Built $target"
}

