# BrasaRO launcher
# EXE d3dok respeita WIDTH/HEIGHT (sem MoveWindow).
# Patch HKLM->HKCU exige device dgVoodoo completo no HKCU (ro_video.reg).
$ErrorActionPreference = 'Stop'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$enc = [System.Text.Encoding]::GetEncoding(1252)

$W = 1024
$H = 768

Get-Process BrasaRO -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1

$opt = @"
CmdOnOffList["/fog"] = 0
CmdOnOffList["/camera"] = 1
CmdOnOffList["/effect"] = 1
CmdOnOffList["/bgm"] = 1
CmdOnOffList["/sound"] = 1
CmdOnOffList["/showname"] = 1
CmdOnOffList["/window"] = 1
CmdOnOffList["/noctrl"] = 1
OptionInfoList["Trilinear"] = 0
OptionInfoList["Bgm_Volume"] = 100
OptionInfoList["Effect_Volume"] = 100
OptionInfoList["WIDTH"] = $W
OptionInfoList["HEIGHT"] = $H
OptionInfoList["BITPERPIXEL"] = 32
OptionInfoList["ISFULLSCREENMODE"] = 0
OptionInfoList["Window_XPos"] = 40
OptionInfoList["Window_YPos"] = 40
OptionInfoList["LockMouse"] = 0
OptionInfoList["MouseExclusive"] = 0
"@


New-Item (Join-Path $dir 'SaveData') -ItemType Directory -Force | Out-Null
New-Item (Join-Path $dir 'data') -ItemType Directory -Force | Out-Null
[System.IO.File]::WriteAllText((Join-Path $dir 'SaveData\OptionInfo.lua'), $opt, $enc)
[System.IO.File]::WriteAllText((Join-Path $dir 'data\OptionInfo.lua'), $opt, $enc)

# dgVoodoo: CenterAppWindow/CaptureMouse/ScaleCursor prendem ou atrapalham o mouse
$dgPath = Join-Path $dir 'dgVoodoo.conf'
$dg = @"
[General]
OutputAPI = d3d11_fl11_0
FullScreenMode = false
ScalingMode = unspecified
KeepWindowAspectRatio = false
CaptureMouse = false
CenterAppWindow = false
DisableSplashScreen = true
[GeneralExt]
CursorScaleFactor = 0
WatermarkDisplayDuration = 0
[Glide]
3DfxWatermark = false
3DfxSplashScreen = false
[DirectX]
VideoCard = geforce_9800_gt
VRAM = 1024
Filtering = force_16bit
Resolution = unforced
Antialiasing = appdriven
AppControlledScreenMode = true
dgVoodooWatermark = false
FastVideoMemoryAccess = true
[DirectXExt]
MSAAForceOff = true
HideCursor = false
ScaleCursor = false
"@
[System.IO.File]::WriteAllText($dgPath, ($dg -replace "`n","`r`n"), [System.Text.Encoding]::ASCII)


foreach ($bad in @('dbghelp.dll', 'D3D8.dll')) {
  $p = Join-Path $dir $bad
  if (Test-Path $p) { Rename-Item $p ($bad + '.off') -Force -ErrorAction SilentlyContinue }
}

$regFile = Join-Path $dir 'ro_video.reg'
if (-not (Test-Path $regFile)) {
  Write-Host 'ERRO: falta ro_video.reg (device dgVoodoo). Rode Setup.exe como admin e exporte o registro.'
  exit 1
}
reg import $regFile | Out-Null

$reg = 'HKCU:\Software\Gravity Soft\Ragnarok'
Set-ItemProperty $reg WIDTH $W -Type DWord
Set-ItemProperty $reg HEIGHT $H -Type DWord
Set-ItemProperty $reg BITPERPIXEL 32 -Type DWord
Set-ItemProperty $reg ISFULLSCREENMODE 0 -Type DWord
# Sem isso o Ragexe prende o cursor na janela (mesmo sem fullscreen)
Set-ItemProperty $reg MOUSEEXCLUSIVE 0 -Type DWord
Remove-ItemProperty $reg UIRectInfo -ErrorAction SilentlyContinue
$reg2 = 'HKCU:\Software\Gravity\RagnarokOnline'
if (Test-Path $reg2) { Set-ItemProperty $reg2 MOUSEEXCLUSIVE 0 -Type DWord }

$exePath = Join-Path $dir 'BrasaRO.exe'
$layers = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers'
if (-not (Test-Path $layers)) { New-Item $layers -Force | Out-Null }
Set-ItemProperty -Path $layers -Name $exePath -Value '~ WIN7RTM HIGHDPIAWARE DISABLEDXMAXIMIZEDWINDOWEDMODE' -Type String

Start-Process $exePath -WorkingDirectory $dir
# Watchdog: limpa ClipCursor (Ragexe/dgVoodoo podem prender o mouse na janela)
$freeMouse = Join-Path $dir 'FreeMouse.ps1'
if (Test-Path $freeMouse) {
  Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @(
    '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $freeMouse
  ) | Out-Null
}
Write-Host "BrasaRO ${W}x${H} janela (mouse livre). Login: admin / admin"
