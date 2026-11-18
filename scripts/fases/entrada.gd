class_name Entrada
extends Marker2D
## Um ponto onde a Bia aparece quando chega nesta fase por uma porta.
## Fica dentro do nó "Entradas" da fase. O NOME do nó é o que a porta usa
## em "Entrada Destino".

## Para onde a Bia fica olhando ao chegar (a lanterna também aponta para lá).
@export var olhando := Vector2.DOWN
