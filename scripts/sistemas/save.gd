extends Node
## SAVE — autoload. Guarda e carrega o jogo num arquivo só (um save).
##
##   Save.salvar()      → grava tudo em user://save.json
##   Save.existe()      → já tem save? (o menu usa para mostrar "Continuar")
##   Save.carregar()    → lê o arquivo e leva a Bia de volta para onde salvou
##   Save.novo_jogo()   → zera tudo para começar do início
##
## "user://" é uma pasta do Godot no computador de quem joga (no Windows fica em
## %APPDATA%\Godot\app_userdata\The Blonde). O arquivo é JSON: dá para abrir no
## bloco de notas e ver o que foi salvo.

const CAMINHO := "user://save.json"
const VERSAO := 1
const LANTERNA := preload("res://scripts/personagens/lanterna.gd")


func existe() -> bool:
	return FileAccess.file_exists(CAMINHO)


## Junta o estado de cada autoload num dicionário e grava como JSON.
func salvar() -> void:
	var fase := get_tree().current_scene
	var bia := fase.get_node_or_null("Bia")
	var lanterna := get_tree().get_first_node_in_group("lanterna")
	var dados := {
		"versao": VERSAO,
		"data": Time.get_datetime_string_from_system(false, true),
		"fase": fase.scene_file_path,
		"posicao": [bia.global_position.x, bia.global_position.y] if bia else null,
		"olhando": [bia.direcao.x, bia.direcao.y] if bia else [0, 1],
		"historia": {
			"empatia": Historia.empatia,
			"flags": Historia.flags,        # inclui o que já foi pego e os diálogos vistos
			"escolhas": Historia.escolhas,
		},
		"inventario": Inventory.to_dict(),  # Comp 8: a tabela hash vira uma lista + quantidades
		"lanterna": {"bateria": lanterna.bateria, "ligada": lanterna.ligada} if lanterna else LANTERNA.guardada,
		"medo": Medo.valor,
		"celular": {"conversas": Celular.conversas, "notas": Celular.notas},
	}
	var arquivo := FileAccess.open(CAMINHO, FileAccess.WRITE)
	if arquivo == null:
		push_error("Não deu para salvar: " + error_string(FileAccess.get_open_error()))
		return
	arquivo.store_string(JSON.stringify(dados, "\t"))   # "\t" = arquivo identado, fácil de ler


## Lê o arquivo, devolve cada parte ao seu autoload e troca para a fase salva.
func carregar() -> bool:
	_fechar_janelas()
	var arquivo := FileAccess.open(CAMINHO, FileAccess.READ)
	if arquivo == null:
		return false
	var dados = JSON.parse_string(arquivo.get_as_text())
	if typeof(dados) != TYPE_DICTIONARY:
		push_error("Save corrompido: " + CAMINHO)
		return false

	var h: Dictionary = dados.get("historia", {})
	Historia.empatia = int(h.get("empatia", 0))       # JSON guarda números como decimal
	Historia.flags = h.get("flags", {})
	Historia.escolhas.assign(h.get("escolhas", []))   # assign: a lista é tipada

	Inventory.from_dict(dados.get("inventario", {}))
	LANTERNA.guardada = dados.get("lanterna", {})      # a lanterna nova lê isto no _ready
	_definir_medo(float(dados.get("medo", 0.0)))

	var c: Dictionary = dados.get("celular", {})
	Celular.conversas = c.get("conversas", [])
	Celular.notas.assign(c.get("notas", []))

	var pos = dados.get("posicao")
	if pos is Array:
		Transicao.posicao = Vector2(pos[0], pos[1])
		var o: Array = dados.get("olhando", [0, 1])
		Transicao.olhando = Vector2(o[0], o[1])
	Transicao.ir_para(dados.get("fase", ""))
	return true


## Começa do zero: tudo volta ao estado do início da noite.
## (O save antigo continua no disco até a próxima vez que a Bia salvar.)
func novo_jogo(primeira_fase: String) -> void:
	_fechar_janelas()
	Historia.empatia = 0
	Historia.flags = {}
	Historia.escolhas.clear()
	Inventory.clear()
	LANTERNA.guardada = {}
	_definir_medo(0.0)
	Celular.conversas = []
	Celular.notas.clear()
	Celular._carregar_dados()   # mensagens e notas iniciais do celular.json
	Transicao.ir_para(primeira_fase)


## Um diálogo ou o celular aberto não podem "vazar" para a fase seguinte.
func _fechar_janelas() -> void:
	if Dialogo.ativo:
		Dialogo._fechar()
	if Celular.aberto:
		Celular.fechar()


func _definir_medo(valor: float) -> void:
	Medo.descer(100.0)
	Medo.subir(valor)
