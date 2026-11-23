# BrasaRO — registro de alterações do cliente

**Regras:** ler `regras/README.md` + `regras/cliente.md` no início.  
Este arquivo é o **log histórico** (atualizar ao mudar o cliente). Não fica dentro de `BrasaRO\`.

- Cliente: `D:\projetos\ragnarok\BrasaRO`
- Regras: `D:\projetos\ragnarok\regras\`
- Este log: `D:\projetos\ragnarok\ALTERACOES_CLIENTE.md`

---

## 2026-11-21 — Mouse preso + ROExt + instalador

- Causa real: Ragexe prende mouse via **DirectInput exclusive** (registro/OptionInfo/dgVoodoo não bastam)
- Fix definitivo: **ROExt** `dinput.dll` + `dinput.ini` (`MouseFreedom=1`, Ruri 2010.2.17)
- Documentado em `regras/cliente.md` (seção Mouse livre) + `.cursor/rules/ler-regras.mdc`
- Backup: `bkp\BrasaRO_FULL_20261121_2214\` + `.zip`
- Instalador: `installer\dist\BrasaRO-Setup.exe` (build com ROExt no payload)


## 2026-11-21 — Pique [4] (1408), não Ice Pick

- Loja Weapons#1z: `1408` (Pike [4] / Pique); removido 1230
- Cards#1z: +4140 Cavaleiro do Abismo, +4253 Alice
- (tentativa anterior Ice Pick 1230 descartada — pedido era Pique)

## Estado atual (2026-11-19 ~00:10)

| Item | Valor |
|------|--------|
| EXE | NEMO `ep132_d3d_ok` + **Increase Zoom Out Max** ¡æ MD5 `22192A9F¡¦` (em `BrasaRO\` e `client\`) |
| Resolu??o | **1024¡¿768** janela (muda via OptionInfo + registro; nativo, sem MoveWindow) |
| Como abrir | **`BrasaRO\AbrirBrasaRO.ps1`** |
| Login | `admin` / `admin` |
| Chat | `data\ChatWndInfo_U.lua` ¡æ `Publico` / `Batalha` |
| Skills/itens PT | overlays em `data\` |
| DATA.INI | `data.grf` + `rdata.grf` |
| dgVoodoo | `Resolution = unforced`, `OutputAPI = d3d11_fl11_0`; **sem** `D3D8.dll` / `dbghelp.dll` ativos |
| Device gr?fico | HKCU deve ter `DEVICENAME`/`GUIDDEVICE` (arquivo `BrasaRO\ro_video.reg`) |
| Backup atual | Pasta `bkp\BrasaRO_FULL_20261121_2214\` + ZIP `bkp\BrasaRO_FULL_20261121_2214.zip` |

## 2026-11-20 — Capa 2554 Und + ghost equip

- Sintoma: cliente mostra capa solta / ícone `Und`, “não pode equipar”; no relog volta equipada (`inventory.equip=4`).
- Cliente: adicionados `data\idnum2itemresnametable.txt` + `num2itemresnametable.txt` (sprite `2554#??#`) em `BrasaRO\`, `client\`, `Program Files\BrasaRO\` e installer.
- Servidor: patch `pc_equip_desync` força unequip+re-equip se já equipado; NPC silencioso `#CapaEquipSync` no login.
- Backup: `bkp\BrasaRO_FULL_20261120_2105\` + `.zip`. |

### Causa da tela azul / resolu??o morta

1. EXE antigo (`client` stub `2CB5624D`) **ignorava** WIDTH/HEIGHT ¡æ janela 166¡¿47; `MoveWindow` depois gerava faixas azuis (backbuffer ¡Á HWND).
2. EXE novo com patch **27 HKLM¡æHKCU** lia s? HKCU, que tinha WIDTH/HEIGHT mas **sem** `DEVICENAME`/`GUIDDEVICE` do Setup ¡æ `Cannot init d3d OR grf`.
3. Device completo estava em `HKLM\¡¦\WOW6432Node\Gravity Soft\Ragnarok` (`dgVoodoo HAL`). Sem copiar isso para HKCU, D3D falhava.
4. `Resolution=1600x900` for?ado no dgVoodoo + fullscreen no OptionInfo piorava tudo. **1600¡¿900 n?o existe** na tabela de modos deste client.

### O que corrigiu

- Rebuild NEMO com `ep132_d3d_ok_patches.txt` (sem patch 71).
- Importar/manter device dgVoodoo em **HKCU** (`ro_video.reg` + launcher).
- OptionInfo + registro: janela, `ISFULLSCREENMODE=0`, `/window=1`.
- Launcher n?o usa mais MoveWindow.

### Como mudar resolu??o

Editar `WIDTH`/`HEIGHT` no launcher (`AbrirBrasaRO.ps1`) ou no OptionInfo + registro. Modos seguros deste EXE: **640¡¿480, 1024¡¿768, 1280¡¿768, 1280¡¿1024** (n?o usar 1600¡¿900).

Se voltar `Cannot init d3d`: rodar `Setup.exe` como admin, escolher device **dgVoodoo TnL HAL**, Apply/OK; depois `reg export` de novo para `ro_video.reg`.

---

## Regras para o agente

Fonte canônica: **`regras/cliente.md`** (e `regras/capa-equip.md` para capa 2554).

1. Ler `regras/` e **atualizar este MD** ao mudar cliente.
2. Antes de patch/NEMO/GRF/EXE/dgVoodoo: backup **pasta + ZIP** (obrigatório os dois).
3. Nunca deixar `ISFULLSCREENMODE=1` sem teste.
4. Não usar NEMO patch **71 Ignore Resource Errors**.
5. Abrir via `AbrirBrasaRO.ps1`.
6. Patch **27 HKLM?HKCU** exige device completo no HKCU (não só WIDTH/HEIGHT).
7. Não gerar lixo em `_ferramentas` sem limpar depois.
8. Capa: nunca ícone/@refresh/force unequip — ver `regras/capa-equip.md`.

---

## Hist?rico

| Quando | O qu? |
|--------|--------|
| 2026-11-18 | Tradu??o PT, chat Publico/Batalha, skills/itens data overlays |
| 2026-11-18 noite | NEMO bisect; lixo; tela pequena/azul |
| 2026-11-18 23:35 | Diagn?stico fullscreen + stub EXE; launcher MoveWindow |
| 2026-11-19 00:10 | Causa raiz: HKCU sem device + stub EXE; rebuild d3dok; registry device; resolu??o nativa; login admin/admin |
| 2026-11-19 01:29 | Backup FULL pasta+ZIP; regra obrigat?ria de ZIP (`.cursor/rules` + este MD) |

## 2026-11-19 — Cadastro desfeito; GM admCaio
- Removidos Cadastro.exe / register-api / porta 8089.
- Conta GM: admCaio / Caio (group_id 99) no OCI e seed sql.
- OCI MariaDB host port: 3307 (3306 ocupada pelo Clipadores).


## 2026-11-19 — Cliente local ? 127.0.0.1
- BrasaRO e client apontam para servidor local (127.0.0.1:6900).
- Instalador/payload continua com IP OCI; só muda ao pedir nova versão.


## 2026-11-19 — Cursor sumindo no instalado (Program Files)
- Causa: pasta so leitura ? VirtualStore + OptionInfo incompleto; cursor some com dgVoodoo.
- Fix instalado: ACL Modify para Users, limpeza VirtualStore, OptionInfo + DPIUNAWARE.
- postinstall.ps1 passa a aplicar ACL + DPI nas proximas builds.


## 2026-11-19 — Mouse no instalado
- Causa: AbrirBrasaRO.ps1 sobrescrevia dgVoodoo.conf sem HideCursor/CaptureMouse.
- Fix: conf completo (HideCursor=false, CaptureMouse=false, ScaleCursor=true); launcher nao sobrescreve mais.
- DPI flags iguais ao local: WIN7RTM HIGHDPIAWARE DISABLEDXMAXIMIZEDWINDOWEDMODE.


## 2026-11-19 17:35 — Novo BrasaRO-Setup.exe
- Rebuild com dgVoodoo HideCursor + launcher sem sobrescrever conf + postinstall ACL/DPI.
- Arquivo: `installer\dist\BrasaRO-Setup.exe` e copia em `D:\projetos\ragnarok\BrasaRO-Setup.exe`.
- Clientinfo do instalador: 129.213.27.121 (OCI).


## 2026-11-20 — OCI BG teste (MinPlayers 1) + bkp

- BKP OCI: /opt/bkp/brasaro_FULL_20261120_1853/ + .zip (+ .tar.gz)
- Deploy: NPC Prontera 151,190, KvM min 1x1, contas bgG*/bgC*
- Contas OCI: admin/admin, admCaio/Caio, bgC1/bgC1 (teste 2 contas)

## 2026-11-20 — Capa 2554 Und + ghost equip

- Sintoma: cliente mostra capa solta / icone Und, nao pode equipar; no relog volta equipada (inventory.equip=4).
- Cliente: data\idnum2itemresnametable.txt + num2itemresnametable.txt (sprite 2554 = manto) em BrasaRO, client, Program Files e installer.
- Servidor: patch pc_equip_desync forca unequip+re-equip se ja equipado; sync silencioso no login (#CapaEquipSync).
- Backup: bkp\BrasaRO_FULL_20261120_2105\ + .zip

## 2026-11-20 21:28 — Revert icone capa + log diagnostico

- Removidos idnum2itemresnametable/num2itemresnametable do data\ (icone original do GRF).
- Nao alterar sprite/icone da capa 2554.
- Log: log/capa_equip.log + tabela SQL capa_equip_log + @capalog + ShowInfo no map-server.

## 2026-11-20 22:10 — Causa raiz ghost capa (PACKETVER_RE)

- Sintoma: unequip OK no client; reequip ? "Você não pode equipar"; SQL/`script_equip` com `equip=4` (servidor aceitou).
- Causa: build com PACKETVER=20100730 **sem** `PACKETVER_RE`. ACK `0x00aa` ia com 7 bytes (MAIN); RagexeRE >=20100629 espera 9 bytes (view id + result) ? client lia `result` errado.
- Fix servidor (sem mudar ícone/sprite, sem @refresh, sem force unequip): `server/custom/defines_pre.hpp` define `PACKETVER_RE`; rebuild imagem Docker.
- Limpeza: `inventory.equip=0` no char teste antes do reteste se ainda houver fantasma.

## 2026-11-20 22:30 â€” Limpeza capa + bkp + release

- Removidos: @capalog, capa_equip_log, NPC capa_equip_sync, patches de log ShowInfo.
- ProduÃ§Ã£o: PACKETVER_RE + desync sync-only (sem log). Loja 1z/Reborn sÃ³ com BRASARO_LOCAL_DEV=1.
- Backup: `bkp\BrasaRO_FULL_20261120_2227\` + `bkp\BrasaRO_FULL_20261120_2227.zip`


- Setup novo: `installer\dist\BrasaRO-Setup.exe` e copia `BrasaRO-Setup.exe` na raiz (~2.0 GB).
- OCI: sync+rebuild com PACKETVER_RE; BRASARO_LOCAL_DEV=0; capa_equip_log dropada; map online.


## 2026-11-21 — dgVoodoo watermark
- dgVoodooWatermark = false + conf em CRLF (antes era LF e podia ser ignorado).
- Aplicado em BrasaRO\, client\, installer\payload e Program Files\BrasaRO.


## 2026-11-21 — watermark + loja 1z
- dgVoodoo.conf minimo (sem chaves duplicadas); AppData+BrasaRO+Program Files; watermark false.
- Loja 1z: trocou callshop por getitem (client 2010 travava em Comprando Itens); textos sem acento quebrado.

