param([Parameter(Mandatory = $true)][string]$InstallDir)
$ErrorActionPreference = 'SilentlyContinue'
$reg = Join-Path $InstallDir 'ro_video.reg'
if (Test-Path $reg) {
  & reg.exe import $reg | Out-Null
}
# Mouse livre em janela (sem MOUSEEXCLUSIVE o Ragexe prende o cursor)
$hk = 'HKCU:\Software\Gravity Soft\Ragnarok'
if (-not (Test-Path $hk)) { New-Item $hk -Force | Out-Null }
Set-ItemProperty $hk MOUSEEXCLUSIVE 0 -Type DWord
Set-ItemProperty $hk ISFULLSCREENMODE 0 -Type DWord
$hk2 = 'HKCU:\Software\Gravity\RagnarokOnline'
if (Test-Path $hk2) { Set-ItemProperty $hk2 MOUSEEXCLUSIVE 0 -Type DWord }


# Program Files e so leitura: sem escrita o RO usa VirtualStore e o cursor some.
& icacls.exe $InstallDir /grant "*S-1-5-32-545:(OI)(CI)M" /T | Out-Null

# Limpa sombra VirtualStore de instalacoes anteriores
$vs = Join-Path $env:LOCALAPPDATA "VirtualStore\Program Files\BrasaRO"
if (Test-Path $vs) { Remove-Item $vs -Recurse -Force }

# OptionInfo padrao 1024x768 janela
$optDir = Join-Path $InstallDir 'SaveData'
New-Item -ItemType Directory -Force -Path $optDir | Out-Null
$enc = [System.Text.Encoding]::GetEncoding(1252)
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
OptionInfoList["WIDTH"] = 1024
OptionInfoList["HEIGHT"] = 768
OptionInfoList["BITPERPIXEL"] = 32
OptionInfoList["ISFULLSCREENMODE"] = 0
OptionInfoList["Window_XPos"] = 40
OptionInfoList["Window_YPos"] = 40
OptionInfoList["LockMouse"] = 0
"@
[System.IO.File]::WriteAllText((Join-Path $optDir 'OptionInfo.lua'), $opt, $enc)
$dataOpt = Join-Path $InstallDir 'data\OptionInfo.lua'
if (Test-Path (Split-Path $dataOpt)) {
  [System.IO.File]::WriteAllText($dataOpt, $opt, $enc)
}

# Mesmos flags do cliente local que funciona (cursor/DPI)
$exe = Join-Path $InstallDir 'BrasaRO.exe'
if (Test-Path $exe) {
  $layers = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers'
  if (-not (Test-Path $layers)) { New-Item $layers -Force | Out-Null }
  Set-ItemProperty -Path $layers -Name $exe -Value '~ WIN7RTM HIGHDPIAWARE DISABLEDXMAXIMIZEDWINDOWEDMODE' -Type String
}
