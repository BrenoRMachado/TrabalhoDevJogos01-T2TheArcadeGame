extends Area2D

#Cria variáveis
enum Estado { APROXIMANDO, ANDANDO_LADO, ATACANDO, MORTO }
var estado_atual = Estado.APROXIMANDO

var y_inicial: float = 498.0
var y_final: float = 577.0

var velocidade_aproximacao: float = 15.0 
var velocidade_lateral: float = 80.0

@export var cena_projetil: PackedScene

var escala_inicial: float = 0.5
var escala_final: float = 3.0

var direcao_lateral: int = 0 

@onready var anim = $AnimatedSprite2D
@onready var timer_lado = $TimerLateral
@onready var timer_tiro = $TimerTiro
@onready var colisor = $CollisionShape2D
@onready var boca_cano = $BocaDoCano

func _ready():
	#Inicia escala e movimentação
	position.y = y_inicial
	scale = Vector2(escala_inicial, escala_inicial)
	anim.play("walking_front")
	
	#Timers do inimigo
	self.input_event.connect(_on_clique_mouse)
	timer_lado.timeout.connect(_on_fim_caminhada_lado)
	timer_tiro.timeout.connect(_on_atirar)

func _process(delta):
	#Estados possíveis para inimigo
	match estado_atual:
		Estado.APROXIMANDO:
			_comportamento_aproximar(delta)
		Estado.ANDANDO_LADO:
			_comportamento_andar_lado(delta)
		Estado.ATACANDO:
			pass 
		Estado.MORTO:
			pass

#Função para aproximação de tela
func _comportamento_aproximar(delta):
	position.y += velocidade_aproximacao * delta
	
	var progresso = (position.y - y_inicial) / (y_final - y_inicial)
	progresso = clamp(progresso, 0.0, 1.0)
	
	var nova_escala = lerp(escala_inicial, escala_final, progresso)
	scale = Vector2(nova_escala, nova_escala)
	
	if position.y >= y_final:
		position.y = y_final
		_trocar_para_andar_lado()

#Função para andar para o lado
func _trocar_para_andar_lado():
	estado_atual = Estado.ANDANDO_LADO
	var opcoes = [-1, 1]
	direcao_lateral = opcoes.pick_random()
	
	anim.play("walking_side")
	anim.flip_h = (direcao_lateral == -1)
	boca_cano.position.x = abs(boca_cano.position.x) * direcao_lateral
	timer_lado.start()

#Movimento lateral
func _comportamento_andar_lado(delta):
	position.x += (velocidade_lateral * direcao_lateral) * delta

#Função para inimigo parado
func _on_fim_caminhada_lado():
	if estado_atual == Estado.MORTO: return
	
	estado_atual = Estado.ATACANDO
	anim.play("standing")
	
	# Atira imediatamente ao parar
	_on_atirar()
	timer_tiro.start()

#Função para atirar
func _on_atirar():
	#Quando morto não atira
	if estado_atual == Estado.MORTO: return
	
	#Gera projétil inimigo
	if cena_projetil:
		var novo_tiro = cena_projetil.instantiate()
		novo_tiro.global_position = boca_cano.global_position
		get_tree().current_scene.add_child(novo_tiro)

#Reação inimigo ao clique
func _on_clique_mouse(_viewport, event, _shape_idx):
	if estado_atual == Estado.MORTO: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		morrer() 

#Função de morte
func morrer():
	estado_atual = Estado.MORTO
	colisor.set_deferred("disabled", true)
	timer_tiro.stop()
	timer_lado.stop()
	
	var hud = get_tree().root.find_child("HUD", true, false)
	
	#Pontuação
	if hud and hud.has_method("atualiza_pontuacao"):
		hud.atualiza_pontuacao(100)
	
	#Morte do inimigo
	anim.play("death")
	await anim.animation_finished
	
	queue_free()
