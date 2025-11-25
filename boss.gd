extends Area2D

# --- Configurações ---
@export var vida: int = 50
@export var velocidade: float = 100.0
@export var limite_esquerda: float = 100.0 # Ajuste conforme a tela do seu amigo
@export var limite_direita: float = 1000.0 # Ajuste conforme a tela
@export var cena_projetil: PackedScene     # Arraste o projetil_inimigo.tscn aqui

# --- Variáveis de Controle ---
var direcao_x: int = 1 # 1 = Direita, -1 = Esquerda
var esta_morto: bool = false

# --- Pegando os nós ---
@onready var timer_tiro = $TimerTiro
# Pega todos os filhos do nó "Armas" de uma vez só
@onready var canos = $Armas.get_children()
@onready var anim_explosao = $ExplosaoVisual

func _ready():
	$AnimatedSprite2D.play("default")
	# Inicia voando
	timer_tiro.wait_time = 1.5 # Tempo entre rajadas de tiro
	timer_tiro.start()
	timer_tiro.timeout.connect(_disparar_todos_canos)
	
	# Para receber cliques (tiros do player)
	self.input_event.connect(_on_receber_clique)

func _process(delta):
	if esta_morto: return
	
	# --- Movimento Ping-Pong (Lado a Lado) ---
	position.x += (velocidade * direcao_x) * delta
	
	# Verifica se bateu nos limites da tela para virar
	if position.x >= limite_direita:
		direcao_x = -1 # Vira pra esquerda
	elif position.x <= limite_esquerda:
		direcao_x = 1  # Vira pra direita

func _disparar_todos_canos():
	if esta_morto: return
	if not cena_projetil: return
	
	print("BOSS: DISPARANDO 4 ARMAS!")
	
	# Loop inteligente: Passa por cada Marker2D dentro da pasta "Armas"
	for cano in canos:
		# Cria um tiro pra cada cano
		var novo_tiro = cena_projetil.instantiate()
		novo_tiro.global_position = cano.global_position
		
		get_tree().current_scene.add_child(novo_tiro)
		
		var centro_da_tela = get_viewport_rect().size / 2
		novo_tiro.definir_alvo(centro_da_tela)

func _on_receber_clique(_viewport, event, _shape_idx):
	if esta_morto: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		tomar_dano()

func tomar_dano():
	vida -= 1
	# Piscar vermelho
	modulate = Color(10, 0, 0)
	await get_tree().create_timer(0.05).timeout
	modulate = Color(1, 1, 1)
	
	if vida <= 0:
		morrer()

func morrer():
	esta_morto = true
	timer_tiro.stop()
	$CollisionShape2D.set_deferred("disabled", true)
	
	# 1. Faz a Explosão aparecer e tocar
	anim_explosao.visible = true
	anim_explosao.play("default") # Ou o nome que você deu pra animação
	
	# 2. Ao mesmo tempo, o Boss vai sumindo (efeito que já tínhamos)
	var tween = create_tween()
	# Fica transparente
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1.5) 
	# Encolhe um pouco (opcional, se quiser manter)
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 1.5)
	
	# 3. Espera a animação mais longa terminar (no caso, o tween de 1.5s)
	await tween.finished
	
	# Tchau Boss
	queue_free()
