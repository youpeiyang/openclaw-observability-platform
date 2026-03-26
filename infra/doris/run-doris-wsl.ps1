# Start Doris via WSL using start-doris.sh (requires WSL2 + Docker Desktop)
# Usage: .\run-doris-wsl.ps1 [-Version 4.0.4]

param(
  [string]$Version = "4.0.4"
)

$ErrorActionPreference = "Stop"
$here = $PSScriptRoot

if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
  Write-Host "WSL not found. Install WSL2 + Ubuntu and Docker Desktop (WSL integration). See README.txt"
  exit 1
}

if (-not (Test-Path (Join-Path $here "start-doris.sh"))) {
  Write-Host "Missing start-doris.sh in this folder."
  exit 1
}

function Convert-WindowsPathToWsl([string]$WinPath) {
  $p = $WinPath.TrimEnd('\')
  if ($p -match '^([A-Za-z]):\\(.*)$') {
    $d = $Matches[1].ToLower()
    $rest = ($Matches[2] -replace '\\', '/').Trim('/')
    if ($rest) { return "/mnt/$d/$rest" }
    return "/mnt/$d"
  }
  throw "Cannot convert to WSL path: $WinPath"
}

try {
  $wslDir = Convert-WindowsPathToWsl $here
} catch {
  Write-Host "Could not map path to WSL. In Ubuntu, run: bash start-doris.sh -v $Version"
  exit 1
}

Write-Host "WSL path: $wslDir"
Write-Host "Doris version: $Version (images: apache/doris:fe-$Version, be-$Version)"
Write-Host ""

$bashCmd = ('cd ''{0}'' && chmod +x start-doris.sh && bash start-doris.sh -v {1}' -f $wslDir, $Version)
wsl -e bash -lc $bashCmd
