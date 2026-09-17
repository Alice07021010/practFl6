$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$api = if ($env:API_BASE_URL) { $env:API_BASE_URL } else { "http://localhost:8080/api" }
$dist = Join-Path $root "dist_measurements"
Remove-Item $dist -Recurse -Force -ErrorAction SilentlyContinue
New-Item $dist -ItemType Directory | Out-Null

function Measure-Folder($path) {
  $sum = (Get-ChildItem $path -File -Recurse | Measure-Object Length -Sum).Sum
  return [math]::Round($sum / 1MB, 2)
}

function Save-Build($name) {
  $target = Join-Path $dist $name
  Copy-Item "build/web" $target -Recurse
  return Measure-Folder $target
}

flutter clean
flutter pub get

flutter build web --release --no-tree-shake-icons --dart-define=API_BASE_URL=$api
$baseline = Save-Build "js_baseline"

flutter build web --release --dart-define=API_BASE_URL=$api
$optimized = Save-Build "js_optimized"

flutter build web --release --wasm --dart-define=API_BASE_URL=$api
$wasm = Save-Build "wasm"

@(
  [pscustomobject]@{ Variant="JS baseline без tree-shake icons"; SizeMB=$baseline },
  [pscustomobject]@{ Variant="JS release оптимизированная"; SizeMB=$optimized },
  [pscustomobject]@{ Variant="WASM release"; SizeMB=$wasm }
) | Export-Csv (Join-Path $dist "build_sizes.csv") -NoTypeInformation -Encoding UTF8

Write-Host "Готово. Результат: $dist\build_sizes.csv"
