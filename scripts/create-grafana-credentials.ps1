param(
  [string]$AdminUser = "platform-admin",
  [Parameter(Mandatory = $true)]
  [string]$AdminPassword
)

$ErrorActionPreference = "Stop"

$RepositoryRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$TargetPath = Join-Path $RepositoryRoot "kubernetes/grafana/admin-credentials.local.yaml"

$Manifest = @"
apiVersion: v1
kind: Secret
metadata:
  name: grafana-admin-credentials
  namespace: monitoring
  labels:
    app.kubernetes.io/name: grafana
    app.kubernetes.io/component: dashboard
    app.kubernetes.io/part-of: enterprise-platform
type: Opaque
stringData:
  admin-user: $AdminUser
  admin-password: $AdminPassword
"@

Set-Content -Path $TargetPath -Value $Manifest -Encoding UTF8
Write-Host "Created $TargetPath"
