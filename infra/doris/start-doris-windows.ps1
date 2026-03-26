# Start Doris on Windows + Docker Desktop (bridge network, same layout as macOS in start-doris.sh)
# Does not require Ubuntu WSL. Usage: .\start-doris-windows.ps1 [-Version 4.0.4]

param(
  [string]$Version = "4.0.4"
)

$ErrorActionPreference = "Stop"
$here = $PSScriptRoot
$composeFile = Join-Path $here "docker-compose-doris.yaml"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Host "Docker not found. Install Docker Desktop and ensure it is running."
  exit 1
}

$dc = $null
if (Get-Command docker -ErrorAction SilentlyContinue) {
  docker compose version 2>$null | Out-Null
  if ($LASTEXITCODE -eq 0) { $dc = "docker compose" }
}
if (-not $dc -and (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
  $dc = "docker-compose"
}
if (-not $dc) {
  Write-Host "Need docker compose (docker compose) or docker-compose."
  exit 1
}

$yaml = @"
networks:
  custom_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.80.0/24

services:
  fe:
    image: apache/doris:fe-${Version}
    hostname: fe
    ports:
      - 8030:8030
      - 9030:9030
      - 9010:9010
    environment:
      - FE_SERVERS=fe1:172.20.80.2:9010
      - FE_ID=1
    networks:
      custom_network:
        ipv4_address: 172.20.80.2

  be:
    image: apache/doris:be-${Version}
    hostname: be
    ports:
      - 8040:8040
      - 9050:9050
    environment:
      - FE_SERVERS=fe1:172.20.80.2:9010
      - BE_ADDR=172.20.80.3:9050
    depends_on:
      - fe
    networks:
      custom_network:
        ipv4_address: 172.20.80.3
"@

Set-Content -Path $composeFile -Value $yaml -Encoding UTF8
Write-Host "Wrote $composeFile"
Write-Host "Starting Doris fe/be (version $Version)..."
if ($dc -eq "docker compose") {
  docker compose -f $composeFile up -d
} else {
  & docker-compose -f $composeFile up -d
}
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Doris started. Connect FE (MySQL protocol): mysql -uroot -P9030 -h127.0.0.1"
Write-Host "FE web: http://127.0.0.1:8030  BE web: http://127.0.0.1:8040"
Write-Host "Stop: $dc -f `"$composeFile`" down"
