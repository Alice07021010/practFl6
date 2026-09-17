param(
  [string]$RepoName = "practFl6",
  [string]$ApiBaseUrl = "https://example.invalid/api"
)
$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)
flutter build web --release --base-href "/$RepoName/" --dart-define=API_BASE_URL=$ApiBaseUrl
Copy-Item build/web/index.html build/web/404.html -Force
Write-Host "Сборка для GitHub Pages готова в build/web"
