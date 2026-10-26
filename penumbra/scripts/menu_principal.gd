extends Control

const Estilo = preload("res://scripts/estilo_ui.gd")

var panel_instrucciones: CenterContainer
var panel_ajustes: CenterContainer

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	$Fondo.color = Color(0.04, 0.04, 0.05)

	$Titulo.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	$Titulo.offset_top = 70
	$Titulo.offset_bottom = 150
	$Titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Titulo.add_theme_font_size_override("font_size", 56)
	$Titulo.add_theme_color_override("font_color", Color(0.75, 0.1, 0.1))

	$Botones.add_theme_constant_override("separation", 18)
	for boton in $Botones.get_children():
		Estilo.boton(boton)

	panel_instrucciones = _crear_instrucciones()
	panel_ajustes = _crear_ajustes()

	$Botones/BtnJugar.pressed.connect(_on_jugar)
	$Botones/BtnInstrucciones.pressed.connect(func(): _mostrar(panel_instrucciones))
	$Botones/BtnAjustes.pressed.connect(func(): _mostrar(panel_ajustes))
	$Botones/BtnSalir.pressed.connect(_on_salir)

func _mostrar(panel):
	$Botones.visible = false
	panel.visible = true

func _volver():
	panel_instrucciones.visible = false
	panel_ajustes.visible = false
	$Botones.visible = true
	Ajustes.guardar()

# Crea un panel centrado con un VBox adentro. Devuelve [centro, vbox]
func _crear_panel_base(ancho):
	var centro = CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centro.visible = false
	add_child(centro)

	var caja = PanelContainer.new()
	Estilo.panel(caja)
	centro.add_child(caja)

	var margen = MarginContainer.new()
	for lado in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margen.add_theme_constant_override(lado, 40)
	caja.add_child(margen)

	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(ancho, 0)
	vbox.add_theme_constant_override("separation", 22)
	margen.add_child(vbox)
	return [centro, vbox]

func _titulo_panel(vbox, texto):
	var t = Label.new()
	t.text = texto
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Estilo.texto(t, 36, Color(0.75, 0.1, 0.1))
	vbox.add_child(t)

func _boton_volver(vbox):
	var volver = Button.new()
	volver.text = "Volver"
	volver.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	Estilo.boton(volver)
	volver.pressed.connect(_volver)
	vbox.add_child(volver)

func _crear_instrucciones():
	var base = _crear_panel_base(640)
	var vbox = base[1]
	_titulo_panel(vbox, "INSTRUCCIONES")

	var texto = Label.new()
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	Estilo.texto(texto, 22)
	texto.text = "Despiertas encerrado en la recepción de un internado abandonado. La puerta de salida tiene un candado de 4 dígitos: consigue el código completo para escapar.\n\nW A S D: moverte\nShift: correr\nMouse: mirar\nE: interactuar (puertas, notas, objetos)\nF: linterna\nEsc: liberar el mouse (clic para volver a capturarlo)\nCasilleros del ala médica: E para esconderte y E para salir\n\nExplora, junta pistas y no dejes que la entidad te atrape. Si algo se acerca, escóndete o rompe su línea de visión."
	vbox.add_child(texto)

	_boton_volver(vbox)
	return base[0]

func _crear_ajustes():
	var base = _crear_panel_base(520)
	var vbox = base[1]
	_titulo_panel(vbox, "AJUSTES")

	# Volumen
	var vol = _fila_slider(vbox, "Volumen", 0.0, 1.0, 0.05, Ajustes.volumen)
	vol.value_changed.connect(func(v):
		Ajustes.volumen = v
		Ajustes.aplicar())

	# Sensibilidad del mouse
	var sens = _fila_slider(vbox, "Sensibilidad", 0.001, 0.008, 0.0005, Ajustes.sensibilidad)
	sens.value_changed.connect(func(v): Ajustes.sensibilidad = v)

	# Pantalla completa
	var check = CheckButton.new()
	check.text = "Pantalla completa"
	check.focus_mode = Control.FOCUS_NONE
	check.button_pressed = Ajustes.pantalla_completa
	Estilo.texto(check, 22)
	check.toggled.connect(func(activo):
		Ajustes.pantalla_completa = activo
		Ajustes.aplicar())
	vbox.add_child(check)

	_boton_volver(vbox)
	return base[0]

func _fila_slider(vbox, nombre, minimo, maximo, paso, valor):
	var fila = HBoxContainer.new()
	fila.add_theme_constant_override("separation", 20)
	var etiqueta = Label.new()
	etiqueta.text = nombre
	etiqueta.custom_minimum_size = Vector2(150, 0)
	Estilo.texto(etiqueta, 22)
	fila.add_child(etiqueta)
	var slider = HSlider.new()
	slider.min_value = minimo
	slider.max_value = maximo
	slider.step = paso
	slider.value = valor
	slider.focus_mode = Control.FOCUS_NONE
	slider.custom_minimum_size = Vector2(300, 30)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	fila.add_child(slider)
	vbox.add_child(fila)
	return slider

func _on_jugar():
	Inventario.reiniciar_todo()
	Transicion.ir_a("res://scenes/nivel1_recepcion.tscn")

func _on_salir():
	get_tree().quit()
