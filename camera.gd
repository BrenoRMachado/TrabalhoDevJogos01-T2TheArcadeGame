extends Camera2D


#Cria variáveis
@onready var mira : Area2D = $Mira

enum EstadoCamera { INICIO, MOVIMENTO_DIREITA, FIM }
var estado_atual = EstadoCamera.INICIO
var tempo_no_estado: float = 0.0

const TEMPO_PARADO: float = 5.0      
const TEMPO_MOVENDO: float = 5.0  
const VELOCIDADE_MOVIMENTO: float = 100.0

func _ready() -> void:
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
		#Parado no final
		EstadoCamera.FIM:
			pass

func _input(event) -> void:
	#Em evento, verifica se o click esquerdo do mouse foi acionado
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#Se sim, chama a função de animação da Mira
		if event.pressed:
			mira.animacao_ao_clicar()
