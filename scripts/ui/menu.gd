extends Control
## MENU INICIAL — a primeira tela do jogo, em cima da capa que o grupo desenhou.
## A capa já tem "Jogar" e "Opções" escritos: os botões aqui são invisíveis, do
## tamanho dessas palavras, e só mostram uma seta e um brilho quando selecionados.
##
##   Jogar  → sem save: começa um jogo novo
##            com save: pergunta "Continuar" ou "Novo jogo"
##   Opções → volume e tela cheia (guardados em user://opcoes.cfg)
##   Sair   → fecha o jogo
##
## Teclado: ↑ ↓ escolhem, E/Enter confirma, Esc volta. O mouse também funciona.

const PRIMEIRA_FASE := "res://cenas/fases/teste_corredor.tscn"   # troque pelo prólogo depois
const CAPA := preload("res://assets/menu/capa.jpg")
const MUSICA := preload("res://assets/audio/musica/01_musica_menu.ogg")
const FONTE := preload("res://assets/fonts/fonte_dialogo.tres")
const FONTE_PEQUENA := preload("res://assets/fonts/Silkscreen-Regular.ttf")
const SOM_MOVER := preload("res://assets/audio/sfx/30_menu_mover.wav")
const SOM_OK := preload("res://assets/audio/sfx/31_menu_confirmar.wav")
const OPCOES := "user://opcoes.cfg"

## Onde ficam as palavras desenhadas na capa, na tela de 640 x 360
## (ajuste aqui se a capa mudar). Rect2(x, y, largura, altura).
const AREA_JOGAR := Rect2(282, 222, 84, 26)
const AREA_OPCOES := Rect2(293, 274, 64, 20)

var _jogar: Button
var _opcoes: Button
var _sair: Button
var _painel_jogar: PanelContainer
var _painel_opcoes: PanelContainer
var _continuar: Button
var _info_save: Label
var _volume: HSlider
var _tela_cheia: CheckButton
var _seta: Label
var _brilho: ColorRect
var _som: AudioStreamPlayer


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	_carregar_opcoes()
	_montar_tela()
	var musica := AudioStreamPlayer.new()
	musica.stream = MUSICA
	musica.bus = &"Music"
	musica.autoplay = true
	musica.finished.connect(musica.play)   # repete
	add_child(musica)
	_som = AudioStreamPlayer.new()
	_som.bus = &"SFX"
	add_child(_som)
	_jogar.grab_focus()


func _process(_delta: float) -> void:
	# Seta e brilho acompanham o botão de baixo do mouse ou do teclado.
	var foco := get_viewport().gui_get_focus_owner()
	var visivel := foco == _jogar or foco == _opcoes or foco == _sair
	_seta.visible = visivel
	_brilho.visible = visivel and foco != _sair
	if visivel:
		var r := foco.get_global_rect()
		var balanco := sin(Time.get_ticks_msec() / 180.0) * 2.0
		_seta.position = Vector2(r.position.x - 16 + balanco, r.position.y + r.size.y / 2 - 9)
		_brilho.position = r.position - Vector2(6, 2)
		_brilho.size = r.size + Vector2(12, 4)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and (_painel_jogar.visible or _painel_opcoes.visible):
		_fechar_paineis()
		get_viewport().set_input_as_handled()


# ─────────────────────────────────────────────────────────────
# AÇÕES
# ─────────────────────────────────────────────────────────────
func _ao_jogar() -> void:
	_tocar(SOM_OK)
	if not Save.existe():
		_novo_jogo()
		return
	_info_save.text = "Salvo em " + _data_do_save()
	_abrir_painel(_painel_jogar)
	_continuar.grab_focus()


func _continuar_jogo() -> void:
	_tocar(SOM_OK)
	if not Save.carregar():
		_info_save.text = "Não deu para abrir o save."


func _novo_jogo() -> void:
	_tocar(SOM_OK)
	Save.novo_jogo(PRIMEIRA_FASE)


func _ao_opcoes() -> void:
	_tocar(SOM_OK)
	_abrir_painel(_painel_opcoes)
	_volume.grab_focus()


