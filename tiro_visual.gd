extends Node2D

#Cria variáveis
var direcao: Vector2 = Vector2.ZERO
var velocidade: float = 1500.0
var distancia_maxima: float = 0.0
var distancia_percorrida: float = 0.0

func _process(delta):
	#Calcula quanto andou neste frame
	var passo = velocidade * delta
	
	#Move o tiro
	position += direcao * passo
	
	#Tiro diminui
	scale -= Vector2(1.5, 1.5) * delta
	
	#Soma no contador
	distancia_percorrida += passo
	
	#Tiro some ao alcançar inimigo
	if distancia_percorrida >= distancia_maxima:
		queue_free()
