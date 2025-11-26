extends CanvasLayer

@onready var titulo: Label = $VBoxContainer/Titulo
@onready var botao_jogar = $VBoxContainer/BotaoJogar
@onready var botao_sair = $VBoxContainer/BotaoSair

const CENA_JOGO = "res://main.tscn"

func _ready():
	botao_jogar.pressed.connect(_on_jogar_pressed)
	botao_sair.pressed.connect(_on_sair_pressed)
	

func _on_jogar_pressed():
	#Chama cena principal
	get_tree().change_scene_to_file(CENA_JOGO)

func _on_sair_pressed():
	#Fecha o jogo
	get_tree().quit()
