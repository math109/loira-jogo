# Aula 5 — Sair do corredor

| Parte | O que fica pronto | Requisito do GDD |
|---|---|---|
| **1 · Portas e troca de cena** (esta) | Portas que levam a outras fases com a tela escurecendo; a Bia aparece na entrada certa; o jogo lembra o que já foi pego e a bateria da lanterna | — |
| 2 · Ponto seguro | A sala dos professores salva o jogo | Comp 8 |
| 3 · Memória 1 (1998) | Filtro quente e a Marina | CG 5 |

**Mapa desta parte**

```
 Sala dos Professores ──porta D-11── Corredor ──saída de baixo── Fim do corredor (grade da escada)
                                        │
                                   escada da direita (trancada por enquanto)
```

**Arquivos novos**

```
scripts/sistemas/transicao.gd      autoload: escurece, troca a fase, clareia
scripts/objetos/porta.gd           uma porta = um Interagivel que troca de fase
scripts/fases/entrada.gd           ponto onde a Bia aparece numa fase
scripts/fases/recorte.gd           pedaço do cenário que fica na frente da Bia (passar por trás)
assets/cenarios/*.png              10 cenários novos (labs, cantinas, guarita, pátio, hall,
                                   subsolo, corredor e banheiro do Bloco Antigo)
cenas/fases/sala_professores.tscn  fase nova, já montada (colisões, móveis, objetos)
cenas/fases/porta_escada.tscn      fase nova, já montada
```

**Arquivos que mudaram**

```
scripts/fases/fase.gd              põe a Bia na entrada; diálogo de entrada só na 1ª vez
scripts/objetos/interagivel.gd     lembra o que já foi pego/usado entre as fases
scripts/personagens/lanterna.gd    a bateria passa de uma fase para outra
scripts/personagens/bia.gd         ganhou olhar_para(direção)
```

> O `teste_corredor.tscn` **não vem no zip**: ele é seu (você mudou o power bank de
> lugar). As portas do corredor você coloca na mão, no Passo 3.

---

## Passo 1 — Extrair o zip
Godot fechado, **Extrair tudo...** na pasta do projeto, **substituir**.

## Passo 2 — Autoload novo

| Path | Node Name |
|---|---|
| `res://scripts/sistemas/transicao.gd` | `Transicao` |

A lista fica com 7. **Project → Reload Current Project**.

## Passo 3 — Portas no corredor (na mão)

Abra `teste_corredor.tscn`.

**3.1 — Um nó para guardar as portas.** Clique com o botão direito em `Corredor` →
Add Child Node → **Node2D** → renomeie para `Portas`.

**3.2 — A porta da sala dos professores (D-11).**
Botão direito em `Portas` → Add Child Node → procure **Porta** (aparece porque o
script tem `class_name Porta`) → renomeie `PortaProfessores`.

| Inspector | Valor |
|---|---|
| Position | `68, 236` |
| Cena Destino | `res://cenas/fases/sala_professores.tscn` (pastinha) |
| Entrada Destino | `porta` |
| Altura Do Aviso | `60` |

Dentro dela: Add Child Node → **CollisionShape2D** → Shape: **New RectangleShape2D**, Size `50, 22`.

**3.3 — A saída de baixo (passagem, sem E).** Outra Porta dentro de `Portas`, nome `SaidaBaixo`:

| Inspector | Valor |
|---|---|
| Position | `487, 548` |
| Cena Destino | `res://cenas/fases/porta_escada.tscn` |
| Entrada Destino | `corredor` |
| Automatica | ligado |

CollisionShape2D com RectangleShape2D `90, 20`.

**3.4 — A escada da direita, trancada.** Outra Porta, nome `Escada`:

| Inspector | Valor |
|---|---|
| Position | `912, 300` |
| Trancada | ligado |
| Texto | `A escada para o térreo. O Raimundo pediu para eu não sair do bloco.` |
| Altura Do Aviso | `50` |

CollisionShape2D com RectangleShape2D `50, 60`.

**3.5 — As entradas do corredor** (onde a Bia aparece ao VOLTAR para cá).
Botão direito em `Corredor` → Add Child Node → **Node2D** → `Entradas`.
Dentro dele, Add Child Node → procure **Entrada**. Crie duas:

| Nome (exatamente assim) | Position | Olhando |
|---|---|---|
| `porta_professores` | `68, 272` | `0, 1` (para baixo) |
| `saida_baixo` | `487, 490` | `0, -1` (para cima) |

Salve (Ctrl+S).

