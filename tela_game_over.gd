extends CanvasLayer

func _ready():
	# Conecta os botões via código para ser mais rápido
	$VBoxContainer/BotaoReiniciar.pressed.connect(_on_reiniciar_pressed)
	$VBoxContainer/BotaoSair.pressed.connect(_on_sair_pressed)

func _on_reiniciar_pressed():
	# Recarrega a cena que estava aberta (reinicia o jogo)
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_sair_pressed():
	# Fecha o jogo
	get_tree().quit()
