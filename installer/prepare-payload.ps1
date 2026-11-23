# Prepara pasta limpa do cliente para o instalador
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$src = Join-Path $root 'BrasaRO'
$dst = Join-Path $PSScriptRoot 'payload\BrasaRO'

if (-not (Test-Path (Join-Path $src 'BrasaRO.exe'))) {
  throw "Cliente nao encontrado: $src"
}

Write-Host "Limpando payload..."
if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
New-Item -ItemType Directory -Path $dst -Force | Out-Null

Write-Host "Copiando cliente (pode demorar)..."
& robocopy $src $dst /E /XD `
  ScreenShot SaveData HShield_off PatchClient_off _ferramentas `
  /XF `
  '*.bak' '*.bak_*' '*.off' '*.old' '*_old' `
  'BrasaRO.exe.bak_hotkey' 'dbghelp.dll_old' `
  /NFL /NDL /NJH /NJS /nc /ns /np
$code = $LASTEXITCODE
if ($code -ge 8) { throw "robocopy falhou: $code" }

# Pastas vazias uteis
New-Item -ItemType Directory -Force -Path (Join-Path $dst 'SaveData') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $dst 'ScreenShot') | Out-Null

# Garantir IP do servidor OCI
foreach ($name in @('sclientinfo.xml', 'clientinfo.xml')) {
  $f = Join-Path $dst "data\$name"
  if (Test-Path $f) {
    $xml = Get-Content $f -Raw -Encoding Default
    $xml = [regex]::Replace($xml, '<address>.*?</address>', '<address>129.213.27.121</address>')
    [System.IO.File]::WriteAllText($f, $xml, [System.Text.Encoding]::GetEncoding(1252))
  }
}

# Atalhos / docs do instalador
Copy-Item (Join-Path $PSScriptRoot 'LEIA-ME-JOGADOR.txt') (Join-Path $dst 'LEIA-ME.txt') -Force
Copy-Item (Join-Path $PSScriptRoot 'JOGAR.bat') (Join-Path $dst 'JOGAR.bat') -Force -ErrorAction SilentlyContinue

$bytes = (Get-ChildItem $dst -Recurse -File | Measure-Object Length -Sum).Sum
Write-Host ("PAYLOAD_OK {0:N2} GB em {1}" -f ($bytes / 1GB), $dst)
