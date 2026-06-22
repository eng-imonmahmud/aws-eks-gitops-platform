$ErrorActionPreference = "Stop"

$RepositoryRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

$RequiredPaths = @(
  "terraform/modules/vpc",
  "terraform/modules/eks",
  "terraform/modules/security-groups",
  "terraform/environments/prod",
  "kubernetes/argocd",
  "kubernetes/prometheus",
  "kubernetes/grafana",
  "kubernetes/nginx",
  "scripts",
  "docs/architecture",
  "docs/screenshots",
  ".github/workflows"
)

$MissingPaths = @()

foreach ($Path in $RequiredPaths) {
  $FullPath = Join-Path $RepositoryRoot $Path
  if (-not (Get-Item -LiteralPath $FullPath -ErrorAction SilentlyContinue)) {
    $MissingPaths += $Path
  }
}

if ($MissingPaths.Count -gt 0) {
  Write-Error ("Missing required paths: " + ($MissingPaths -join ", "))
  exit 1
}

Write-Host "Repository layout validated."
