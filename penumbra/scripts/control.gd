extends Control

@onready var prompt_label = $PromptLabel
@onready var nota_label = $NotaLabel

func _ready():
	add_to_group("ui_interaccion")
	prompt_label.visible = false
	nota_label.visible = false

func mostrar_prompt(texto):
	prompt_label.text = texto
	prompt_label.visible = true

func ocultar_prompt():
	prompt_label.visible = false

func mostrar_nota(texto):
	nota_label.text = texto
	nota_label.visible = true
	prompt_label.visible = false