## Passo 4 — Testar
F5. Termine a conversa do rádio e:

| Faça | O que acontece |
|---|---|
| E na porta D-11 (esquerda) | tela escurece → sala dos professores, a Bia na porta olhando para cima |
| E na porta da sala | volta ao corredor **na frente da D-11** |
| Pegue o power bank, vá e volte | ele **não** reaparece |
| Ande pela saída de baixo | fim do corredor, com a grade da escada |
| E na escada da direita | "O Raimundo pediu para eu não sair do bloco." |

Repare: o rádio não fala de novo quando você volta, e a bateria continua de onde parou.

---

## Como funciona

### Transição (`transicao.gd`)
```gdscript
get_tree().paused = true                 # ninguém se mexe no escuro
await _escurecer(1.0)                    # tween: tela preta aparece
get_tree().change_scene_to_file(cena)    # troca a fase
await get_tree().scene_changed           # espera a fase nova existir
get_tree().paused = false
await _escurecer(0.0)                    # clareia
```
`await` espera algo terminar sem travar o jogo. O **tween** anima um valor ao longo
do tempo: aqui a transparência (`modulate:a`) de um retângulo preto do tamanho da tela.
Ele vive num autoload porque a fase antiga é apagada no meio da troca: um nó da fase
não conseguiria terminar a animação.

