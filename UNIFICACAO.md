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
