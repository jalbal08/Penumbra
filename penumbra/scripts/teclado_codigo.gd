extends CanvasLayer
# Candado digital de 4 digitos. Se crea por codigo desde puerta_salida.gd

const Estilo = preload("res://scripts/estilo_ui.gd")

signal codigo_ingresado(codigo)
signal cancelado

var _codigo = ""
var _pantalla: Label
var _mensaje: Label

func _ready():
	layer = 50
	Inventario.ui_bloqueada = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_construir()
	_actualizar()

func _construir():
	var oscuro = ColorRect.new()
	oscuro.color = Color(0, 0, 0, 0.65)
	oscuro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(oscuro)

	var centro = CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var caja = PanelContainer.new()
	Estilo.panel(caja)
	centro.add_child(caja)

	var margen = MarginContainer.new()
	for lado in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margen.add_theme_constant_override(lado, 30)
	caja.add_child(margen)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margen.add_child(vbox)

	var titulo = Label.new()
	titulo.text = "CANDADO DIGITAL"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Estilo.texto(titulo, 28, Color(0.75, 0.1, 0.1))
	vbox.add_child(titulo)

	_pantalla = Label.new()
	_pantalla.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Estilo.texto(_pantalla, 44, Color(0.9, 0.9, 0.9))
	vbox.add_child(_pantalla)

	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	vbox.add_child(grid)
	for n in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "Borrar", "0", "OK"]:
		var b = Button.new()
		b.text = n
		Estilo.boton(b, 90, 55, 22)
		b.pressed.connect(_on_tecla.bind(n))
		grid.add_child(b)

	_mensaje = Label.new()
	_mensaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Estilo.texto(_mensaje, 20, Color(0.9, 0.3, 0.3))
	vbox.add_child(_mensaje)

	var cancelar = Button.new()
	cancelar.text = "Cancelar"
	cancelar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	Estilo.boton(cancelar, 200, 45, 20)
	cancelar.pressed.connect(_cancelar)
	vbox.add_child(cancelar)

func _on_tecla(tecla):
	if tecla == "Borrar":
		_codigo = _codigo.left(_codigo.length() - 1)
	elif tecla == "OK":
		_confirmar()
		return
	elif _codigo.length() < 4:
		_codigo += tecla
	_mensaje.text = ""
	_actualizar()

func _actualizar():
	var t = ""
	for i in range(4):
		t += (_codigo[i] if _codigo.length() > i else "_") + " "
	_pantalla.text = t.strip_edges()

func _confirmar():
	if _codigo.length() < 4:
		_mensaje.text = "Ingresa los 4 dígitos"
		return
	codigo_ingresado.emit(_codigo)

func mostrar_error():
	_codigo = ""
	_mensaje.text = "CÓDIGO INCORRECTO"
	_actualizar()

func _cancelar():
	cerrar()
	cancelado.emit()

# Cierra el teclado y devuelve el control al jugador
func cerrar():
	Inventario.ui_bloqueada = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()

func _unhandled_input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var k = event.keycode
	if k >= KEY_0 and k <= KEY_9:
		_on_tecla(str(k - KEY_0))
	elif k >= KEY_KP_0 and k <= KEY_KP_9:
		_on_tecla(str(k - KEY_KP_0))
	elif k == KEY_BACKSPACE:
		_on_tecla("Borrar")
	elif k == KEY_ENTER or k == KEY_KP_ENTER:
		_confirmar()
	elif k == KEY_ESCAPE:
		_cancelar()
	else:
		return
	get_viewport().set_input_as_handled()
