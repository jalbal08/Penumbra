extends Control
# Interfaz en pantalla: aviso de interaccion, notas y el HUD con el objetivo y el codigo.

@onready var prompt_label = $PromptLabel
@onready var nota_label = $NotaLabel

var hud_label: Label
var _nota_id = 0

func _ready():
	add_to_group("ui_interaccion")
	prompt_label.visible = false
	nota_label.visible = false
	_configurar_textos()
	_crear_hud()

func _configurar_textos():
	# Aviso "Presiona E": abajo al centro
	prompt_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	prompt_label.offset_top = -110
	prompt_label.offset_bottom = -70
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_texto_con_borde(prompt_label, 24)

	# Notas: al centro de la pantalla
	nota_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	nota_label.offset_left = -320
	nota_label.offset_right = 320
	nota_label.offset_top = -120
	nota_label.offset_bottom = 120
	nota_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nota_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_texto_con_borde(nota_label, 26)

func _texto_con_borde(l, tamano):
	l.add_theme_font_size_override("font_size", tamano)
	l.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", 8)

func _crear_hud():
	hud_label = Label.new()
	hud_label.position = Vector2(24, 20)
	_texto_con_borde(hud_label, 20)
	add_child(hud_label)

func _process(_delta):
	hud_label.text = "Objetivo: " + Inventario.objetivo_actual() + "\nCódigo: " + Inventario.texto_codigo()

func mostrar_prompt(texto):
	prompt_label.text = texto
	prompt_label.visible = true

func ocultar_prompt():
	prompt_label.visible = false

func mostrar_nota(texto):
	nota_label.text = texto
	nota_label.visible = true
	prompt_label.visible = false
	# La nota se esconde sola despues de unos segundos
	_nota_id += 1
	var mi_id = _nota_id
	await get_tree().create_timer(6.0).timeout
	if mi_id == _nota_id:
		nota_label.visible = false
