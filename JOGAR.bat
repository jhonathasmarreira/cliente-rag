@echo off
cd /d "%~dp0"
if exist "ro_video.reg" reg import "ro_video.reg" >nul 2>&1
if exist "AbrirBrasaRO.ps1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "AbrirBrasaRO.ps1"
) else (
  start "" "BrasaRO.exe"
)
