# Aula 4 — Interagir e inventário

| Parte | O que fica pronto | Requisito do GDD |
|---|---|---|
| **1 · Tecla E e itens** (esta) | Objetos que a Bia inspeciona, quadro de avisos da cena 1.2, itens no chão que vão para o inventário | Comp 8 (tabela hash do grupo), CG 2 (produto escalar para "olhar para") |
| 2 · Celular (Tab) | Celular com abas: Itens (usar o power bank), Mensagens, Notas; F3 mostra a tabela hash | Comp 8 |

**Arquivos novos**

```
scripts/dados/hash_table.gd        tabela hash DE VOCÊS (igual ao repositório)
scripts/dados/item_db.gd           catálogo de itens DE VOCÊS (igual ao repositório)
scripts/sistemas/inventory.gd      inventário DE VOCÊS, com 2 ajustes (ver abaixo)
scripts/ui/avisos.gd               mensagens curtas no topo da tela
cenas/ui/avisos.tscn
scripts/objetos/interagivel.gd     o componente "dá para apertar E aqui"
dados/dialogos/cap1_quadro.json    cena 1.2: o quadro de avisos
scripts/ui/caixa_dialogo.gd        ganhou Dialogo.pensar("texto")
cenas/fases/teste_corredor.tscn    corredor com 5 objetos interativos
```

---

## Passo 1 — Extrair o zip na pasta do projeto

Igual à Aula 3: Godot fechado, **Extrair tudo...** na pasta do jogo, **substituir** quando perguntar.

## Passo 2 — Dois autoloads novos

| Path | Node Name |
|---|---|
| `res://scripts/sistemas/inventory.gd` | `Inventory` |
| `res://cenas/ui/avisos.tscn` | `Avisos` |

A lista fica com 5: `Medo`, `Historia`, `Dialogo`, `Inventory`, `Avisos`.
**Project → Reload Current Project**.

## Passo 3 — Testar

F5, termine a conversa do rádio e ande pelo corredor:

| Onde | O que acontece |
|---|---|
| Power bank no chão, à esquerda | **E** → "Pegou: Power bank" e ele some |
| Algodão no chão, à direita | **E** → vai para o inventário (é uma pista) |
| Quadro de avisos (verde) | **E** de frente → cena 1.2 do roteiro, o Medo sobe um pouco |
| Bebedouro | **E** → um pensamento da Bia |
| Porta do WC | **E** → "Trancado. Ainda bem." |

O **E** pisca em cima do objeto só quando a Bia está perto **e olhando para ele**.

---

## Como funciona

### `interagivel.gd` — um componente reaproveitável
É um `Area2D` (uma área que detecta quem entra, sem bloquear). No Inspector você escolhe:

- **Acao**: `INSPECIONAR` (pensamento curto), `DIALOGO` (abre um `.json`) ou `PEGAR_ITEM`.
- **Texto**, **Dialogo** ou **Item Id**, conforme a ação.
- **So Uma Vez**: depois de usar, não reage mais.
- **Altura Do Aviso**: onde o "E" aparece.

`class_name Interagivel` no topo registra o tipo: no **Add Child Node** dá para procurar
"Interagivel" como se fosse um nó do Godot.

### "Ela está olhando para o objeto?" — CG 2 de novo
```gdscript
var ate_objeto := global_position - _bia.global_position
return _bia.direcao.dot(ate_objeto.normalized()) > 0.35
```
`direcao` é para onde a Bia olha (Aula 2). O produto escalar dá 1 se o objeto estiver
bem na frente, 0 se estiver do lado e −1 se estiver atrás. Com `> 0.35`, aceitamos até
uns 70° para o lado. Sem isso, a Bia "pegaria" coisas de costas.

### O E não avança o diálogo sem querer
Quando o objeto usa o E, ele chama `set_input_as_handled()`: o aperto para ali e não chega
na caixa de diálogo. Se não fizesse isso, o mesmo aperto abriria o diálogo **e** já pularia
a primeira fala.

### O inventário de vocês (Comp 8)
`hash_table.gd`, `item_db.gd` e `inventory.gd` são os do repositório do grupo. Só mudei
duas coisas no `inventory.gd`, porque aqui não existe o `GameState`:
- os avisos (`GameState.toast`) agora usam `Avisos.mostrar`;
- o power bank recarrega a **lanterna** (`lanterna.recarregar(50)`).

Lembrando como a tabela de vocês funciona:

```
h(k) = (c₀·31ⁿ⁻¹ + c₁·31ⁿ⁻² + ... + cₙ₋₁) mod capacidade
```

Cada letra do id (`"power_bank"`) entra na conta, e o resto da divisão pela capacidade (8)
diz em qual **balde** o item cai. Itens que caem no mesmo balde ficam numa lista
(**encadeamento separado**). Quando a tabela passa de 75% cheia, ela dobra de tamanho e
redistribui tudo (**rehash**). No meu teste, o `power_bank` caiu no balde 6.
Na Parte 2, o F3 dentro do celular mostra isso ao vivo.

