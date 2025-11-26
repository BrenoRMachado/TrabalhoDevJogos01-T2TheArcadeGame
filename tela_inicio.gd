extends Control

@onready var titulo: Label = $VBoxContainer/Titulo
@onready var botao_jogar = $VBoxContainer/BotaoJogar
@onready var botao_sair = $VBoxContainer/BotaoSair

# Referência para a cena principal do jogo
const CENA_JOGO = "res://main.tscn" # CONFIRA SE O NOME É ESSE MESMO

func _ready():
	# 1. Conecta os botões
	botao_jogar.pressed.connect(_on_jogar_pressed)
	botao_sair.pressed.connect(_on_sair_pressed)
	

func _on_jogar_pressed():
	# Muda para a cena do jogo
	get_tree().change_scene_to_file(CENA_JOGO)

func _on_sair_pressed():
	get_tree().quit()
