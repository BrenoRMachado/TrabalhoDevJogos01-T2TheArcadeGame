extends Area2D

#Cria variáveis
@onready var sprite: AnimatedSprite2D = $Sprite2D
@export var velocidade_mira : float = 20.0
var posicao_mira : Vector2 = Vector2.ZERO
const AnimationOnClick = "click"

#Implementa funções
func _ready() -> void:
	pass

#Atualiza posição da mira durante frames em uma velocidade definida
func _physics_process(delta: float) -> void:
	position = position.lerp(posicao_mira, delta * velocidade_mira)

#Função que atualiza a posição dado um vetor
func atualiza_posicao(nova_posicao : Vector2):
	posicao_mira = nova_posicao

#Função que aciona a animação de click do mouse
func animacao_ao_clicar() -> void:
	sprite.play(AnimationOnClick)
