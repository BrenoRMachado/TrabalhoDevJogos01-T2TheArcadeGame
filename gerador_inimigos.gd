extends Node


#Criação variáveis
const CENA_INIMIGO = preload("res://inimigo.tscn")
var camera: Camera2D = null

const DISTANCIA_MINIMA_X: float = -1000.0 
const DISTANCIA_MAXIMA_X: float = 1000.0 
const DISTÂNCIA_PARA_DELETAR: float = 600.0 
const ALTURA_FIXA_Y: float = 498.0
const INTERVALO_SPAWN: float = 0.5 

var tempo_ate_spawn: float = 0.0
var lista_inimigos: Array[Node2D] = []

var geracao_ativa: bool = true

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	if !camera:
		return
		
	#Para de gerar inimigos no estado final
	if geracao_ativa:
		tempo_ate_spawn -= delta
		if tempo_ate_spawn <= 0:
			spawn_inimigo()
			tempo_ate_spawn = INTERVALO_SPAWN

	#Deleta inimigos fora da câmera
	deleta_inimigos()

func inicia_timer(cam: Camera2D) -> void:
	#Inicia timer
	camera = cam
	tempo_ate_spawn = INTERVALO_SPAWN 
	geracao_ativa = true

#Função para parar de gerar inimigos
func parar_geracao() -> void:
	geracao_ativa = false

#Função para spawnar inimigos
func spawn_inimigo() -> void:
	#Calcula a posição x de geração à frente da câmera
	var spawn_x: float = camera.global_position.x + randf_range(DISTANCIA_MINIMA_X, DISTANCIA_MAXIMA_X)

	#Posição y fixa
	var spawn_y: float = ALTURA_FIXA_Y
	var instancia_inimigo = CENA_INIMIGO.instantiate()
	get_parent().add_child(instancia_inimigo)
	instancia_inimigo.global_position = Vector2(spawn_x, spawn_y)
	
	lista_inimigos.append(instancia_inimigo)

#Deletar inimigos fora da tela
func deleta_inimigos() -> void:
	#Obtém a posição relativa para deletar
	var limite_deleta: float = camera.global_position.x - DISTÂNCIA_PARA_DELETAR
	
	#Percorre a lista de inimigos ativos
	for i in range(lista_inimigos.size() - 1, -1, -1):
		var inimigo = lista_inimigos[i]
		
		#Remove inimigos que estão muito para trás
		if is_instance_valid(inimigo) and inimigo.global_position.x < limite_deleta:
			inimigo.queue_free()
			lista_inimigos.remove_at(i)

#Deletar inimigos na cena final
func deleta_todos_inimigos() -> void:
	#Percorre a lista e deleta todos de forma segura
	for inimigo in lista_inimigos:
		if is_instance_valid(inimigo):
			inimigo.queue_free()
	#Limpa o array de inimigos
	lista_inimigos.clear()
