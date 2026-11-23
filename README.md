# cliente-rag

Cliente **BrasaRO** já ajustado (RagexeRE 2010 + ROExt + dgVoodoo) para o servidor rag Ep 13.2.

É o pack de jogo do projeto — mouse livre (`dinput.dll` / `MouseFreedom=1`), capa, lojas, etc.

## Conteúdo

| Item | Função |
|------|--------|
| `BrasaRO.exe` / GRFs | Cliente (ver `.gitignore` — binários grandes ficam local) |
| `dinput.dll` + `dinput.ini` | ROExt — mouse livre |
| `dgVoodoo.conf` | Wrapper DirectX |
| `installer/` | Fonte do instalador (sem `payload`/`dist`) |
| `regras/` | Regras do cliente / capa |
| `ALTERACOES_CLIENTE.md` | Log de mudanças |

## Backup

Antes de patch/NEMO/GRF/EXE: pasta + ZIP em `bkp\BrasaRO_FULL_YYYYMMDD_HHMM`.
