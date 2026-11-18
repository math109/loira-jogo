extends Node2D
## Script de uma fase (um mapa do jogo).
## Aula 1: prende a câmera dentro do cenário e deixa os sons de ambiente em loop.
## Aula 2: os móveis fazem sombra na luz da lanterna.
## Aula 3: pode abrir um diálogo assim que a fase começa.
## Aula 5: a Bia aparece na Entrada certa quando chega por uma porta,
##         e passa por trás dos objetos (Y-Sort + Recortes).

## Sombras projetadas pelos móveis na luz da lanterna (CG 3). Desligado por padrão;
## ligue no Inspector da fase para mostrar na apresentação.
@export var sombras_dos_moveis := false

## Aula 5 Parte 3 — numa memória de 1998 o jogador controla a Marina.
@export var como_marina := false

## Diálogo que começa sozinho quando a fase abre (deixe vazio para nenhum).
@export_file("*.json") var dialogo_ao_entrar := ""

@onready var fundo: Sprite2D = $Fundo
@onready var bia: CharacterBody2D = $Bia


func _ready() -> void:
	# Profundidade: quem está mais embaixo na tela é desenhado por cima.
	# A Bia e os Recortes entram nessa ordem; o fundo fica sempre atrás.
	y_sort_enabled = true
	fundo.z_index = -1
	if como_marina:
		bia.virar_marina()
	_posicionar_bia()
	_limitar_camera()
	_repetir_sons_de_ambiente()
	if sombras_dos_moveis:
		_criar_sombras()
	# O diálogo de entrada só toca na PRIMEIRA vez (voltar ao corredor não repete).
	var chave := "visto:" + dialogo_ao_entrar
	if dialogo_ao_entrar != "" and not Historia.tem(chave):
		Historia.marcar(chave)
		Dialogo.iniciar(dialogo_ao_entrar)


## Se viemos por uma porta, Transicao.entrada diz o nome da Entrada.
## Sem ela (F5 direto na fase), a Bia fica onde foi colocada no editor.
func _posicionar_bia() -> void:
	if Transicao.posicao != Vector2.INF:   # veio de um save: o ponto exato
		_colocar_bia(Transicao.posicao, Transicao.olhando)
		Transicao.posicao = Vector2.INF
		Transicao.entrada = ""
		return
	if Transicao.entrada == "":
		return
	var entrada := get_node_or_null("Entradas/" + Transicao.entrada)
	Transicao.entrada = ""
	if entrada == null:
		push_warning("Esta fase não tem a entrada pedida pela porta.")
		return
	_colocar_bia(entrada.global_position, entrada.olhando)


func _colocar_bia(ponto: Vector2, olhando: Vector2) -> void:
	bia.global_position = ponto
	bia.olhar_para(olhando)
	bia.reset_physics_interpolation()   # não "desliza" do ponto antigo
	bia.get_node("Camera2D").reset_smoothing()


## A câmera segue a Bia, mas não pode mostrar nada fora da imagem de fundo.
func _limitar_camera() -> void:
	var camera: Camera2D = bia.get_node("Camera2D")
	var tamanho := fundo.texture.get_size()  # 960 x 640 nos nossos cenários
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(tamanho.x)
	camera.limit_bottom = int(tamanho.y)


## Todo nó no grupo "som_em_loop" volta a tocar quando termina.
func _repetir_sons_de_ambiente() -> void:
	for som in get_tree().get_nodes_in_group("som_em_loop"):
		som.finished.connect(som.play)


## CG 3 — SOMBRAS: cada colisão retangular dentro do nó "Moveis" ganha um
## LightOccluder2D. O occluder é um polígono que a luz não atravessa: o Godot
## projeta, a partir da luz, a "sombra" atrás dele.
## Usamos só uma faixa fina na borda de trás do móvel (ESPESSURA pixels):
## se o polígono cobrisse o móvel inteiro, o próprio móvel ficaria no escuro.
const ESPESSURA := 3.0


func _criar_sombras() -> void:
	var moveis := get_node_or_null("Moveis")
	if moveis == null:
		return  # fase sem móveis: nada a fazer
	for forma in moveis.get_children():
		if not (forma is CollisionShape2D and forma.shape is RectangleShape2D):
			continue
		var metade: Vector2 = forma.shape.size / 2.0
		# Os 4 cantos da faixa fina, na borda de cima (de trás) da colisão.
		var poligono := OccluderPolygon2D.new()
		poligono.polygon = PackedVector2Array([
			Vector2(-metade.x, -metade.y),
			Vector2(metade.x, -metade.y),
			Vector2(metade.x, -metade.y + ESPESSURA),
			Vector2(-metade.x, -metade.y + ESPESSURA),
		])
		var oclusor := LightOccluder2D.new()
		oclusor.name = "Sombra" + forma.name
		oclusor.occluder = poligono
		oclusor.position = forma.position
		moveis.add_child(oclusor)
