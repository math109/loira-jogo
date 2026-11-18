extends CanvasLayer
## MEMÓRIA — autoload. Leva a Bia para dentro de uma lembrança de 1998 e traz de volta.
##
##   Memoria.entrar("res://cenas/memorias/memoria_1.tscn")
##   Memoria.sair("res://dados/dialogos/memoria_1_volta.json")   # diálogo ao voltar (opcional)
##
## Nos diálogos (.json) dá para usar como efeito:
##   "efeitos": { "memoria": "res://cenas/memorias/memoria_1.tscn" }
##   "efeitos": { "sair_memoria": "res://dados/dialogos/memoria_1_volta.json" }
## Se um diálogo estiver aberto, a memória espera ele terminar.
##
## O que muda na memória: a tela esquenta (shader com matriz de cor, CG 8),
## o som fica abafado (filtro passa-baixa) e o jogador controla a Marina.

const SHADER := preload("res://shaders/memoria.gdshader")
const DURACAO_ENTRAR := 1.2   # segundos para a luz esquentar
const DURACAO_SAIR := 1.6     # segundos para "a luz quente escorrer para o azul"

var ativa := false
var _volta := {}               # para onde voltar: fase, posição e direção da Bia
var _filtro: ColorRect
var _abafado := AudioEffectLowPassFilter.new()


func _ready() -> void:
	layer = 4                                # acima do jogo e do HUD, abaixo do diálogo (5)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_filtro = ColorRect.new()
	_filtro.set_anchors_preset(Control.PRESET_FULL_RECT)
	_filtro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_filtro.material = ShaderMaterial.new()
	_filtro.material.shader = SHADER
	_filtro.material.set_shader_parameter("forca", 0.0)   # o tween só anima o que já existe
	_filtro.hide()
	add_child(_filtro)
	_abafado.cutoff_hz = 900.0              # corta os agudos: som "de longe"


func entrar(cena: String) -> void:
	if ativa:
		return
	# Cada memória acontece uma vez só (ler o quadro de novo não repete).
	var chave := "memoria:" + cena
	if Historia.tem(chave):
		return
	Historia.marcar(chave)
	if Dialogo.ativo:
		await Dialogo.terminou
	ativa = true
	var fase := get_tree().current_scene
	var bia := fase.get_node_or_null("Bia")
	_volta = {
		"fase": fase.scene_file_path,
		"posicao": bia.global_position if bia else Vector2.INF,
		"olhando": bia.direcao if bia else Vector2.DOWN,
	}
	_som_abafado(true)
	await _interpolar(1.0, DURACAO_ENTRAR)  # ainda no presente: a luz esquenta
	Transicao.ir_para(cena)                 # e a tela escurece para a lembrança


func sair(dialogo_ao_voltar := "") -> void:
	if not ativa:
		return
	if Dialogo.ativo:
		await Dialogo.terminou
	Transicao.posicao = _volta.posicao      # a Bia volta exatamente onde estava
	Transicao.olhando = _volta.olhando
	await Transicao.ir_para(_volta.fase)
	_som_abafado(false)
	await _interpolar(0.0, DURACAO_SAIR)
	ativa = false
	if dialogo_ao_voltar != "":
		Dialogo.iniciar(dialogo_ao_voltar)


## Interpolação: o tween leva a "forca" do shader do valor atual até "alvo".
func _interpolar(alvo: float, duracao: float) -> void:
	_filtro.show()
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(_filtro.material, "shader_parameter/forca", alvo, duracao)
	await tween.finished
	if alvo == 0.0:
		_filtro.hide()                      # sem filtro, nem desenha


## Liga/desliga o filtro passa-baixa no bus Master (0): tudo soa abafado.
func _som_abafado(ligar: bool) -> void:
	var tem := false
	for i in AudioServer.get_bus_effect_count(0):
		if AudioServer.get_bus_effect(0, i) == _abafado:
			tem = true
			if not ligar:
				AudioServer.remove_bus_effect(0, i)
			break
	if ligar and not tem:
		AudioServer.add_bus_effect(0, _abafado)