func _abrir_painel(painel: PanelContainer) -> void:
	_jogar.disabled = true
	_opcoes.disabled = true
	_sair.disabled = true
	painel.show()


func _fechar_paineis() -> void:
	_painel_jogar.hide()
	_painel_opcoes.hide()
	_jogar.disabled = false
	_opcoes.disabled = false
	_sair.disabled = false
	_salvar_opcoes()
	_jogar.grab_focus()


## Lê só a data de dentro do save, sem carregar o jogo.
func _data_do_save() -> String:
	var arquivo := FileAccess.open(Save.CAMINHO, FileAccess.READ)
	var dados = JSON.parse_string(arquivo.get_as_text()) if arquivo else null
	if typeof(dados) != TYPE_DICTIONARY:
		return "?"
	var d: String = dados.get("data", "")           # "2026-11-18 15:40:12"
	if d.length() < 16:
		return d
	return "%s/%s às %s" % [d.substr(8, 2), d.substr(5, 2), d.substr(11, 5)]


# ─────────────────────────────────────────────────────────────
# OPÇÕES (volume em decibéis: linear_to_db converte 0..1 para dB)
# ─────────────────────────────────────────────────────────────
var _cfg_volume := 0.8
var _cfg_tela_cheia := false


func _carregar_opcoes() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(OPCOES) == OK:
		_cfg_volume = cfg.get_value("audio", "volume", 0.8)
		_cfg_tela_cheia = cfg.get_value("video", "tela_cheia", false)
	_aplicar_volume(_cfg_volume)
	_aplicar_tela_cheia(_cfg_tela_cheia)


func _salvar_opcoes() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "volume", _volume.value)
	cfg.set_value("video", "tela_cheia", _tela_cheia.button_pressed)
	cfg.save(OPCOES)


func _aplicar_volume(v: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(v, 0.0001)))   # bus 0 = Master


func _aplicar_tela_cheia(ligada: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if ligada else DisplayServer.WINDOW_MODE_WINDOWED)


# ─────────────────────────────────────────────────────────────
# MONTAR A TELA (tudo por código, como o celular da Aula 4)
# ─────────────────────────────────────────────────────────────
func _montar_tela() -> void:
	var capa := TextureRect.new()
	capa.texture = CAPA
	capa.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	capa.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED   # cobre a tela, corta as sobras
	capa.set_anchors_preset(PRESET_FULL_RECT)
	add_child(capa)

	_brilho = ColorRect.new()
	_brilho.color = Color(1, 0.85, 0.85, 0.18)
	_brilho.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_brilho)

	_seta = _label("›", FONTE, 20, Vector2.ZERO)
	_seta.add_theme_color_override("font_color", Color(1, 0.9, 0.9))
	_seta.add_theme_color_override("font_outline_color", Color(0.4, 0, 0))
	_seta.add_theme_constant_override("outline_size", 4)

	_jogar = _botao_invisivel(AREA_JOGAR, _ao_jogar)
	_opcoes = _botao_invisivel(AREA_OPCOES, _ao_opcoes)

	_sair = Button.new()
	_sair.text = "Sair"
	_sair.flat = true
	_sair.add_theme_font_override("font", FONTE_PEQUENA)
	_sair.add_theme_font_size_override("font_size", 8)
	_sair.add_theme_color_override("font_color", Color(0.75, 0.72, 0.8))
	_sair.add_theme_color_override("font_focus_color", Color.WHITE)
	_sair.add_theme_color_override("font_hover_color", Color.WHITE)
	_sair.position = Vector2(596, 336)
	_sair.pressed.connect(get_tree().quit)
	_sair.focus_entered.connect(_tocar.bind(SOM_MOVER))
	add_child(_sair)

	# Ordem do teclado: Jogar ↓ Opções ↓ Sair ↓ (volta) Jogar
	_ligar_foco([_jogar, _opcoes, _sair])

	# Painel "Jogar" (só quando existe save)
	_painel_jogar = _painel(Vector2(250, 214), Vector2(140, 0))
	var caixa := _painel_jogar.get_child(0)
	_continuar = _botao_texto("Continuar", _continuar_jogo, caixa)
	var novo := _botao_texto("Novo jogo", _novo_jogo, caixa)
	_info_save = _label("", FONTE_PEQUENA, 8, Vector2.ZERO)
	remove_child(_info_save)
	_info_save.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info_save.add_theme_color_override("font_color", Color(0.7, 0.68, 0.78))
	caixa.add_child(_info_save)
	var voltar1 := _botao_texto("Voltar", _fechar_paineis, caixa)
	_ligar_foco([_continuar, novo, voltar1])

	# Painel "Opções"
	_painel_opcoes = _painel(Vector2(235, 200), Vector2(170, 0))
	caixa = _painel_opcoes.get_child(0)
	var rotulo := _label("Volume", FONTE, 16, Vector2.ZERO)
	remove_child(rotulo)
	caixa.add_child(rotulo)
	_volume = HSlider.new()
	_volume.min_value = 0.0
	_volume.max_value = 1.0
	_volume.step = 0.05
	_volume.value = _cfg_volume
	_volume.custom_minimum_size = Vector2(150, 16)
	_volume.value_changed.connect(_aplicar_volume)
	caixa.add_child(_volume)
	_tela_cheia = CheckButton.new()
	_tela_cheia.text = "Tela cheia"
	_tela_cheia.add_theme_font_override("font", FONTE)
	_tela_cheia.button_pressed = _cfg_tela_cheia
	_tela_cheia.toggled.connect(_aplicar_tela_cheia)
	caixa.add_child(_tela_cheia)
	var voltar2 := _botao_texto("Voltar", _fechar_paineis, caixa)
	_ligar_foco([_volume, _tela_cheia, voltar2])


