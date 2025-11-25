extends Area2D

# --- Estados ---
enum Estado { APROXIMANDO, ANDANDO_LADO, ATACANDO, MORTO }
var estado_atual = Estado.APROXIMANDO

# --- Configurações de Movimento ---
var y_inicial: float = 498.0
var y_final: float = 577.0

# Velocidade de aproximação (Ajuste aqui se quiser mais rápido ou devagar)
var velocidade_aproximacao: float = 15.0 
var velocidade_lateral: float = 80.0

@export var cena_projetil: PackedScene

# --- Configurações de Escala ---
var escala_inicial: float = 0.5
var escala_final: float = 3.0

# --- Variáveis de Controle ---
var direcao_lateral: int = 0 

# Nós
@onready var anim = $AnimatedSprite2D
@onready var timer_lado = $TimerLateral
@onready var timer_tiro = $TimerTiro
@onready var colisor = $CollisionShape2D
@onready var boca_cano = $BocaDoCano

func _ready():
	position.y = y_inicial
	scale = Vector2(escala_inicial, escala_inicial)
	anim.play("walking_front")
	
	self.input_event.connect(_on_clique_mouse)
	timer_lado.timeout.connect(_on_fim_caminhada_lado)
	timer_tiro.timeout.connect(_on_atirar)

func _process(delta):
	match estado_atual:
		Estado.APROXIMANDO:
			_comportamento_aproximar(delta)
		Estado.ANDANDO_LADO:
			_comportamento_andar_lado(delta)
		Estado.ATACANDO:
			pass 
		Estado.MORTO:
			pass

func _comportamento_aproximar(delta):
	position.y += velocidade_aproximacao * delta
	
	var progresso = (position.y - y_inicial) / (y_final - y_inicial)
	progresso = clamp(progresso, 0.0, 1.0)
	
	var nova_escala = lerp(escala_inicial, escala_final, progresso)
	scale = Vector2(nova_escala, nova_escala)
	
	if position.y >= y_final:
		position.y = y_final
		_trocar_para_andar_lado()

func _trocar_para_andar_lado():
	estado_atual = Estado.ANDANDO_LADO
	var opcoes = [-1, 1]
	direcao_lateral = opcoes.pick_random()
	
	anim.play("walking_side")
	anim.flip_h = (direcao_lateral == -1)
	boca_cano.position.x = abs(boca_cano.position.x) * direcao_lateral
	timer_lado.start()

func _comportamento_andar_lado(delta):
	position.x += (velocidade_lateral * direcao_lateral) * delta

func _on_fim_caminhada_lado():
	if estado_atual == Estado.MORTO: return
	
	estado_atual = Estado.ATACANDO
	anim.play("standing")
	
	# Atira imediatamente ao parar
	_on_atirar()
	timer_tiro.start()

func _on_atirar():
	if estado_atual == Estado.MORTO: return
	
	# Verifica se colocamos o tiro no Inspector pra não dar erro
	if cena_projetil:
		# 1. Cria a cópia do tiro
		var novo_tiro = cena_projetil.instantiate()
		
		# 2. Define onde ele nasce (na mesma posição do inimigo)
		novo_tiro.global_position = boca_cano.global_position
		
		# 3. Adiciona o tiro na cena principal (não como filho do inimigo, senão buga)
		get_tree().current_scene.add_child(novo_tiro)
		
		# 4. Manda o tiro ir na direção do mouse atual
		novo_tiro.definir_alvo(get_global_mouse_position())
		
		print("POW! Inimigo disparou.")

func _on_clique_mouse(_viewport, event, _shape_idx):
	if estado_atual == Estado.MORTO: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		morrer() 

# --- CORREÇÃO AQUI ---
func morrer():
	estado_atual = Estado.MORTO
	colisor.set_deferred("disabled", true) # Desliga o colisor
	timer_tiro.stop()
	timer_lado.stop()
	
	anim.play("death")
	
	# A MÁGICA: Espera o sinal de que a animação terminou de verdade
	await anim.animation_finished
	
	# Só depois de terminar ele deleta
	queue_free()
