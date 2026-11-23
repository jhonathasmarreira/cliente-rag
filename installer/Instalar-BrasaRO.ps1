# Instalador simples (sem Inno) ? copia payload para Program Files
# Uso: clique direito > Executar com PowerShell (Admin)
#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$payload = Join-Path $here 'payload\BrasaRO'
if (-not (Test-Path (Join-Path $payload 'BrasaRO.exe'))) {
  Write-Host 'Payload ausente. Rode prepare-payload.ps1 primeiro.' -ForegroundColor Red
  exit 1
}

$dest = Join-Path ${env:ProgramFiles} 'BrasaRO'
Write-Host "Instalando em $dest ..."
New-Item -ItemType Directory -Force -Path $dest | Out-Null
& robocopy $payload $dest /E /NFL /NDL /NJH /NJS /nc /ns /np
if ($LASTEXITCODE -ge 8) { throw "robocopy falhou: $LASTEXITCODE" }

& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'postinstall.ps1') -InstallDir $dest

$wsh = New-Object -ComObject WScript.Shell
$desktop = [Environment]::GetFolderPath('Desktop')
$lnk = $wsh.CreateShortcut((Join-Path $desktop 'BrasaRO.lnk'))
$lnk.TargetPath = Join-Path $dest 'JOGAR.bat'
$lnk.WorkingDirectory = $dest
$lnk.IconLocation = (Join-Path $dest 'BrasaRO.exe')
$lnk.Save()

$start = Join-Path ([Environment]::GetFolderPath('StartMenu')) 'Programs\BrasaRO'
New-Item -ItemType Directory -Force -Path $start | Out-Null
$lnk2 = $wsh.CreateShortcut((Join-Path $start 'BrasaRO.lnk'))
$lnk2.TargetPath = Join-Path $dest 'JOGAR.bat'
$lnk2.WorkingDirectory = $dest
$lnk2.IconLocation = (Join-Path $dest 'BrasaRO.exe')
$lnk2.Save()

Write-Host 'Instalacao concluida. Atalho BrasaRO no Desktop.' -ForegroundColor Green
$launch = Read-Host 'Abrir o jogo agora? (S/N)'
if ($launch -match '^[sSyY]') {
  Start-Process -FilePath (Join-Path $dest 'JOGAR.bat') -WorkingDirectory $dest
}
