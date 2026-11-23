# Regras ? capa / garment (item 2554)

Mapa completo: `docs/MAPA_CAPA_EQUIP.md`  
Ler este arquivo **antes** de qualquer ¡°fix¡± de equip da Pele do Guardi?o.

## Causa raiz (j? corrigida)

- Cliente: **RagexeRE** `20100730` espera ACK `0x00aa` com **9 bytes** (`wItemSpriteNumber` + `result`).
- Server sem `PACKETVER_RE` mandava **7 bytes** (MAIN) ¡æ UI ¡°n?o pode equipar¡± enquanto SQL j? tinha `equip=4`.
- Fix: `#define PACKETVER_RE` em `server/custom/defines_pre.hpp` + rebuild Docker.

## Fluxo (resumo)

```
Cliente 0x00a9 ¡æ pc_equipitem ¡æ inventory.equip=4 ¡æ ACK 0x00aa (9 bytes RE) ¡æ UI slot capa
Cliente 0x00ab ¡æ pc_unequipitem ¡æ equip=0 ¡æ ACK 0x00ac ¡æ UI invent?rio
```

- Bit garment: **4** (`EQP_GARMENT`)
- Diagn?stico: `SELECT equip FROM inventory WHERE nameid=2554`
- Removido (n?o reativar em produ??o): `@capalog`, tabela `capa_equip_log`, NPC `capa_equip_sync`, patches de log ShowInfo

## PROIBIDO (n?o repetir)

| Tentativa | Status |
|-----------|--------|
| Mudar ?cone / sprite / `resname` | PROIBIDO |
| `@refresh` / recreate no login | PROIBIDO |
| Force unequip + re-equip (flicker) | PROIBIDO |
| NPC ¡°Fix Capa¡± / logs de capa | Removido ? n?o reativar |
| Loja 1z / Reborn 99 na OCI | S? `local_dev.conf` com `BRASARO_LOCAL_DEV=1` |

## Se o bug voltar

1. Confirmar `PACKETVER_RE` no bin?rio.
2. Cruzar `inventory.equip` com o que a UI mostra.
3. Se server `equip=4` e client ¡°n?o pode¡± ¡æ protocolo/ACK, n?o ?cone.
