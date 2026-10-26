extends CanvasLayer
# Susto a pantalla completa cuando la entidad te atrapa (solo se usa en el nivel 3).
# Uso: await Susto.reproducir()

const CARA = preload("res://assets/imagenes/cara_susto.png")
const GRITO = preload("res://assets/audio/grito.wav")
const DURACION = 1.9

var _raiz: Control
var _cara: TextureRect
var _rojo: ColorRect
var _audio: AudioStreamPlayer
var _activo = false
var _t = 0.0

func _ready():
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS

	_raiz = Control.new()
	_raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.visible = false
	add_child(_raiz)

	var fondo = ColorRect.new()
	fondo.color = Color(0, 0, 0, 1)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(fondo)

	_cara = TextureRect.new()
	_cara.texture = CARA
	_cara.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cara.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_cara.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_cara.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cara.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(_cara)

	_rojo = ColorRect.new()
	_rojo.color = Color(0.8, 0.0, 0.0, 0.0)
	_rojo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rojo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(_rojo)

	_audio = AudioStreamPlayer.new()
	_audio.stream = GRITO
	add_child(_audio)

func reproducir():
	if _activo:
		return
	_activo = true
	_t = 0.0
	Inventario.ui_bloqueada = true
	_raiz.visible = true
	_audio.play()
	await get_tree().create_timer(DURACION).timeout
	_raiz.visible = false
	_activo = false

func _process(delta):
	if not _activo:
		return
	_t += delta
	# La cara tiembla y late; el rojo parpadea
	_cara.pivot_offset = _cara.size / 2.0
	_cara.scale = Vector2.ONE * (1.14 + 0.05 * sin(_t * 45.0))
	_cara.position = Vector2(randf_range(-22, 22), randf_range(-22, 22))
	_rojo.color.a = 0.28 * (0.5 + 0.5 * sin(_t * 28.0)) * clamp(1.6 - _t, 0.0, 1.0)