func _botao_invisivel(area: Rect2, acao: Callable) -> Button:
	var b := Button.new()
	b.flat = true
	b.position = area.position
	b.size = area.size
	var vazio := StyleBoxEmpty.new()
	for estado in ["normal", "hover", "pressed", "focus", "disabled"]:
		b.add_theme_stylebox_override(estado, vazio)
	b.pressed.connect(acao)
	b.mouse_entered.connect(b.grab_focus)          # o mouse também seleciona
	b.focus_entered.connect(_tocar.bind(SOM_MOVER))
	add_child(b)
	return b


func _botao_texto(texto: String, acao: Callable, pai: Node) -> Button:
	var b := Button.new()
	b.text = texto
	b.add_theme_font_override("font", FONTE)
	b.add_theme_font_size_override("font_size", 16)
	b.pressed.connect(acao)
	b.mouse_entered.connect(b.grab_focus)
	b.focus_entered.connect(_tocar.bind(SOM_MOVER))
	pai.add_child(b)
	return b


func _painel(pos: Vector2, tamanho: Vector2) -> PanelContainer:
	var p := PanelContainer.new()
	p.position = pos
	p.custom_minimum_size = tamanho
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.06, 0.03, 0.06, 0.94)
	estilo.border_color = Color(0.55, 0.05, 0.08)
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(3)
	estilo.set_content_margin_all(8)
	p.add_theme_stylebox_override("panel", estilo)
	var caixa := VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 4)
	p.add_child(caixa)
	p.hide()
	add_child(p)
	return p


func _label(texto: String, fonte: Font, tamanho: int, pos: Vector2) -> Label:
	var l := Label.new()
	l.text = texto
	l.position = pos
	l.add_theme_font_override("font", fonte)
	l.add_theme_font_size_override("font_size", tamanho)
	l.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(l)
	return l


## Liga ↑ ↓ entre os controles da lista, em volta (o último desce para o primeiro).
func _ligar_foco(lista: Array) -> void:
	for i in lista.size():
		var c: Control = lista[i]
		c.focus_neighbor_bottom = c.get_path_to(lista[(i + 1) % lista.size()])
		c.focus_neighbor_top = c.get_path_to(lista[i - 1])


func _tocar(som: AudioStream) -> void:
	if _som:
		_som.stream = som
		_som.play()
