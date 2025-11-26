extends Area2D

#Cria variáveis
@export var vida: int = 50
@export var velocidade: float = 100.0
@export var offset_limite_horizontal: float = 400.0 
@export var cena_projetil: PackedScene  

const CENA_VITORIA = preload("res://TelaVitoria.tscn")
@export var tempo_atraso_vitoria: float = 3.0
@onready var timer_vitoria = $TimerVitoria

var direcao_x: int = 1
var esta_morto: bool = false
var camera: Camera2D = null

@onready var timer_tiro = $TimerTiro
@onready var canos = $Armas.get_children()
@onready var anim_explosao = $ExplosaoVisual

func _ready():
	$AnimatedSprite2D.play("default")

	#Tiro do boss
	timer_tiro.wait_time = 1.5
	timer_tiro.start()
	timer_tiro.timeout.connect(_disparar_todos_canos)
	timer_vitoria.timeout.connect(_on_timer_vitoria_timeout)

	self.input_event.connect(_on_receber_clique)

func _process(delta):
	if esta_morto: return
	
	var centro_camera_x = camera.global_position.x
	var limite_esquerda = centro_camera_x - offset_limite_horizontal
	var limite_direita = centro_camera_x + offset_limite_horizontal

	position.x += (velocidade * direcao_x) * delta
	
	#Movimentação inimigo
	if position.x >= limite_direita:
		direcao_x = -1
	elif position.x <= limite_esquerda:
		direcao_x = 1 

#Função para atirar
func _disparar_todos_canos():
	if esta_morto: return
	if not cena_projetil: return
	var alvo_global = camera.global_position
	
	for cano in canos:
		var novo_tiro = cena_projetil.instantiate()
		novo_tiro.global_position = cano.global_position
		
		get_tree().current_scene.add_child(novo_tiro)
		
		novo_tiro.definir_alvo(alvo_global)

#Função para ser clicável
func _on_receber_clique(_viewport, event, _shape_idx):
	if esta_morto: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		tomar_dano()

#Função para tomar dano
func tomar_dano():
	vida -= 1

	var hud = get_tree().root.find_child("HUD", true, false)
	if hud and hud.has_method("atualiza_pontuacao"):
		hud.atualiza_pontuacao(50) 

	#Pisca vermelho ao receber dano
	modulate = Color(10, 0, 0)
	await get_tree().create_timer(0.05).timeout
	modulate = Color(1, 1, 1)
	
	if vida <= 0:
		morrer()

#Função inimigo morrer
func morrer():
	if esta_morto:
		return

	esta_morto = true
	timer_tiro.stop()
	$CollisionShape2D.set_deferred("disabled", true)
	
	timer_vitoria.start(tempo_atraso_vitoria)
	
	#Pontuação 
	var hud = get_tree().root.find_child("HUD", true, false)
	if hud and hud.has_method("atualiza_pontuacao"):
		hud.atualiza_pontuacao(5000) 
	
	#Animação explosão
	anim_explosao.visible = true
	anim_explosao.play("default")
	
	#Some lentamente
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1.5) 
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 1.5)
	
	await tween.finished

#Quando derrotado, chama cena de vitória
func _on_timer_vitoria_timeout():
	get_tree().paused = true
	if CENA_VITORIA:
		var tela_vitoria = CENA_VITORIA.instantiate()
		get_tree().current_scene.add_child(tela_vitoria)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	queue_free()
