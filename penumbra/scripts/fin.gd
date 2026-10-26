extends Control
# Pantalla final: el jugador escapo.

const Estilo = preload("res://scripts/estilo_ui.gd")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var fondo = ColorRect.new()
	fondo.color = Color(0.02, 0.02, 0.03)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	var centro = CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 30)
	centro.add_child(vbox)

	var titulo = Label.new()
	titulo.text = "LOGRASTE ESCAPAR"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Estilo.texto(titulo, 56, Color(0.75, 0.1, 0.1))
	vbox.add_child(titulo)

	var texto = Label.new()
	texto.text = "La puerta se abre y el aire frío de la noche te golpea la cara.\nNunca sabrás qué había realmente en ese lugar."
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Estilo.texto(texto, 22)
	vbox.add_child(texto)

	var volver = Button.new()
	volver.text = "Volver al menú"
	volver.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	Estilo.boton(volver)
	volver.pressed.connect(func():
		Inventario.reiniciar_todo()
		Transicion.ir_a("res://scenes/menu_principal.tscn"))
	vbox.add_child(volver)

	var salir = Button.new()
	salir.text = "Salir"
	salir.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	Estilo.boton(salir)
	salir.pressed.connect(func(): get_tree().quit())
	vbox.add_child(salir)
