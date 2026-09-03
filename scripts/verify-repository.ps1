[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$requiredFiles = @(
    'Dockerfile', 'go.mod', 'README.md', 'SECURITY.md',
    '.github/workflows/ci.yml', '.github/workflows/release.yml',
    'deploy/helm/arm64-ci-build-farm/Chart.yaml',
    'infra/runner-scale-set/values.yaml',
    'monitoring/prometheus-rules.yaml'
)

$failures = @()
foreach ($file in $requiredFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $file))) {
        $failures += "Missing $file"
    }
}

$yamlFiles = Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object { $_.Extension -in @('.yml', '.yaml') }
foreach ($file in $yamlFiles) {
    $tabs = Select-String -LiteralPath $file.FullName -Pattern "`t" -SimpleMatch
    if ($tabs) { $failures += "YAML contains a tab: $($file.FullName)" }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}
Write-Host "Repository checks passed ($($requiredFiles.Count) required files, $($yamlFiles.Count) YAML files)."

