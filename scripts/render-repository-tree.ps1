param(
  [int]$Depth = 4
)

$ErrorActionPreference = "Stop"

$RepositoryRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ExcludedNames = @(".git", ".terraform", "node_modules")

function Write-Tree {
  param(
    [string]$Path,
    [string]$Prefix,
    [int]$CurrentDepth
  )

  if ($CurrentDepth -gt $Depth) {
    return
  }

  $Items = Get-ChildItem -LiteralPath $Path -Force |
    Where-Object { $ExcludedNames -notcontains $_.Name } |
    Sort-Object @{ Expression = { -not $_.PSIsContainer } }, Name

  foreach ($Item in $Items) {
    Write-Host "$Prefix$($Item.Name)"
    if ($Item.PSIsContainer) {
      Write-Tree -Path $Item.FullName -Prefix "$Prefix  " -CurrentDepth ($CurrentDepth + 1)
    }
  }
}

Write-Host (Split-Path $RepositoryRoot -Leaf)
Write-Tree -Path $RepositoryRoot -Prefix "  " -CurrentDepth 1
