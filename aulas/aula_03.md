# Aula 3 — Diálogos e escolhas

**Objetivo:** a caixa de diálogo com retrato, efeito de máquina de escrever,
pensamentos da Bia e escolhas que mexem na Empatia (escondida do jogador).
Ao abrir o corredor, a cena 1.1 do roteiro acontece: a Bia acorda e o rádio fala com ela.

| Requisito do GDD | Onde está |
|---|---|
| Comp 5 — grafo de decisão | os arquivos `.json` em `dados/dialogos/` e o `caixa_dialogo.gd` |
| CG 7 — máscara de gradiente nos retratos | `shaders/retrato.gdshader` |

**Arquivos novos**

```
scripts/sistemas/historia.gd        Empatia, flags e registro das escolhas (autoload)
cenas/ui/caixa_dialogo.tscn         a caixa de diálogo (autoload de cena)
scripts/ui/caixa_dialogo.gd         o código que percorre o grafo
shaders/retrato.gdshader            o retrato que some aos poucos na base
dados/dialogos/cap1_corredor.json   cena 1.1 (Bia acorda, rádio)
dados/dialogos/prologo_portao.json  cena 0.2 com a ESCOLHA 1 (o trote)
assets/retratos/bia.png             retrato provisório da Bia
assets/retratos/raimundo_radio.png  o rádio (Raimundo não aparece, só a voz)
assets/fonts/PixelifySans.woff2     fonte pixel com minúsculas e acentos (licença OFL)
assets/fonts/fonte_dialogo.tres     a mesma fonte, sem as ligaduras ("fi" grudado)
```

---

## Passo 1 — Copiar tudo de uma vez

Para não faltar arquivo como na Aula 2: feche o Godot, clique com o botão direito no zip,
**Extrair tudo...**, e escolha a **pasta do projeto** (a que tem o `project.godot`).
Quando o Windows perguntar se quer substituir, diga **Sim para todos**.
As pastas do zip têm a mesma estrutura do projeto, então cada arquivo cai no lugar certo.

Abra o Godot de novo.

## Passo 2 — Dois autoloads novos

Em **Project → Project Settings → Globals → Autoload**, adicione:

| Path | Node Name |
|---|---|
| `res://scripts/sistemas/historia.gd` | `Historia` |
| `res://cenas/ui/caixa_dialogo.tscn` | `Dialogo` |

Repare que o segundo é uma **cena** (`.tscn`), não um script. Autoload pode ser uma cena
inteira: assim a caixa de diálogo existe sempre, por cima de qualquer fase,
e qualquer script pode chamar `Dialogo.iniciar(...)`.

## Passo 3 — Pequenas mudanças em 3 scripts

**`bia.gd`** — a Bia não anda durante a conversa. Logo depois da linha do `Input.get_vector(...)`:

```gdscript
	if Dialogo.ativo:
		entrada = Vector2.ZERO  # durante um diálogo a Bia fica parada
```

**`medo.gd`** — o Medo não sobe enquanto ela conversa. Troque:

```gdscript
	if lanterna == null:
		return  # tela sem a Bia (menu, diálogo...): o medo fica parado
```
por:
```gdscript
	if lanterna == null or Dialogo.ativo:
		return  # sem a Bia na tela, ou conversando: o medo fica parado
```

**`fase.gd`** — a fase pode abrir um diálogo sozinha. Acima de `@onready var fundo`:

```gdscript
## Diálogo que começa sozinho quando a fase abre (deixe vazio para nenhum).
@export_file("*.json") var dialogo_ao_entrar := ""
```

E no fim do `_ready()`:

```gdscript
	if dialogo_ao_entrar != "":
		Dialogo.iniciar(dialogo_ao_entrar)
```

(Se você extraiu o zip por cima, esses 3 arquivos já vieram mudados. Confira só se estão iguais.)

## Passo 4 — Ligar o diálogo no corredor

1. Abra `teste_corredor.tscn` e clique no nó **Corredor**.
2. No Inspector aparece **Dialogo Ao Entrar**. Clique na pastinha e escolha
   `res://dados/dialogos/cap1_corredor.json`.
3. F5. Aperte **E** (ou Enter) para avançar. Apertando durante a digitação, o texto aparece todo.

Para testar a **escolha**, troque o arquivo para `prologo_portao.json`.
Use as setas ↑ ↓ para escolher e **E** para confirmar.

---

## Como funciona

### O diálogo é um grafo (Comp 5)

Abra `prologo_portao.json`. Ele tem duas partes:

