extends CanvasLayer
## TRANSIÇÃO — autoload. Troca de fase com a tela escurecendo e clareando.
##
##   Transicao.ir_para("res://cenas/fases/sala_professores.tscn", "porta")
##
## O segundo valor é o nome da ENTRADA (um nó dentro de "Entradas" na fase nova)
## onde a Bia vai aparecer. A fase lê Transicao.entrada no _ready (fase.gd).

const DURACAO := 0.35   # segundos para escurecer (e o mesmo para clarear)

var entrada := ""       # onde a Bia aparece na próxima fase
# Aula 5 Parte 2 — ao carregar um save, a Bia volta para o ponto exato onde salvou.
var posicao := Vector2.INF   # INF = "não usar" (vale a entrada)
var olhando := Vector2.DOWN
var ocupado := false    # já está trocando? (evita trocar duas vezes)

var _tela: ColorRect


func _ready() -> void:
	layer = 20                                 # por cima de tudo, até do celular
	process_mode = Node.PROCESS_MODE_ALWAYS    # funciona com o jogo pausado

	_tela = ColorRect.new()
	_tela.color = Color.BLACK
	_tela.modulate.a = 0.0                     # começa transparente
	_tela.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tela.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tela)


func ir_para(cena: String, nome_entrada := "") -> void:
	if ocupado:
		return
	ocupado = true
	entrada = nome_entrada
	get_tree().paused = true        # ninguém anda nem gasta bateria no escuro

	await _escurecer(1.0)           # 1) tela preta
	get_tree().change_scene_to_file(cena)   # 2) troca a fase
	await get_tree().scene_changed  # espera a fase nova estar na árvore
	get_tree().paused = false
	await _escurecer(0.0)           # 3) clareia
	ocupado = false


## Tween: anima a transparência da tela preta até "alvo" (0 = some, 1 = preta).
func _escurecer(alvo: float) -> void:
	var tween := create_tween()
	tween.tween_property(_tela, "modulate:a", alvo, DURACAO)
	await tween.finished
