# Gera BrasaRO-Setup.exe (Inno Setup 6)
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
Set-Location $here

Write-Host '==> prepare-payload'
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'prepare-payload.ps1')

$iscc = @(
  "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
  "${env:LocalAppData}\Programs\Inno Setup 6\ISCC.exe",
  'C:\Program Files (x86)\Inno Setup 6\ISCC.exe'
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $iscc) { throw 'ISCC.exe nao encontrado. Instale Inno Setup 6.' }

New-Item -ItemType Directory -Force -Path (Join-Path $here 'dist') | Out-Null
Write-Host "==> compilando com $iscc (LZMA ? demora em cliente grande)"
& $iscc (Join-Path $here 'BrasaRO.iss')
if ($LASTEXITCODE -ne 0) { throw "ISCC falhou: $LASTEXITCODE" }

Get-Item (Join-Path $here 'dist\BrasaRO-Setup.exe') | Format-List FullName, Length, LastWriteTime
Write-Host 'BUILD_OK'
