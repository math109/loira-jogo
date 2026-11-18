# Unificação dos dois zips (18/11/2026)

Os dois zips vieram da **mesma base do curso**, mas de releases diferentes:

| | `the-blonde` | `the-blonde Sprint A- Isadora` |
|---|---|---|
| Base do curso | release mais nova (Aula 5 **Partes 1, 2 e 3**) | release anterior (só Aula 5 Parte 1) |
| Tem menu inicial + save | sim (`cenas/ui/menu.tscn`, `scripts/sistemas/save.gd`, `scripts/objetos/ponto_seguro.gd`) | não |
| Tem a memória de 1998 | sim (`cenas/memorias/memoria_1.tscn`, `scripts/sistemas/memoria.gd`, `shaders/memoria.gdshader`) | não |
| Arte dos personagens e das luzes | versão nova | versão antiga |
| Passos manuais da Aula 5 feitos | sim (Caderno já é ponto seguro, 9 autoloads, main scene = menu) | não |

Por isso a **base deste zip é o `the-blonde`**: ele contém tudo o que o outro tinha, mais as
Partes 2 e 3. Nada foi perdido.

## O que veio do zip da Isadora

Dois arquivos de diálogo que só existiam lá, copiados **sem nenhuma alteração**:

- `dados/dialogos/prologo_parada.json` — a conversa do Théo, Yasmin, Davi e Bia na parada.
  É conteúdo novo, não existia no outro zip.
- `dados/dialogos/memoria1_chegada.json` — a versão dela da chegada da Marina (tem a fala
  do reflexo: *"Ficou… diferente. Ficou bom. Acho."*).

Nenhum dos dois está ligado a uma cena ainda (nenhum `.tscn` aponta para eles), então eles
não mexem em nada do jogo. Para usar:

- **`prologo_parada.json`**: num `Interagivel` da cena do prólogo, campo `Dialogo` do Inspector.
- **`memoria1_chegada.json`**: a memória de 1998 já usa `memoria_1_chegada.json` (com underline,
  retrato da Marina e o efeito `fragmento: F01`). Se quiserem a fala do reflexo, o melhor é
  **acrescentar um nó** no `memoria_1_chegada.json` em vez de trocar o arquivo — assim o
  retrato e o fragmento continuam funcionando.

## Coisas do zip da Isadora que **não** foram trazidas (de propósito)

- `config/name="The Blonde Atualizado"` → voltou para `"The Blonde"` (é só o nome da janela).
- `run/main_scene` = `teste_corredor.tscn` → voltou para `cenas/ui/menu.tscn`, como pede a
  Aula 5 Parte 2. Para testar direto no corredor, use **F6** com a cena aberta em vez de mudar isso.
- Autoloads escritos como `uid://...` → voltaram para `res://...` (mesmo efeito, só mais legível),
  e o `Save` e o `Memoria` entraram no fim da lista, na ordem certa (9 autoloads).
- `prologo_portao.json` dela estava sem a opção `"Yasmin, você vem comigo?"`; ficou a versão
  que tem a opção.
- `sala_professores.tscn`: o Caderno ficou com o script `ponto_seguro.gd` (Passo 4 da Aula 5).

## Verificações feitas neste zip

- Todos os JSON de `dados/` abrem sem erro de sintaxe.
- Todo `proximo` de diálogo aponta para um nó que existe (ou `fim`).
- Todo `quem` usa um personagem declarado no próprio arquivo.
- Todos os caminhos `res://` citados em `.tscn`, `.gd`, `.json` e `project.godot` existem no zip.
- Nenhum `.uid` duplicado e nenhum script sem `.uid` (é isso que quebra referência no Godot 4).
- O cache `.godot/` foi removido: o Godot recria sozinho ao abrir, e isso evita erro de
  import vindo da máquina de outra pessoa.

## Como abrir

1. Extraia o zip numa pasta nova (não por cima de uma das antigas).
2. Abra o `project.godot` no Godot. Na primeira vez ele reimporta os assets — pode levar um minuto.
3. **F5**. O jogo começa pelo menu.

---

# Sprint A da Lara — fases novas (18/11/2026, 20h)

Pacote com 6 arquivos, conferido e integrado.

**Arquivos novos**

| Arquivo | O que é |
|---|---|
| `cenas/fases/sala_2026.tscn` | sala de aula de hoje (cena 1.4) — chega pela porta **D-13** do corredor |
| `cenas/memorias/sala_1998.tscn` | a mesma sala em 1998, jogando como a Marina (`como_marina = true`) |
| `cenas/memorias/banheiro_1998.tscn` | o banheiro na noite do trote, como a Marina |
| `aulas/fases_sprint_a.md` | o guia de revisão dela |

**Arquivos alterados** (os dois são acréscimos, nada foi removido)

- `cenas/fases/teste_corredor.tscn` — ganhou a porta `PortaD13` e a entrada `porta_d13`.
- `scripts/ui/caixa_dialogo.gd` — em `pensar()`, dentro de uma memória o pensamento
  sai com o nome e o retrato da **Marina** em vez da Bia (usa `Memoria.ativa`).
  Os efeitos `memoria`, `sair_memoria` e `fragmento` da Aula 5 Parte 3 continuam lá.

## Verificações feitas

- A Lara trabalhou **na base certa** (a mesma deste repositório): os dois arquivos
  alterados são acréscimos limpos sobre a versão atual, sem desfazer a Aula 5.
- `Memoria.ativa` existe mesmo no autoload `Memoria` — a linha nova dela não quebra.
- Todos os `res://` das 3 fases novas existem (cenários, áudios, scripts, `bia.tscn`, `hud.tscn`).
- As portas fecham o circuito nos dois sentidos:
  `corredor → sala_2026` (entrada `corredor`) e `sala_2026 → corredor` (entrada `porta_d13`).
  As outras portas do jogo continuam certas.
- `PortaLateral` da sala 2026 é `trancada = true` de propósito: não precisa de destino.
- As 3 fases têm a estrutura que o `fase.gd` espera (`Fundo`, `Bia`, `Entradas`, `Recortes`).
  As duas memórias não têm HUD, o que está certo: a Marina não tem lanterna.

## Arrumado na integração

Cinco cenas tinham `parent="."instance=` sem espaço no nó da Bia
(`memoria_1`, `porta_escada`, `sala_2026`, `sala_1998`, `banheiro_1998`).
O Godot aceita assim, mas ficou padronizado com espaço. Só isso mudou nessas linhas.

## Para revisar no Godot (não dá para testar por fora)

- Andar nas 3 fases com **Debug → Visible Collision Shapes** ligado.
- Na sala 2026, a `SaidaCorredor` é **automática** e fica em y=520; a Bia nasce em y=478,
  a 32 px dela. Entre pela D-13 e confira que ela não volta sozinha para o corredor.
  Se voltar, suba a entrada `corredor` uns 20 px no editor.
