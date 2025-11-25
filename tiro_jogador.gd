extends Area2D

# --- Configurações ---
@export var velocidade_tiro: float = 1200.0 # Quão rápido o tiro "avança"
@export var tempo_de_vida: float = 0.5     # Tempo que o tiro existe antes de sumir
@export var escala_inicial: float = 1.0    # Tamanho mínimo ao ser gerado
@export var escala_final: float = 0.1      # Tamanho máximo ao "atingir a profundidade"

# --- Variáveis de Controle ---
var _direcao: Vector2 = Vector2.ZERO # Direção para onde o tiro vai
var _tempo_restante: float = 0.0      # Contador para o tempo de vida
var _progresso_escala: float = 0.0    # Progresso da animação de escala

func _ready():
	# Inicializa o tamanho do tiro para o efeito de profundidade
	scale = Vector2(escala_inicial, escala_inicial)
	_tempo_restante = tempo_de_vida
	
	# ✅ Garanta que os sinais de colisão estão conectados no Editor!
	# _on_body_entered para CharacterBody2D (Player/Obstáculos)
	# _on_area_entered para Area2D (Inimigos/Boss)

func _process(delta):
	_tempo_restante -= delta
	
	# ✅ Movimento "Para Frente" (Aqui é onde o tiro deve ir)
	# Se o jogo é 2D de visão lateral, "Frente" é o eixo X positivo.
	# Se o jogo é top-down/isométrico, 'direcao' virá de um cálculo.
	# Por agora, assumimos X positivo como "frente".
	position += _direcao * velocidade_tiro * delta

	# Animação de escala para dar a impressão de profundidade
	_progresso_escala = 1.0 - (_tempo_restante / tempo_de_vida)
	_progresso_escala = clamp(_progresso_escala, 0.0, 1.0) # Garante que está entre 0 e 1
	
	var nova_escala = lerp(escala_inicial, escala_final, _progresso_escala)
	scale = Vector2(nova_escala, nova_escala)

	# Tiro some ao final do tempo de vida
	if _tempo_restante <= 0:
		queue_free()

# Função para definir a direção do tiro (chamada pela Câmera/Jogador)
func set_direction(dir: Vector2):
	_direcao = dir.normalized()

# --- Lógica de Colisão (Inimigo "recebe" o tiro) ---

func _on_body_entered(body: Node2D):
	_handle_collision(body)

func _on_area_entered(area: Area2D):
	_handle_collision(area)

func _handle_collision(collider : Node2D):
	# Verifica se o objeto colidido é um Inimigo ou o Boss
	if collider.is_in_group("inimigos"): # Garanta que Inimigos/Boss estão neste grupo
		if collider.has_method("morrer"):
			collider.morrer()
		elif collider.has_method("tomar_dano"): # Para o Boss que tem vida
			collider.tomar_dano()
			
		# O tiro some após acertar algo
		queue_free()
