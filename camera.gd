extends Camera2D


#Cria variáveis
@onready var mira : Area2D = $Mira

func _ready() -> void:
	#Oculta mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) 

func _process(delta: float) -> void:
	#Corrige posição relativa entre mouse e camera
	var posicao_mouse : Vector2 = get_viewport().get_mouse_position()
	var posicao_relativa_camera : Vector2 = get_viewport_rect().size / 2.0
	
	#Chama função da Mira para atualizar posição baseado no mouse
	var posicao_corrigida : Vector2 = posicao_mouse - posicao_relativa_camera
	mira.atualiza_posicao(posicao_corrigida)

func _input(event) -> void:
	#Em evento, verifica se o click esquerdo do mouse foi acionado
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#Se sim, chama a função de animação da Mira
		if event.pressed:
			mira.animacao_ao_clicar()
