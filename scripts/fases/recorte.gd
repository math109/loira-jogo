@tool
class_name Recorte
extends Polygon2D
## Um pedaço do cenário que fica NA FRENTE da Bia quando ela passa por trás dele.
##
## O fundo é uma imagem só: a Bia sempre seria desenhada por cima de tudo.
## O Recorte é um polígono que contorna um objeto alto (mesa, planta, estante)
## e mostra exatamente os mesmos pixels do fundo naquele lugar. Com o Y-Sort
## ligado na fase, o Godot desenha primeiro quem está mais acima na tela:
##   • Bia acima da "base" (atrás do objeto) → o recorte cobre a Bia
##   • Bia abaixo da base (na frente)        → a Bia cobre o recorte
##
## Como usar: Add Child Node no nó "Recortes" → Recorte. Com ele selecionado,
## desenhe o contorno do objeto clicando em volta dele (ferramenta de polígono no
## topo da tela). Depois ajuste "Base" para a linha onde o objeto toca o chão.

## A linha (y, em pixels do cenário) onde o objeto encosta no chão.
@export var base := 0.0:
	set(valor):
		base = valor
		# O nó fica na altura da base (é por ela que o Y-Sort ordena)...
		position = Vector2(0.0, base)
		# ...mas o desenho volta para o lugar certo, em cima do fundo.
		offset = Vector2(0.0, -base)
		# A textura anda junto com o offset; isto a devolve para o lugar
		# certo, para os pixels do recorte baterem com os do fundo.
		texture_offset = Vector2(0.0, base)
		queue_redraw()


func _ready() -> void:
	base = base   # aplica position/offset
	var fundo := _achar_fundo()
	if fundo:
		texture = fundo.texture   # os mesmos pixels do cenário


func _achar_fundo() -> Sprite2D:
	var no: Node = self
	while no:
		if no.has_node("Fundo"):
			return no.get_node("Fundo")
		no = no.get_parent()
	return null


## Uma linha vermelha mostra a base no editor (não aparece no jogo).
func _draw() -> void:
	if Engine.is_editor_hint() and polygon.size() > 0:
		var xs := polygon.duplicate()
		var minx := 1e9
		var maxx := -1e9
		for p in xs:
			minx = minf(minx, p.x)
			maxx = maxf(maxx, p.x)
		draw_line(Vector2(minx, 0), Vector2(maxx, 0), Color.RED, 1.0)
