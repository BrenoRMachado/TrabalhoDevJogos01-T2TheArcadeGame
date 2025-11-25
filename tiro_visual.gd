extends Node2D # Pode voltar a ser Node2D se quiser, ou Area2D, tanto faz

var direcao: Vector2 = Vector2.ZERO
var velocidade: float = 1500.0
var distancia_maxima: float = 0.0 # A distância exata até o clique
var distancia_percorrida: float = 0.0

func _process(delta):
	# Calcula quanto andou neste frame
	var passo = velocidade * delta
	
	# Move o tiro
	position += direcao * passo
	
	# Efeito visual (diminuir)
	scale -= Vector2(1.5, 1.5) * delta
	
	# Soma no contador
	distancia_percorrida += passo
	
	# O TRUQUE: Se já andou tudo que tinha pra andar, "explode"
	if distancia_percorrida >= distancia_maxima:
		queue_free() # Aqui o tiro some (parece que bateu no alvo)