---

## Exercícios

1. **Crie um interagível na mão** (é o que vocês vão fazer em todos os mapas):
   - Add Child Node no nó `Interagiveis` → procure **Interagivel** → Create. Renomeie `Extintor`.
   - Add Child Node nele → **CollisionShape2D** → Shape: **New RectangleShape2D**, Size `30, 22`.
   - Position do `Extintor`: `690, 238`. Acao `INSPECIONAR`, Texto: o que a Bia pensa do extintor.
2. Mude o `PowerBank` para `So Uma Vez` desligado e Acao `INSPECIONAR`. O que acontece?
3. Em `item_db.gd`, crie um item novo (copie o bloco do `algodao`) e coloque no mapa.

---
---

# Parte 2 — O celular (Tab)

**Arquivos novos:** `scripts/ui/celular.gd`, `dados/celular.json` (e o `assets/items/power_bank.png` novo).

## Passos

1. Extraia o zip na pasta do jogo (substituir).
2. Autoload novo: `res://scripts/ui/celular.gd` com o nome **`Celular`**.
   A lista fica com 6: `Medo`, `Historia`, `Dialogo`, `Inventory`, `Avisos`, `Celular`.
3. Reload Current Project, F5.

## Teclas

| Tecla | O que faz |
|---|---|
| **Tab** | abre / fecha o celular (o jogo pausa) |
| setas | andam entre os itens e as abas |
| **E** ou Enter | usa o item selecionado (o power bank recarrega 50% da lanterna) |
| **F3** | mostra a tabela hash do inventário (para a apresentação) |
| Esc | fecha |

## Como funciona

### Pausar o jogo
`get_tree().paused = true` congela todos os nós do jogo: a Bia, a lanterna (a bateria
para de gastar), o Medo e, depois, a Loira. O celular continua funcionando porque ele
tem `process_mode = PROCESS_MODE_ALWAYS`.

### A tela é montada por código
Em vez de uma cena `.tscn`, o `_montar_tela()` cria cada pedaço com `.new()` e
`add_child()`: o fundo escuro, o aparelho (`Panel` com cantos arredondados), as 3 abas
(`Button` com `toggle_mode`), a grade 4 x 3 de slots (`GridContainer`) e os textos.
Leia de cima para baixo e você vê a tela sendo construída. O tamanho é pensado para a
tela do jogo (640 x 360).

### Aba ITENS = o inventário de vocês
`Inventory.get_items()` devolve os itens na ordem em que foram pegos. Cada slot mostra
o ícone de 16x16 em dobro (32x32) e a quantidade. Ao selecionar, aparecem o nome, a
categoria e a descrição do `ItemDB`. **E** chama `Inventory.use_item(id)`, que é o código
de vocês: ele devolve a mensagem que aparece embaixo ("Bateria recarregada (+50%).").

### Abas MSGS e NOTAS
Vêm de `dados/celular.json` (as mensagens do prólogo, cena 0.1 do roteiro).
Qualquer script pode mandar mensagem nova ou anotar algo:

```gdscript
Celular.receber_mensagem("Calouros Noite", "Théo", "alguém aí?")
Celular.anotar("A porta do banheiro tranca por fora.")
```

### F3 — a tabela hash ao vivo (Comp 8)
Mostra o `Inventory.debug_text()` de vocês: a capacidade, quantos itens, o fator de carga
e em qual balde cada item caiu. Pegue mais itens e veja: quando a carga passa de 0,75,
a capacidade dobra de 8 para 16 e os itens mudam de balde (rehash).

## Exercícios

1. Em `celular.json`, acrescente uma conversa com o "Théo".
2. No `cap1_quadro.json`, no nó `"papel3"`, não tem como mandar mensagem pelo diálogo.
   Desafio: em `caixa_dialogo.gd`, na função `_aplicar`, acrescente
   `if efeitos.has("nota"): Celular.anotar(efeitos.nota)` e use
   `"efeitos": {"nota": "Trote solidário: quinta, meia-noite."}` no `.json`.
3. Pegue itens até a tabela hash fazer o rehash (F3 antes e depois).


## Extra — a arte do celular

`assets/ui/celular.png` é a moldura gerada no SpriteCook. A imagem original tinha o
aparelho com 110 x 202 pixels; para caber a tela do jogo, ela foi esticada para 228 x 336
**sem aumentar os pixels**: os cantos (com a rachadura) ficam iguais e só o meio é repetido,
a técnica de "9 fatias" (nine-slice). O entalhe da câmera e a barra de baixo foram
recolocados no centro. No `celular.gd`, o aparelho virou um `TextureRect` com essa imagem
(constante `ARTE`), e as abas, a grade e os textos foram encaixados dentro da tela desenhada.
