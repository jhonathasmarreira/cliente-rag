# Regras do cliente BrasaRO

**Caminho:** `D:\projetos\ragnarok\BrasaRO`  
**Log de mudanças:** `ALTERACOES_CLIENTE.md` (atualizar sempre que mudar o cliente)  
**Abrir jogo:** `BrasaRO\AbrirBrasaRO.ps1` ou `JOGAR.bat` (não abrir o `.exe` direto)

## Backup (obrigatório)

Antes de patch/NEMO/GRF/EXE/dgVoodoo/OptionInfo/ROExt ou troca grande em `BrasaRO\`:

1. Parar `BrasaRO.exe` se estiver rodando.
2. Pasta: `bkp\BrasaRO_FULL_YYYYMMDD_HHMM\`
3. **ZIP obrigatório:** `bkp\BrasaRO_FULL_YYYYMMDD_HHMM.zip` (não vale só a pasta)
4. Registrar o caminho do backup em `ALTERACOES_CLIENTE.md`

## Estado / convenções

- PACKETVER / EXE: `2010-07-30aRagexeRE` (cliente **RE**)
- Resolução segura: **1024×768** janela (também 640×480, 1280×768, 1280×1024). **Não** usar 1600×900.
- `ISFULLSCREENMODE=0`; abrir com `/window=1`
- Device gráfico: HKCU precisa de `DEVICENAME`/`GUIDDEVICE` (`BrasaRO\ro_video.reg`)
- dgVoodoo: `Resolution = unforced`; `HideCursor=false`; `CaptureMouse=false`; `CenterAppWindow=false`; `ScaleCursor=false`
- DATA.INI: GRFs oficiais; NEMO com Read Data Folder First se usar overlays em `data\`
- Login local típico: `admin` / `admin`

## Mouse livre em janela (ROExt) — obrigatório

O Ragexe prende o cursor via **DirectInput exclusive**. Registro `MOUSEEXCLUSIVE` / OptionInfo / dgVoodoo **não bastam**.

| Arquivo | Função |
|---------|--------|
| `BrasaRO\dinput.dll` | ROExt (Ruri **2010.2.17**, copyright Ruri) — emula DirectInput |
| `BrasaRO\dinput.ini` | `MouseFreedom = 1`; `CodePage = -1` (não forçar UTF-8 no client PT) |

- Fonte de cópia no repo: `download\roext\`
- EXE importa `DINPUT.dll` ? o `dinput.dll` ao lado do EXE é carregado automaticamente
- **Não** usar ROExt 2018+ (`dinput8.dll`) neste client 2010
- Ao gerar instalador (`installer\build.ps1`), os dois arquivos devem ir no payload (robocopy da pasta `BrasaRO`)
- Complementar (já no launcher): `MOUSEEXCLUSIVE=0` no registro, `LockMouse`/`MouseExclusive=0` no OptionInfo, `FreeMouse.ps1`

## PROIBIDO no cliente

| Não fazer | Motivo |
|-----------|--------|
| NEMO patch **71 Ignore Resource Errors** | Esconde erros reais |
| Mudar `idnum2*` / `num2itemresnametable` da capa 2554 “pra consertar equip” | Piorou (ícone Und); proibido pelo usuário |
| Fullscreen sem teste / forçar resolução inválida | Tela azul / D3D morto |
| Deixar lixo em `_ferramentas` | Poluição |
| Assumir que “Cannot init d3d” é GRF | Quase sempre device HKCU incompleto |
| Remover `dinput.dll` / `dinput.ini` ou `MouseFreedom=0` | Mouse volta a ficar preso na janela |
| “Corrigir” mouse só com registro/OptionInfo sem ROExt | Não resolve DirectInput exclusive |

## Se D3D falhar

1. `Setup.exe` admin ? device **dgVoodoo TnL HAL** ? Apply/OK  
2. Exportar registro de novo para `ro_video.reg`  
3. Abrir só via `AbrirBrasaRO.ps1`
