extends Area2D

# Configurações do tiro
var velocidade_crescimento: float = 2.5  # Velocidade que "vem pra frente"
var velocidade_viagem: float = 400.0     # Velocidade lateral (ir até o alvo)
var tamanho_explosao: float = 3.0
@export var dano_causado: int = 1        # Tamanho que ele acerta o player

var direcao: Vector2 = Vector2.ZERO

func _ready():
	# Começa pequenininho
	scale = Vector2(0.2, 0.2)
	
	# Se sair da tela, se destrói sozinho
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	
	call_deferred("mirar_no_centro")

func mirar_no_centro():
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	if camera:
		var centro_da_tela = viewport.get_visible_rect().size / 2
		var camera_transform = camera.get_canvas_transform()
		var alvo_global: Vector2
		alvo_global = camera_transform.inverse() * centro_da_tela
		definir_alvo(alvo_global)

func definir_alvo(posicao_alvo: Vector2):
	# Calcula a direção: Do tiro -> Para a mira do mouse
	direcao = (posicao_alvo - global_position).normalized()
	# 2. A CORREÇÃO: Faz o tiro "olhar" para onde está indo
	look_at(posicao_alvo)

func _process(delta):
	# 1. Efeito 3D: Cresce vindo pra tela
	scale += Vector2(velocidade_crescimento, velocidade_crescimento) * delta
	
	# 2. Movimento 2D: Viaja na direção do alvo
	global_position += direcao * velocidade_viagem * delta
	
	# 3. Verifica se bateu na "tela" (ficou muito grande)
	if scale.x >= tamanho_explosao:
		acertar_player()

func acertar_player():
	
	var camera_node = get_viewport().get_camera_2d()
	if camera_node and camera_node.has_method("tomar_dano"):
		camera_node.tomar_dano(2)

	queue_free()

# Se quiser que o tiro seja destruível pelo clique do jogador:
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Tiro destruído no ar!")
		queue_free()
