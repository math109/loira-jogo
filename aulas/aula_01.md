# Aula 1 — A Bia anda pelo corredor

**Objetivo:** abrir o projeto, entender como o Godot organiza um jogo e fazer a Bia
andar, correr e agachar, com animação, colisão, câmera e som.

**Arquivos desta aula**

```
project.godot                      configurações (tela, controles, áudio)
cenas/personagens/bia.tscn         a cena da Bia
scripts/personagens/bia.gd         o código da Bia
cenas/fases/teste_corredor.tscn    o mapa de teste
scripts/fases/fase.gd              o código de qualquer mapa
assets/personagens/bia.png         spritesheet (4 direções × 3 quadros)
```

---

## Parte 1 — Os 3 conceitos que você precisa saber

### 1. Nó (Node)
É a peça básica do Godot. Cada nó faz **uma coisa só**:

| Nó | Faz |
|---|---|
| `Sprite2D` | mostra uma imagem |
| `CollisionShape2D` | define o formato de uma colisão |
| `Camera2D` | decide o que aparece na tela |
| `AudioStreamPlayer` | toca um som |
| `CharacterBody2D` | um corpo que se move e bate nas coisas |

### 2. Cena (Scene, arquivo `.tscn`)
É uma **árvore de nós** salva num arquivo. A Bia é uma cena, o corredor é outra.
Uma cena pode ser colocada **dentro** de outra: o corredor contém a Bia.
Se você mudar a cena da Bia, ela muda em todos os mapas ao mesmo tempo.

### 3. Script (arquivo `.gd`)
É o comportamento. Você "cola" o script num nó e ele passa a ter aquele código.
A linguagem é o **GDScript**, parecida com Python (usa tabulação no lugar de chaves).

---

## Parte 2 — A cena da Bia (`bia.tscn`)

Abra `cenas/personagens/bia.tscn`. A árvore é:

```
Bia (CharacterBody2D)  ← tem o script bia.gd
├── Sprite (Sprite2D)          a imagem
├── Pes (CollisionShape2D)     a colisão
├── Camera2D                   a câmera que segue a Bia
└── Passos (AudioStreamPlayer2D) o som dos passos
```

### Por que `CharacterBody2D`?
Porque ele tem a função `move_and_slide()`: você diz a velocidade e ele move o
personagem, **parando nas paredes e deslizando por elas**. Não precisa calcular
colisão à mão. Em **Motion Mode** está `Floating`, que é o modo para jogos vistos
de cima (o modo `Grounded` é para jogos de plataforma, com chão e gravidade).

### O Sprite e a spritesheet
Clique em **Sprite**. No Inspector:
- **Texture** = `bia.png`, uma imagem com 12 desenhos em grade.
- **Hframes = 3** e **Vframes = 4**: dizem ao Godot para cortar a imagem em 3 colunas e 4 linhas.
- **Frame**: qual pedaço mostrar. Eles são numerados assim:

```
          coluna 0   coluna 1   coluna 2
          (parada)   (passo A)  (passo B)
linha 0  baixo     →    0          1          2
linha 1  esquerda  →    3          4          5
linha 2  direita   →    6          7          8
linha 3  cima      →    9         10         11
```

A fórmula é **frame = linha × 3 + coluna**. É isso que o script usa para animar.

- **Offset = (0, -24)**: sobe a imagem para que a **origem do nó fique nos pés**.
  Assim a posição da Bia é onde ela pisa, o que facilita colisão e ordem de desenho.

### A colisão dos pés
O **Pes** é um retângulo de 14×6 bem embaixo. Em jogos vistos de cima, só os pés
colidem: a cabeça pode "passar na frente" da parede, e isso dá a sensação de profundidade.

### A câmera
A câmera mostra um pedaço de 640×360 do mapa e vai acompanhando a Bia
(veja a Parte 1.5 abaixo para entender de onde vem esse tamanho).
**Position Smoothing** faz a câmera seguir com um atraso suave, em vez de grudada.
Por dentro, o Godot faz uma **interpolação linear (lerp)** entre onde a câmera está e onde
a Bia está: `posição = posição + (alvo − posição) × velocidade × delta`. É o item 1 de
Computação Gráfica do GDD.

### Parte 1.5 — Rasterização em baixa resolução (item 5 de CG no GDD)
Em **Project Settings → Display → Window**:

| Opção | Valor | O que faz |
|---|---|---|
| Viewport Width/Height | 640 × 360 | o jogo é **desenhado** nesse tamanho pequeno |
| Window Width/Height Override | 1280 × 720 | o tamanho da **janela** no computador |
| Stretch Mode | `viewport` | desenha tudo na imagem pequena e depois amplia a imagem inteira |
| Stretch Scale Mode | `integer` | só amplia em números inteiros (2×, 3×), nunca 1,5× |
| Rendering → Default Texture Filter | `Nearest` | amplia sem borrar: cada pixel vira um quadrado nítido |

