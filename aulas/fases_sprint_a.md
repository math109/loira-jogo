# Fases da Sprint A — sala de aula 2026, sala 1998 e banheiro 1998

As três fases já vêm montadas: fundo, colisões (`Paredes` e `Moveis`), objetos com E
(`Interagiveis`), portas, entradas, recortes (para passar por trás) e som de ambiente.
A revisão é: andar por tudo, ajustar o que estiver errado e trocar os sons se quiser.

| Arquivo | O que é | Como chegar nela |
|---|---|---|
| `cenas/fases/sala_2026.tscn` | sala de aula de hoje (cena 1.4, onde a Bia acha o Davi) | porta **D-13** do corredor |
| `cenas/memorias/sala_1998.tscn` | a mesma sala em 1998, jogando como a Marina | F6 com a cena aberta (ainda não tem memória ligada a ela) |
| `cenas/memorias/banheiro_1998.tscn` | o banheiro na noite do trote, jogando como a Marina | F6 com a cena aberta |

O corredor (`teste_corredor.tscn`) ganhou a porta `PortaD13` e a entrada `porta_d13`.

## Como revisar
1. Abra a fase e aperte **F6** (roda só a cena aberta).
2. Ligue **Debug → Visible Collision Shapes** para ver as colisões durante o jogo.
3. Ande encostando em tudo: paredes, cadeiras, mesas, armários.
4. Para ajustar uma colisão: clique no nó em `Paredes` ou `Moveis` e arraste os pontos
   vermelhos, ou mude **Position** e **Shape → Size** no Inspector.
5. Ande **atrás** das cadeiras e das mesas: as pernas da personagem devem sumir.
   Se não sumirem, o recorte está em `Recortes` (o **Base** é a linha do chão do objeto).

## Sons
Cada fase tem `Ambiente` (música/fundo) e, algumas, um som de lugar:

| Fase | Ambiente | Som de lugar |
|---|---|---|
| Sala 2026 | `02_ambiente_base.ogg` | `ArCondicionado` (21_ar_condicionado.wav) perto do ar |
| Sala 1998 | `06_memoria_marina.ogg` | — |
| Banheiro 1998 | `06_memoria_marina.ogg` | `Pingos` (waterDrop.mp3) perto das pias |

Para trocar: clique no nó do som → **Stream** → arraste outro arquivo de `assets/audio/`.
Som que deve repetir precisa estar no grupo **som_em_loop** (aba **Node → Groups**).
`AudioStreamPlayer2D` fica mais alto perto da personagem (**Max Distance** = até onde se ouve).

## Textos
Os textos dos objetos (Lousa, Carteira velha, Espelho, Cabine trancada) são provisórios.
A Isadora pode trocar no Inspector, campo **Texto**. Nas memórias de 1998, o pensamento
aparece com o nome e o retrato da Marina.
