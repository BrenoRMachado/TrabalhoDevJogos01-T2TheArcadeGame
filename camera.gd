extends Camera2D


#Cria variáveis
@onready var mira : Area2D = $"Mira"
@export var vida_maxima: int = 100
@export var cena_tiro_visual: PackedScene
var vida_atual: int = 100
var barra_de_vida: ProgressBar = null

enum EstadoCamera { INICIO, MOVIMENTO_DIREITA, FIM }
var estado_atual = EstadoCamera.INICIO
var tempo_no_estado: float = 0.0

const TEMPO_PARADO: float = 10.0      
const TEMPO_MOVENDO: float = 10.0  
const VELOCIDADE_MOVIMENTO: float = 150.0

const CENA_SPAWN = preload("res://gerador_inimigos.tscn")
const CENA_BOSS = preload("res://boss.tscn")
var spawner_inimigo: Node = null # Referência para o Spawner

func _ready() -> void:
	var instancia_spawner = CENA_SPAWN.instantiate()
	get_parent().call_deferred("add_child", instancia_spawner)
	
	instancia_spawner.inicia_timer(self)
	spawner_inimigo = instancia_spawner
	
	var hud_node = get_parent().find_child("HUD")
	if hud_node:
		var controle_node = hud_node.find_child("Controle") 
		if controle_node:
			barra_de_vida = controle_node.find_child("BarraDeVida")
			if barra_de_vida:
				barra_de_vida.max_value = float(vida_maxima)
				barra_de_vida.value = float(vida_atual)
	#Oculta mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) 

func _process(delta: float) -> void:
	#Chama função movimento de câmera
	handle_lateral_movement(delta)
	
	#Corrige posição relativa entre mouse e camera
	var posicao_mouse : Vector2 = get_viewport().get_mouse_position()
	var posicao_relativa_camera : Vector2 = get_viewport_rect().size / 2.0
	
	#Chama função da Mira para atualizar posição baseado no mouse
	var posicao_corrigida : Vector2 = posicao_mouse - posicao_relativa_camera
	mira.atualiza_posicao(posicao_corrigida)

func handle_lateral_movement(delta: float) -> void:
	# Adiciona delta ao tempo no estado atual
	tempo_no_estado += delta

	#Tratamento de cada estado possível
	match estado_atual:
		#Parado no início
		EstadoCamera.INICIO:
			if tempo_no_estado >= TEMPO_PARADO:
				estado_atual = EstadoCamera.MOVIMENTO_DIREITA
				tempo_no_estado = 0.0
		#Começa movimento lateral
		EstadoCamera.MOVIMENTO_DIREITA:
			position.x += VELOCIDADE_MOVIMENTO * delta
			if tempo_no_estado >= TEMPO_MOVENDO:
				estado_atual = EstadoCamera.FIM
				tempo_no_estado = 0.0
				spawner_inimigo.parar_geracao()
				spawner_inimigo.deleta_todos_inimigos()
				spawn_boss()
				
		#Parado no final
		EstadoCamera.FIM:
			pass

func _input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# 1. Animação da mira (que já existia)
			mira.animacao_ao_clicar()
			
			# 2. A NOVA RAJADA DE TIROS VISUAIS
			if cena_tiro_visual:
				_criar_rajada_tiros()

func _criar_rajada_tiros():
	var mouse_pos = get_global_mouse_position()
	var origem_tiro = global_position
	origem_tiro.y += 300 
	
	# Calcula a distância exata entre a arma e o clique
	var distancia_do_clique = origem_tiro.distance_to(mouse_pos)
	
	var direcao = (mouse_pos - origem_tiro).normalized()
	
	for i in range(6):
		if not cena_tiro_visual: break
		
		var novo_tiro = cena_tiro_visual.instantiate()
		get_parent().add_child(novo_tiro)
		
		novo_tiro.global_position = origem_tiro
		novo_tiro.direcao = direcao
		novo_tiro.rotation = direcao.angle()
		
		# AQUI ESTÁ A MÁGICA:
		# Passamos a distância para a bala saber quando parar
		novo_tiro.distancia_maxima = distancia_do_clique
		
		await get_tree().create_timer(0.05).timeout

func spawn_boss():
	var boss_instancia = CENA_BOSS.instantiate()
	get_parent().call_deferred("add_child", boss_instancia)
	# Adiciona o Boss na cena principal
	boss_instancia.camera = self
	# Posiciona o Boss no centro da visão da Câmera (ou onde ele deve começar)
	var spawn_x: float = global_position.x 
	var spawn_y: float = global_position.y - 200 # Um pouco acima do centro
	
	boss_instancia.global_position = Vector2(spawn_x, spawn_y)
	print("BOSS gerado em X:", spawn_x)

func tomar_dano(quantidade: int):
	# Não recebe dano se já estiver morto
	if vida_atual <= 0:
		return

	vida_atual -= quantidade
	print("Vida atual: ", vida_atual)
	
	# Verificar se a vida acabou (Game Over)
	if vida_atual <= 0:
		vida_atual = 0
		game_over()
		
	if is_instance_valid(barra_de_vida):
		barra_de_vida.value = float(vida_atual)

func game_over():
	print("GAME OVER! A vida do jogador chegou a zero.")