Nossa arte é desenhada com "pixels de 2×2", então 640×360 na tela equivale a **320×180
pixels de arte**, que é a resolução base do GDD. Se a escala não fosse inteira, alguns
pixels sairiam com 2 de largura e outros com 3, e a arte ficaria torta.

---

## Parte 3 — O script da Bia (`bia.gd`), linha por linha

```gdscript
extends CharacterBody2D
```
"Este script é um CharacterBody2D". Ele herda tudo desse nó, inclusive `velocity` e `move_and_slide()`.

```gdscript
@export var velocidade_andar := 70.0
```
- `var` cria uma variável.
- `:=` cria e já descobre o tipo sozinho (aqui, `float`, número com vírgula).
- `@export` faz ela aparecer no **Inspector**. Clique no nó Bia e mude o valor lá: não precisa mexer no código.

```gdscript
const COLUNAS := 3
const LINHA_BAIXO := 0
```
`const` é um valor que nunca muda. Usamos nomes em vez de números soltos para o código se explicar sozinho.

```gdscript
@onready var sprite: Sprite2D = $Sprite
```
- `$Sprite` busca o nó filho chamado **Sprite**.
- `@onready` espera a cena estar montada antes de buscar. Sem isso, o filho ainda não existiria.
- `: Sprite2D` é o tipo. Ajuda o editor a completar o código e a avisar erros.

```gdscript
func _physics_process(delta: float) -> void:
```
Função que o Godot chama **60 vezes por segundo**, sempre no mesmo ritmo.
É onde fica tudo que mexe com movimento e física.
`delta` é quanto tempo passou desde a última chamada (≈ 0,0167 s).

```gdscript
var entrada := Input.get_vector("mover_esquerda", "mover_direita", "mover_cima", "mover_baixo")
```
Lê os controles e devolve um **vetor** (x, y):

| Tecla | Vetor |
|---|---|
| nada | (0, 0) |
| D | (1, 0) |
| W | (0, -1) — no Godot o **y cresce para baixo** |
| W + D | (0,71, -0,71) — já normalizado, para a diagonal não ser mais rápida |

Os nomes `"mover_esquerda"` etc. são **ações** do Input Map
(Project → Project Settings → Input Map). Cada ação tem teclado e gamepad. Assim o
código nunca fala em tecla, só em ação.

```gdscript
var agachada := Input.is_action_pressed("agachar")
var correndo := Input.is_action_pressed("correr") and not agachada
```
`is_action_pressed` é `true` enquanto a tecla está segurada.
`and not agachada`: se estiver agachada, não corre, mesmo segurando Shift.

```gdscript
velocity = entrada * _velocidade(agachada, correndo)
move_and_slide()
```
- `velocity` é uma variável que já vem do CharacterBody2D: a velocidade em pixels por segundo.
- Direção × velocidade = para onde e quão rápido ir. Ex.: (1, 0) × 70 = (70, 0) → 70 px/s para a direita.
- `move_and_slide()` move de verdade, usando `velocity` e o `delta` por conta própria.

### `_velocidade()`
```gdscript
func _velocidade(agachada: bool, correndo: bool) -> float:
	if agachada:
		return velocidade_agachada
	if correndo:
		return velocidade_correr
	return velocidade_andar
```
Funções que começam com `_` são "internas" (convenção, não regra).
`-> float` diz que ela devolve um número. O primeiro `return` que acontecer encerra a função.

### `_animar()`
```gdscript
if entrada == Vector2.ZERO:
	tempo_animacao = 0.0
	sprite.frame = linha_atual * COLUNAS
	return
```
Parada: mostra a coluna 0 (pose parada) da direção para onde ela olhava por último.

```gdscript
if absf(entrada.x) > absf(entrada.y):
	linha_atual = LINHA_DIREITA if entrada.x > 0 else LINHA_ESQUERDA
else:
	linha_atual = LINHA_BAIXO if entrada.y > 0 else LINHA_CIMA
```
- `absf` é o valor absoluto (tira o sinal).
- Se ela anda mais na horizontal que na vertical, usa a linha de esquerda/direita; senão, cima/baixo.
- `A if condição else B` é um "if numa linha só".

```gdscript
tempo_animacao += delta * ritmo
var coluna := 1 + int(tempo_animacao) % 2
sprite.frame = linha_atual * COLUNAS + coluna
```
- `tempo_animacao` cresce `ritmo` vezes por segundo (7 andando).
- `int(...)` corta a parte decimal: 0, 1, 2, 3, 4…
- `% 2` é o **resto da divisão por 2**: 0, 1, 0, 1… → somando 1, dá **1, 2, 1, 2…**
- Resultado: alterna entre passo A e passo B, 7 vezes por segundo.

