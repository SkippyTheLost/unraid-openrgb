$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$version = "2026.06.28.8"
$stage = Join-Path $root ".build\openrgb"
$runtime = Join-Path $stage "runtime\AppRun"
$dist = Join-Path $root "dist"
$bundle = Join-Path $dist "openrgb-$version.tgz"

if (-not (Test-Path $runtime)) {
    throw "Missing extracted Linux runtime at $runtime. Build it with scripts/build-release.sh on Linux or download the GitHub Actions artifact."
}

Copy-Item -Recurse -Force (Join-Path $root "source\usr\local\emhttp\plugins\openrgb\*") $stage
Set-Content -Encoding ASCII -Path (Join-Path $stage "VERSION") -Value $version
New-Item -ItemType Directory -Force -Path $dist | Out-Null
tar -C (Join-Path $root ".build") -czf $bundle openrgb

$hash = Get-FileHash -Algorithm MD5 $bundle
Write-Host "Bundle: $bundle"
Write-Host "MD5: $($hash.Hash.ToLowerInvariant())"
