class_name Porta
extends Interagivel
## Uma porta (ou passagem) que leva para outra fase.
## Herda tudo do Interagivel (o "E" piscando, o "olhando para"...) e só troca
## o que acontece no interagir().
##
##   • Cena Destino:    a fase para onde vai (.tscn)
##   • Entrada Destino: o nome da Entrada lá dentro onde a Bia aparece
##   • Automatica:      passagem aberta (escada, corredor): basta andar por cima, sem E
##   • Trancada:        não abre; a Bia pensa o "Texto"

@export_file("*.tscn") var cena_destino := ""
@export var entrada_destino := ""
@export var automatica := false
@export var trancada := false
## Som ao abrir (opcional). Vazio = sem som.
@export var som_ao_abrir: AudioStream


func _ready() -> void:
	super._ready()   # roda o _ready do Interagivel (cria o "E")
	if automatica:
		body_entered.connect(func(corpo): if corpo.name == "Bia": interagir())


## Passagem automática não mostra o "E".
func _pode_interagir() -> bool:
	if automatica:
		return false
	return super._pode_interagir()


func interagir() -> void:
	if trancada:
		Dialogo.pensar(texto)
		return
	if cena_destino == "":
		push_warning("Porta '%s' sem Cena Destino." % name)
		return
	if som_ao_abrir and not automatica:
		_tocar(som_ao_abrir)
	Transicao.ir_para(cena_destino, entrada_destino)
