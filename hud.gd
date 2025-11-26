extends CanvasLayer

#Cria variáveis
@onready var barra_de_vida : ProgressBar = $Controle/BarraDeVida
@onready var pontuacao : Label = $Controle/Pontos

var vida_atual : int = 100
var pontuacao_atual : int = 0

func _ready() -> void:
	#Vida e pontuação iniciais
	barra_de_vida.value = vida_atual
	pontuacao.text = "Pontos: %d" % pontuacao_atual

#Atualização da vida
func atualiza_vida(dano : int) -> void:
	vida_atual -= dano
	barra_de_vida.value = vida_atual
	
	if vida_atual <= 0:
		print("Personagem morreu!")

#Atualização da pontuação
func atualiza_pontuacao(pontos: int) -> void:
	pontuacao_atual += pontos
	pontuacao.text = "Pontos: %d" % pontuacao_atual
