extends Area2D

#Cria variáveis
var velocidade_crescimento: float = 2.5 
var velocidade_viagem: float = 400.0   
var tamanho_explosao: float = 3.0
@export var dano_causado: int = 1    

var direcao: Vector2 = Vector2.ZERO

func _ready():
	#Começa pequeno
	scale = Vector2(0.2, 0.2)
	
	#Se sair da tela, se destrói sozinho
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	
	call_deferred("mirar_no_centro")

#Função para projetil mirar no centro
func mirar_no_centro():
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	if camera:
		var centro_da_tela = viewport.get_visible_rect().size / 2
		var camera_transform = camera.get_canvas_transform()
		var alvo_global: Vector2
		alvo_global = camera_transform.inverse() * centro_da_tela
		definir_alvo(alvo_global)

#Função para definir alvo do projétil
func definir_alvo(posicao_alvo: Vector2):

	direcao = (posicao_alvo - global_position).normalized()
	look_at(posicao_alvo)

func _process(delta):
	#Crescimento de escala
	scale += Vector2(velocidade_crescimento, velocidade_crescimento) * delta
	
	global_position += direcao * velocidade_viagem * delta
	
	#Acerta jogador
	if scale.x >= tamanho_explosao:
		acertar_player()

#Função para atingir jogador
func acertar_player():
	var camera_node = get_viewport().get_camera_2d()
	if camera_node and camera_node.has_method("tomar_dano"):
		camera_node.tomar_dano(2)
	queue_free()

#Função que torna projétil destrutível
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		queue_free()
