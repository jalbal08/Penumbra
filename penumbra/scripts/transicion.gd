extends CanvasLayer
# Fundido a negro entre escenas (niveles, reinicio, final).
# Uso: Transicion.ir_a("res://scenes/nivel2_sotano.tscn")  o  Transicion.recargar()

var _rect: ColorRect
var _ocupado = false

func _ready():
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rect = ColorRect.new()
	_rect.color = Color(0, 0, 0, 0)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_rect)

func ir_a(ruta, duracion = 0.6):
	await _cambiar(duracion, func(): get_tree().change_scene_to_file(ruta))

func recargar(duracion = 0.6):
	await _cambiar(duracion, func(): get_tree().reload_current_scene())

func _cambiar(duracion, accion):
	if _ocupado:
		return
	_ocupado = true
	Inventario.ui_bloqueada = true
	var t = create_tween()
	t.tween_property(_rect, "color:a", 1.0, duracion)
	await t.finished
	accion.call()
	await get_tree().process_frame
	await get_tree().process_frame
	var t2 = create_tween()
	t2.tween_property(_rect, "color:a", 0.0, duracion)
	await t2.finished
	Inventario.ui_bloqueada = false
	_ocupado = false
