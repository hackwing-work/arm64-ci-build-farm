[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$required = @('git', 'go', 'docker')
$optional = @('kubectl', 'helm', 'terraform', 'cosign', 'syft', 'trivy')
$missingRequired = @()

Write-Host 'ARM64 CI Build Farm - local preflight'
foreach ($command in $required) {
    if (Get-Command $command -ErrorAction SilentlyContinue) {
        Write-Host "[ok]       $command"
    } else {
        Write-Host "[missing]  $command"
        $missingRequired += $command
    }
}
foreach ($command in $optional) {
    if (Get-Command $command -ErrorAction SilentlyContinue) {
        Write-Host "[ok]       $command (optional)"
    } else {
        Write-Host "[skip]     $command (optional)"
    }
}

if ($missingRequired.Count -gt 0) {
    Write-Error "Install required tools: $($missingRequired -join ', ')"
}

