; BrasaRO Client Installer ? Inno Setup 6
#define MyAppName "BrasaRO"
#define MyAppVersion "13.2"
#define MyAppPublisher "BrasaRO"
#define MyAppURL "http://129.213.27.121:3006/"
#define MyAppExeName "JOGAR.bat"
#define MySetupName "Setup.exe"

[Setup]
AppId={{8F3C2B1A-9D47-4E6F-A1B2-C3D4E5F60718}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=dist
OutputBaseFilename=BrasaRO-Setup
SetupIconFile=payload\BrasaRO\BrasaRO.ico
Compression=lzma2/max
SolidCompression=yes
LZMAUseSeparateProcess=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\BrasaRO.exe
InfoBeforeFile=LEIA-ME-JOGADOR.txt
DirExistsWarning=no
UsedUserAreasWarning=no
MinVersion=10.0

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "Criar atalho na Area de Trabalho"; GroupDescription: "Atalhos:"; Flags: checkedonce

[Files]
Source: "payload\BrasaRO\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "postinstall.ps1"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; IconFilename: "{app}\BrasaRO.exe"
Name: "{group}\{#MyAppName} Setup"; Filename: "{app}\{#MySetupName}"; WorkingDir: "{app}"; IconFilename: "{app}\Setup.ico"
Name: "{group}\Desinstalar {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; IconFilename: "{app}\BrasaRO.exe"; Tasks: desktopicon

[Run]
Filename: "powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{tmp}\postinstall.ps1"" -InstallDir ""{app}"""; \
  StatusMsg: "Aplicando configuracao de video e servidor..."; Flags: runhidden waituntilterminated
Filename: "{app}\{#MyAppExeName}"; Description: "Abrir {#MyAppName} agora"; Flags: nowait postinstall skipifsilent shellexec

[UninstallDelete]
Type: filesandordirs; Name: "{app}\SaveData"
Type: filesandordirs; Name: "{app}\ScreenShot"
Type: filesandordirs; Name: "{app}\log"