### `_tocar_passos()`
```gdscript
if andando and not agachada:
	som_passos.pitch_scale = 1.35 if correndo else 1.0
	if not som_passos.playing:
		som_passos.play()
elif som_passos.playing:
	som_passos.stop()
```
- `pitch_scale` acelera o som (1,35 = 35% mais rápido e agudo) quando ela corre.
- Só chama `play()` se não estiver tocando; senão, o som recomeçaria 60 vezes por segundo.
- Quando o arquivo acaba, `playing` vira `false` e no quadro seguinte ele toca de novo: vira um loop.
- Agachada não faz barulho. Isso vai importar na Aula 6, quando a Loira **ouvir** a Bia.

---

## Parte 4 — O mapa (`teste_corredor.tscn`)

```
Corredor (Node2D)  ← script fase.gd
├── Fundo (Sprite2D)          imagem corredor.png, Centered desligado
├── Paredes (StaticBody2D)
│   ├── ParedeTopo (CollisionShape2D)
│   ├── ParedeEsquerda …
│   └── Banco, Bebedouro, Extintor, Escada …
├── Bia (instância de bia.tscn)
├── Ambiente (AudioStreamPlayer)        som de fundo
└── ZumbidoLampada (AudioStreamPlayer2D) zumbido que fica mais alto perto
```

- **Centered desligado** no Fundo: o canto de cima à esquerda da imagem fica no ponto (0, 0).
  Assim as coordenadas do mapa são as mesmas da imagem: o pixel (480, 300) da imagem é a posição (480, 300) no jogo.
- **StaticBody2D**: um corpo que **não se move** (parede). Cada filho `CollisionShape2D` é um pedaço dela.
  Clique num deles: aparecem **alças laranja** para redimensionar arrastando.
- **AudioStreamPlayer** (sem "2D") toca igual em qualquer lugar.
  **AudioStreamPlayer2D** tem posição: o volume cai com a distância (**Max Distance = 420**).
  Ande perto e longe da lâmpada para ouvir a diferença.
- **Bus**: os sons vão para `Music` ou `SFX`. Esses canais estão no painel **Audio**, embaixo.
  O menu de opções de vocês controla o volume de cada canal.

### `fase.gd`
```gdscript
func _ready() -> void:
	_limitar_camera()
	_repetir_sons_de_ambiente()
```
`_ready()` roda **uma vez**, quando a cena termina de carregar. É o lugar para preparar as coisas.

```gdscript
var camera: Camera2D = bia.get_node("Camera2D")
var tamanho := fundo.texture.get_size()
camera.limit_right = int(tamanho.x)
camera.limit_bottom = int(tamanho.y)
```
Pega o tamanho da imagem (960×640) e proíbe a câmera de mostrar além dela.
Como lê da imagem, funciona em **qualquer mapa** sem mudar nada.

```gdscript
for som in get_tree().get_nodes_in_group("som_em_loop"):
	som.finished.connect(som.play)
```
- **Grupos** são etiquetas: os dois sons de ambiente estão no grupo `som_em_loop` (aba **Node → Groups**).
- **Sinal** (`signal`) é um aviso que um nó dá quando algo acontece. `finished` é emitido quando o som termina.
- `.connect(som.play)`: "quando terminar, chame `play`". Resultado: loop infinito.

---

## Parte 5 — Teste

1. Abra o projeto no Godot 4.7 e aperte **F5**.
2. Confira:
   - [ ] WASD/setas andam nas 4 direções e a animação acompanha.
   - [ ] Shift corre (passos mais rápidos) e Ctrl agacha (lenta e sem som).
   - [ ] Ela não atravessa paredes, o banco, o bebedouro nem a escada.
   - [ ] A câmera não mostra além do cenário.
   - [ ] O zumbido fica mais alto perto da luz (à esquerda, no alto do corredor).
3. Dica: **Debug → Visible Collision Shapes** mostra as colisões enquanto joga.

---

## Exercícios (para você fixar)

1. **Fácil:** no Inspector da Bia, mude `velocidade_correr` para 200 e teste. Volte para 120.
2. **Fácil:** na Camera2D, mude o **Zoom** para (1.5, 1.5). Viu como a arte fica torta?
   Agora tente (2, 2). Por que o 2 funciona e o 1,5 não? (Releia a Parte 1.5.) Volte para (1, 1).
3. **Médio:** o lixo/papel no chão do corredor (perto de x=300, y=420) não tem colisão.
   Adicione um `CollisionShape2D` novo dentro de **Paredes** com um retângulo pequeno ali.
   (Dica: clique com o botão direito em Paredes → Add Child Node.)
4. **Médio:** faça a Bia ficar um pouco mais escura quando agachada.
   Dica: em `_physics_process`, use `sprite.modulate = Color(0.7, 0.7, 0.8) if agachada else Color.WHITE`.
5. **Desafio:** troque o som de passos para `passosMolhados.mp3` só enquanto ela corre.
   Dica: crie um segundo `@export var som_correndo: AudioStream` e troque `som_passos.stream`.

Quando terminar, me mande o que conseguiu (pode ser print ou o `bia.gd`) e as dúvidas.
Na **Aula 2** a gente apaga as luzes: lanterna, bateria e o Medo.
