# Sprites dos personagens

Todos no mesmo estilo, a partir das folhas de conceito do grupo.

| Arquivo (`assets/personagens/`) | Quem |
|---|---|
| `bia.png` | Bia (jogadora) |
| `bia_lanterna.png` | Bia com a lanterna na mão (aparece com a lanterna ligada) |
| `theo.png`, `yasmin.png`, `davi.png` | os calouros |
| `raimundo.png` | o vigia |
| `marina.png` | Marina em 1998 (memórias) |
| `loira.png` | a Loira |

**Formato igual para todos:** 3 colunas × 4 linhas, quadros de **40 × 56**.
Linhas: baixo, esquerda, direita, cima. Colunas: parado, passo A, passo B.
O lado direito é o esquerdo espelhado, então os dois lados ficam idênticos.

## Como instalar
1. Godot fechado, extraia o zip na pasta do projeto (substituir).
2. Abra o Godot. A Bia já usa os quadros novos: no `bia.tscn` o `offset` do Sprite
   passou de `(0, -24)` para `(0, -28)`, para os pés continuarem na colisão.
3. F5 e aperte F: com a lanterna ligada ela segura a lanterna.

## O que mudou no `bia.gd`
```gdscript
const SPRITE_NORMAL := preload("res://assets/personagens/bia.png")
const SPRITE_LANTERNA := preload("res://assets/personagens/bia_lanterna.png")
...
sprite.texture = SPRITE_LANTERNA if lanterna.ligada else SPRITE_NORMAL
```
As duas folhas têm a mesma grade, então o número do quadro (`sprite.frame`) vale nas duas.

## Usar outro personagem (NPC)
Sprite2D com a textura do personagem, **Hframes 3**, **Vframes 4**, **Offset (0, -28)**.
**Frame**: 0 = de frente, 3 = esquerda, 6 = direita, 9 = de costas.