### Porta = Interagivel + troca de fase (herança)
```gdscript
class_name Porta
extends Interagivel
```
A Porta **herda** tudo do Interagivel (o E piscando, o produto escalar do "olhando
para"...) e só **sobrescreve** o `interagir()`. `super._ready()` chama o `_ready` do pai.
É o mesmo componente da Aula 4, reaproveitado.

### Entrada: onde a Bia aparece
A porta diz "vá para a fase X, entrada Y". A Transicao guarda o Y em
`Transicao.entrada`. Quando a fase nova abre, `fase.gd` procura `Entradas/Y` e põe a
Bia lá, virada para `olhando`. Sem entrada (F5 direto na fase), ela fica onde está no editor.

### A fase nova nasce do zero
Trocar de cena **apaga** a fase antiga e carrega a nova do arquivo. Então:

- **Itens pegos** voltariam a aparecer. Agora cada Interagivel tem uma chave única
  (`arquivo da fase/caminho do nó`) e, ao ser pego, faz `Historia.marcar(chave)`.
  No `_ready`, se a chave já existe, ele se apaga. A `Historia` é um autoload: não some.
- **A bateria** voltaria a 100%. A lanterna guarda o estado numa **`static var`**,
  que pertence ao script e não a uma lanterna. Ao sair (`_exit_tree`) ela guarda;
  a lanterna nova lê no `_ready`.
- **O diálogo do rádio** tocaria de novo. Agora a fase marca `"visto:<arquivo>"`.

---

## Passar por trás dos objetos (Y-Sort + Recortes)

O cenário é **uma imagem só**. Sem nada, a Bia é desenhada por cima de tudo: se ela
anda atrás da mesa, aparece "em cima" dela. A solução tem duas partes.

**1. Y-Sort** (`fase.gd` liga sozinho): `y_sort_enabled = true` faz o Godot desenhar
primeiro quem está mais **acima** na tela e por último quem está mais **abaixo**.
É assim que jogos vistos de cima mostram profundidade.

**2. Recortes**: um **Polygon2D** que contorna um objeto alto e mostra **os mesmos
pixels do fundo** naquele lugar. O recorte "está" na linha **Base** (onde o objeto
toca o chão):

```
   Bia acima da base  → recorte desenhado DEPOIS → cobre as pernas dela (atrás da mesa)
   Bia abaixo da base → Bia desenhada DEPOIS     → ela fica na frente
```

Na `sala_professores.tscn` já existem 5 (mesa, sofá, planta, mesinha, cadeira) e na
`porta_escada.tscn` mais 5. Teste: ande atrás da mesa de reunião.

### Como fazer um recorte (para os mapas novos)
1. Na fase, crie um **Node2D** chamado `Recortes` (se ainda não existir) e, no Inspector,
   ligue **Ordering → Y Sort Enabled**.
2. Botão direito em `Recortes` → Add Child Node → procure **Recorte**.
3. Com ele selecionado, aparecem ferramentas de polígono no topo da tela.
   Clique em volta do objeto (4 cliques para uma mesa) e clique no primeiro ponto
   para fechar. A imagem do objeto aparece por cima dele mesmo, igualzinha.
4. No Inspector, **Base**: o y da linha onde o objeto encosta no chão (a borda de
   baixo da colisão dele em `Moveis` é um bom valor). Aparece uma linha vermelha ali.

**Contorne o objeto, não um retângulo em volta dele.** Tudo que estiver dentro do
polígono cobre a Bia, inclusive pedaços de chão: se ela parar no vão entre duas
cadeiras e o vão estiver dentro do recorte, o "chão" fica por cima dela. Na mesa de
reunião o contorno sobe e desce em cada cadeira por isso.

**Portas na parede de baixo** (como a da sala dos professores): a Bia não pode pisar
em cima do desenho da porta. A colisão `Porta` em `Paredes` cobre a porta inteira e o
E fica logo acima dela.

**Só objetos em que a Bia pode ficar atrás** precisam de recorte: mesas, plantas,
estantes no meio da sala, árvores do pátio. Coisas encostadas na parede não precisam.

---

## Exercícios
1. Na sala dos professores, mude o texto do `Caderno`. Depois deixe a Cafeteira com
   **So Uma Vez** ligado: saia e volte. Ela continua sem o E?
2. Destranque a escada: desligue **Trancada** e aponte para `porta_escada.tscn`,
   entrada `corredor`. Agora existem dois caminhos para o mesmo lugar.
3. Mude `DURACAO` em `transicao.gd` para `1.0`. Fica mais tenso ou só mais lento?
4. No corredor, faça um recorte no **banco azul** (Base ≈ `268`) e ande atrás dele.
5. Desafio: na `porta_escada.tscn`, a `PortaZelador` está trancada. Crie uma fase
   `zeladoria.tscn` (copie a sala dos professores com Ctrl+D no FileSystem) e ligue as duas.

---
---

# Parte 2 — Menu inicial e ponto seguro (save)

**Arquivos novos**

```
scripts/sistemas/save.gd        autoload: salvar, carregar, novo jogo (um save só)
scripts/objetos/ponto_seguro.gd o caderno que salva (um Interagivel)
scripts/ui/menu.gd              o menu em cima da capa do grupo
cenas/ui/menu.tscn              a cena do menu (só um Control com o script)
```

**Mudaram:** `scripts/sistemas/transicao.gd` (guarda a posição do save) e
`scripts/fases/fase.gd` (põe a Bia no ponto salvo).

> Não vêm no zip: `project.godot` e `sala_professores.tscn` (os seus, com o que você mudou).
> Os ajustes neles você faz na mão, nos Passos 2 a 4.

## Passo 1 — Extrair o zip
Godot fechado, **Extrair tudo...** na pasta do projeto, **substituir**.

## Passo 2 — Autoload novo

| Path | Node Name |
|---|---|
| `res://scripts/sistemas/save.gd` | `Save` |

Fica com 8, e o `Save` tem que vir **depois** do `Transicao` (ele usa os outros).
**Project → Reload Current Project**.

## Passo 3 — O jogo começa pelo menu
**Project → Project Settings → Application → Run → Main Scene**: clique na pastinha e
escolha `res://cenas/ui/menu.tscn`.

## Passo 4 — O caderno vira ponto seguro
1. Abra `sala_professores.tscn` e selecione `Interagiveis/Caderno`.
2. No Inspector, lá embaixo, em **Script**, clique na setinha → **Load** → `res://scripts/objetos/ponto_seguro.gd`.
3. Os campos que já estavam (Texto, Altura Do Aviso...) continuam, e aparece um novo: **Pergunta**.
4. Ctrl+S.

## Passo 5 — Testar
F5 (agora abre o menu):

| Faça | O que acontece |
|---|---|
| **Jogar** sem save | começa o jogo no corredor |
| Pegue o power bank, vá à sala dos professores, **E** no caderno, "Salvar o progresso" | "Progresso salvo.", o Medo zera |
| Feche o jogo, abra de novo, **Jogar** | aparece **Continuar / Novo jogo** com a data do save |
| **Continuar** | volta na sala, no lugar onde salvou, com o power bank e a bateria de antes |
| **Opções** | volume e tela cheia (ficam guardados para a próxima vez) |

Teclado: ↑ ↓ escolhem, **E**/Enter confirma, **Esc** volta. O mouse também funciona.

---

## Como funciona

### O que vai para o save
`Save.salvar()` junta o estado de cada autoload num **dicionário** e grava como JSON:

```json
{
  "fase": "res://cenas/fases/sala_professores.tscn",
  "posicao": [600, 450],
  "historia": { "empatia": 2, "flags": { "usado:...PowerBank": true }, "escolhas": [] },
  "inventario": { "ordem": ["power_bank"], "quantidades": { "power_bank": 1 } },
  "lanterna": { "bateria": 37, "ligada": true },
  "medo": 0,
  "celular": { "conversas": [...], "notas": [...] }
}
```

O arquivo fica em `user://save.json`. No Windows: `%APPDATA%\Godot\app_userdata\The Blonde\`.
Dá para abrir no bloco de notas e ver o que foi salvo (bom para a apresentação).
Para "zerar" e testar do começo, apague esse arquivo.

### O inventário no save (Comp 8)
A tabela hash não vai para o arquivo como tabela: `Inventory.to_dict()` (código de vocês)
transforma em uma lista com a ordem dos itens e as quantidades. Ao carregar,
`from_dict()` coloca cada item de volta com `put()`, e a função hash decide de novo
em que balde cada um cai. Os baldes podem mudar se a capacidade for outra, o
conteúdo não.

### Carregar = voltar cada parte para o seu lugar
`Save.carregar()` faz o caminho inverso: cada autoload recebe a sua parte. A lanterna
é destruída a cada troca de fase, por isso a bateria vai para a `static var guardada`
(Parte 1) e a lanterna nova lê dali. A posição vai para `Transicao.posicao`, que o
`fase.gd` usa no lugar da Entrada.

**Detalhe do JSON:** ele não guarda tipos. Todo número volta como decimal (por isso
`int(...)` na Empatia) e toda lista volta sem tipo (por isso `.assign(...)` nas listas
tipadas, como `Array[String]`).

### O ponto seguro reaproveita o diálogo
`ponto_seguro.gd` herda do `Interagivel` (como a Porta) e monta um grafo de diálogo
pequeno no código: um nó de **escolha** com "Salvar" e "Agora não". Ele escuta o sinal
`Dialogo.escolheu` e, se a resposta for "Salvar", chama `Save.salvar()`. Como isso não
é uma escolha da história, ele tira o registro do relatório "Escolhas que importaram".

### O menu em cima da capa
A capa já tem "Jogar" e "Opções" desenhados. Os botões do `menu.gd` são **invisíveis**,
do tamanho dessas palavras (`AREA_JOGAR`, `AREA_OPCOES`). Quando um deles está
selecionado, aparecem uma seta e um brilho. Se a capa mudar, ajuste só essas duas
constantes.

---

## Exercícios
1. Abra o `save.json` no bloco de notas depois de salvar. Ache a Empatia e as flags.
2. Mude a `pergunta` do Caderno no Inspector para algo com a voz da Bia.
3. Em `menu.gd`, troque `PRIMEIRA_FASE` para `sala_professores.tscn`. O "Novo jogo"
   começa onde? (Depois volte para o corredor.)
4. Desafio: crie um segundo ponto seguro (copie o Caderno com Ctrl+D) em outra fase.

---
---

# Parte 3 — A primeira memória (1998)

Cena 1.3 do roteiro: Bia toca no papel velho do quadro de avisos, a luz esquenta, o som
abafa, e o jogador passa a controlar a **Marina** chegando ao campus em 1998. Ela anda
devagar e não corre. Ao ler o papel "LOIRINHA", a lembrança acaba e a Bia volta ao
corredor, no mesmo lugar, e o rádio do Raimundo explica o que aconteceu.

| Requisito do GDD | Onde está |
|---|---|
| CG 8 — filtro quente por matriz de cor | `shaders/memoria.gdshader` |
| CG 8 — transição por interpolação | `memoria.gd`, `_interpolar()` (tween da `forca` do shader) |

**Arquivos novos**

```
scripts/sistemas/memoria.gd             autoload: entra e sai das memórias
shaders/memoria.gdshader                o filtro quente (matriz de cor) e as bordas
cenas/memorias/memoria_1.tscn           o campus em 1998, já montado
dados/dialogos/memoria_1_*.json         as falas da Marina e a volta (5 arquivos)
assets/retratos/marina.png              retrato da Marina
```

**Mudaram:** `caixa_dialogo.gd` (efeitos `memoria`, `sair_memoria` e `fragmento`),
`fase.gd` (opção **Como Marina**) e `bia.gd` (`virar_marina()`).

## Passos
1. Godot fechado, extraia o zip na pasta do projeto (substituir).
2. Autoload novo, **depois** do `Save`:

   | Path | Node Name |
   |---|---|
   | `res://scripts/sistemas/memoria.gd` | `Memoria` |

3. Reload Current Project.
4. **Ligar o quadro de avisos à memória.** Abra `dados/dialogos/cap1_quadro.json`.
   No nó `"papel3"`, dentro de `"efeitos"`, acrescente a última linha (atenção à vírgula
   no fim da linha de cima):
   ```json
   "efeitos": {
     "flag": "viu_quadro_1998",
     "medo": 5,
     "nota": "Trote solidário: quinta, meia-noite.",
     "memoria": "res://cenas/memorias/memoria_1.tscn"
   },
   ```
5. F5 → Novo jogo → E no quadro de avisos do corredor.

| Na memória | O que acontece |
|---|---|
| Ao chegar | A Marina desce do ônibus: "Mãe, cheguei." (fragmento F01) |
| E no quadro do Bloco D | Ela lê o cartaz do trote |
| E na porta de vidro | O reflexo do cabelo pintado (F02) |
| E no papel "LOIRINHA" | Risadas, ela finge que não viu (F03) → volta para 2026 |

Na volta, a cor quente "escorre" de volta para o azul, e o rádio fala com a Bia.
A memória acontece **uma vez só**: ler o quadro de novo não repete.

---

## Como funciona

### A matriz de cor (CG 8)
Cada pixel tem uma cor (R, G, B). Uma **matriz 3×3** diz quanto de cada canal antigo
entra em cada canal novo. A matriz sépia, a cor de foto antiga, é:

```
R' = 0.393 R + 0.769 G + 0.189 B
G' = 0.349 R + 0.686 G + 0.168 B
B' = 0.272 R + 0.534 G + 0.131 B
```

O vermelho novo recebe muito do verde e do vermelho antigos, e o azul novo recebe pouco
de tudo: a imagem fica amarelada. No shader é uma multiplicação só: `SEPIA * cor`.
Cuidado: no GLSL a `mat3` é escrita **por colunas**, por isso os números aparecem
"deitados" no código.

### A transição por interpolação
`forca` vai de 0 (presente) a 1 (memória), e o shader mistura as duas cores:
`mix(cor, quente, forca)`. O `memoria.gd` anima esse número com um tween:

```gdscript
tween.tween_property(_filtro.material, "shader_parameter/forca", 1.0, 1.2)
```

Em 1,2 segundo a `forca` passa por todos os valores entre 0 e 1 (interpolação,
suavizada com `TRANS_SINE`), e a tela esquenta aos poucos, ainda no corredor. Depois
a Transicao escurece e abre a fase de 1998 com a `forca` em 1. Na volta, o tween leva
de 1 até 0 em 1,6 segundo.

### As bordas da lembrança
Quanto mais longe do centro (`length(SCREEN_UV - 0.5)`), mais o pixel é misturado com
os 4 vizinhos (borrão) e puxado para o marrom. O `smoothstep` faz essa borda começar
suave.

### O som abafado
`memoria.gd` coloca um filtro **passa-baixa** (`AudioEffectLowPassFilter`, corte em
900 Hz) no bus Master: os agudos somem e tudo parece vir de longe. Ao sair, ele tira.

### A Marina usa o corpo da Bia
A fase de memória tem **Como Marina** ligado no Inspector. O `fase.gd` chama
`bia.virar_marina()`, que troca a spritesheet, deixa a velocidade em 45 (sem correr) e
remove a lanterna. Sem lanterna, o Medo fica parado e o celular não abre. A bateria
fica guardada na `static var` da lanterna e volta igual.

### Voltar para o lugar certo
Ao entrar, o `memoria.gd` guarda a fase e a posição da Bia. Ao sair, usa a mesma
`Transicao.posicao` do save (Parte 2): a Bia reaparece exatamente onde estava.

### Fragmentos para o mural (Aula 8)
`"efeitos": {"fragmento": "F01"}` marca a flag `fragmento:F01`. O mural de pistas vai
mostrar como cartão cada fragmento que a Bia já viu.

---

## Exercícios
1. Em `memoria.gdshader`, troque `forca * 0.85` por `forca * 1.0`. E por `0.5`?
2. Mude `cutoff_hz` em `memoria.gd` para `400`. O som parece mais longe?
3. Em `memoria_1.tscn`, mude a cor do `Escuridao` (CanvasModulate) para um laranja mais
   forte: vira pôr do sol?
4. Desafio: crie uma matriz sua no shader, por exemplo uma "azulada" para um pesadelo
   (dica: aumente os números da linha do B').
