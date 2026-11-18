class_name PontoSeguro
extends Interagivel
## PONTO SEGURO — onde a Bia salva o jogo (o caderno da sala dos professores).
## É um Interagivel: herda o "E" e o "olhando para" e só troca o interagir().
## Pergunta com o próprio sistema de diálogo (um grafo pequeno, montado aqui no código).

## O que a Bia pergunta (o "Texto" do Inspector, se tiver, vem antes como pensamento).
@export var pergunta := "Aqui parece seguro. Anoto onde parei?"


func interagir() -> void:
	var nos := {
			"pergunta": {"quem": "BIA", "tipo": "escolha", "id_escolha": "salvar", "texto": pergunta,
				"opcoes": [
					{"texto": "Salvar o progresso", "proximo": "salvo"},
					{"texto": "Agora não", "proximo": "fim"},
				]},
			"salvo": {"quem": "BIA", "tipo": "pensamento",
				"texto": "Respira. Aqui dentro ela não entra.", "proximo": "fim"},
	}
	# Com "Texto" preenchido, a Bia primeiro pensa nele e depois pergunta.
	var comeco := "pergunta"
	if texto != "":
		nos["inicio"] = {"quem": "BIA", "tipo": "pensamento", "texto": texto, "proximo": "pergunta"}
		comeco = "inicio"
	Dialogo.iniciar_dados({
		"personagens": {"BIA": {"nome": "Bia", "retrato": "res://assets/retratos/bia.png", "cor": "#e8dcff"}},
		"nos": nos,
	}, comeco, "ponto seguro")
	Dialogo.escolheu.connect(_ao_escolher, CONNECT_ONE_SHOT)


func _ao_escolher(id_escolha: String, indice: int) -> void:
	if id_escolha != "salvar":
		return
	# Isto é uma escolha de menu, não da história: tira do relatório "Escolhas que importaram".
	Historia.escolhas.pop_back()
	if indice == 0:
		Medo.descer(100.0)          # no ponto seguro o Medo zera
		Save.salvar()
		Avisos.mostrar("Progresso salvo.")