```json
"personagens": {
  "BIA": { "nome": "Bia", "retrato": "res://assets/retratos/bia.png", "cor": "#e8dcff" }
},
"nos": {
  "inicio": { "quem": "VETERANO", "texto": "Calouro só vira gente...", "proximo": "v2" },
  "v2":     { "quem": "VETERANA", "texto": "Vocês conhecem a Loira...", "proximo": "theo" },
  ...
  "escolha_trote": {
    "quem": "BIA", "tipo": "escolha", "id_escolha": "trote", "texto": "O que eu digo?",
    "opcoes": [
      { "texto": "\"Não precisa. Vamos embora.\"", "empatia": 1,  "proximo": "r_embora" },
      { "texto": "\"Vamos de uma vez...\"",        "empatia": 0,  "proximo": "r_rapido" },
      { "texto": "\"Se for só pra rir, eu filmo.\"", "empatia": -1,
        "efeitos": { "flag": "filmou_trote" }, "proximo": "r_filmo" }
    ]
  }
}
```

- Cada entrada de `"nos"` é um **vértice** do grafo, com um id (`"inicio"`, `"v2"`...).
- `"proximo"` é uma **aresta** para outro vértice. `"fim"` encerra.
- Um nó de **escolha** tem várias arestas (as opções). O jogador escolhe qual seguir.
- Cada aresta pode ter **peso** (`"empatia"`), **efeito** (`"efeitos"`: marca uma flag
  ou aumenta o Medo) e **condição** (`"se"`), por exemplo:

  ```json
  { "texto": "Eu confio em você.", "se": { "empatia_min": 3 }, "proximo": "..." }
  { "texto": "Eu vou sozinha.",   "se": { "medo_max": 60 },   "proximo": "..." }
  { "texto": "Davi, vem comigo.", "se": { "flag": "achou_davi" }, "proximo": "..." }
  ```

  A opção só aparece se a condição for verdadeira (`_condicao_ok`).

Ter o diálogo em `.json` separa o **texto** do **código**: o grupo escreve o roteiro
nos arquivos sem mexer em nenhum script.

### Validar o grafo (BFS)
Quando um diálogo abre, `_validar()` anda pelo grafo com uma **fila**, a partir de `"inicio"`
(busca em largura). Se um nó apontar para um id que não existe, ou se algum nó nunca for
alcançado, aparece um aviso amarelo no **Output**. Assim um erro de digitação no `.json`
não passa despercebido.

### Máquina de escrever
`texto.visible_characters` diz quantas letras aparecem. A cada quadro somamos
`45 × delta` (45 letras por segundo) e tocamos um "tic" a cada 2 letras,
com o tom (`pitch_scale`) sorteado um pouco para não ficar robótico.

### Empatia escondida
Ao escolher, `Historia.somar_empatia(...)` soma o peso da opção. O jogador nunca vê o número.
`Historia.registrar_escolha(...)` guarda o que foi escolhido para o relatório
"Escolhas que importaram" do final. `Historia.final()` já devolve `"bom"`, `"neutro"`
ou `"ruim"` com as faixas do roteiro.

### Retrato com máscara (CG 7)
`retrato.gdshader` multiplica a transparência do retrato por dois `smoothstep`:
um na vertical (some embaixo) e outro na horizontal (some na borda direita).
É uma conta por pixel usando a coordenada `UV` (0 a 1 dentro da imagem).
No pensamento, `escurecer = 0.6` deixa o retrato mais escuro.

### Pensamento × fala
`"tipo": "pensamento"` some com o nome, deixa o texto azulado e escurece o retrato.
É o "BIA (pensamento)" do roteiro.

---

## Exercícios

1. Em `cap1_corredor.json`, escreva errado um `"proximo"` (por exemplo `"radio9"`).
   Rode e veja o aviso no Output. Depois conserte.
2. Mude `LETRAS_POR_SEGUNDO` para `15` em `caixa_dialogo.gd`. Fica mais tenso?
3. No `prologo_portao.json`, acrescente uma 4ª opção que só aparece com Empatia ≥ 1:
   `{"texto": "\"Yasmin, você vem comigo?\"", "empatia": 1, "se": {"empatia_min": 1}, "proximo": "fim"}`.
   Ela não aparece na primeira vez (a Empatia começa em 0). Por quê?
4. Desafio: crie `dados/dialogos/teste.json` com uma conversa sua e ligue no corredor.

**Retratos:** o da Bia é provisório (a cabeça do sprite ampliada). Os retratos de verdade
da Bia, do Théo, da Yasmin, do Davi e da Marina eu gero no SpriteCook e é só trocar o
caminho em `"retrato"` nos `.json`.
