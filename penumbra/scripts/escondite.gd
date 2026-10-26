extends Area3D
# Casillero donde el jugador se esconde (nivel 3). E para entrar y E para salir.
# Mientras estas adentro la entidad no te ve. No puedes esconderte si ya te esta persiguiendo.
#   yaw_mirada -> hacia donde mira el jugador al estar adentro, en grados (se configura en el Inspector)

@export var yaw_mirada = 0.0

const SONIDO = preload("res://assets/audio/casillero.wav")

var jugador: Node3D
var cerca = false
var dentro = false
var _pos_prev = Vector3.ZERO
var _rot_prev = Vector3.ZERO
var _capa: CanvasLayer
var _audio: AudioStreamPlayer

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_audio = AudioStreamPlayer.new()
	_audio.stream = SONIDO
	add_child(_audio)
	_crear_capa()

# Vista desde adentro: dos barras negras que dejan solo una rendija
func _crear_capa():
	_capa = CanvasLayer.new()
	_capa.layer = 20
	_capa.visible = false
	add_child(_capa)
	var arriba = ColorRect.new()
	arriba.color = Color(0, 0, 0, 1)
	arriba.anchor_right = 1.0
	arriba.anchor_bottom = 0.42
	arriba.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_capa.add_child(arriba)
	var abajo = ColorRect.new()
	abajo.color = Color(0, 0, 0, 1)
	abajo.anchor_top = 0.58
	abajo.anchor_right = 1.0
	abajo.anchor_bottom = 1.0
	abajo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_capa.add_child(abajo)
	var texto = Label.new()
	texto.text = "Presiona E para salir"
	texto.anchor_top = 0.88
	texto.anchor_right = 1.0
	texto.anchor_bottom = 0.96
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.add_theme_font_size_override("font_size", 22)
	texto.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	_capa.add_child(texto)

func _on_body_entered(body):
	if body.name == "Player":
		jugador = body
		cerca = true
		if not dentro:
			get_tree().call_group("ui_interaccion", "mostrar_prompt", "Presiona E para esconderte")

func _on_body_exited(body):
	if body.name == "Player":
		cerca = false
		get_tree().call_group("ui_interaccion", "ocultar_prompt")

func _process(_delta):
	if dentro:
		if Input.is_action_just_pressed("interactuar"):
			_salir()
		return
	if cerca and not Inventario.ui_bloqueada and Input.is_action_just_pressed("interactuar"):
		if Inventario.perseguido:
			get_tree().call_group("ui_interaccion", "mostrar_nota", "¡Te está viendo!\nNo hay tiempo de esconderse.")
			return
		_entrar()

func _entrar():
	dentro = true
	Inventario.escondido = true
	Inventario.ui_bloqueada = true
	get_tree().call_group("ui_interaccion", "ocultar_prompt")
	_pos_prev = jugador.global_position
	_rot_prev = jugador.rotation
	jugador.set_physics_process(false)
	jugador.get_node("Camera3D/Linterna").visible = false
	jugador.get_node("Camera3D").rotation.x = 0.0
	jugador.global_position = Vector3(global_position.x, _pos_prev.y, global_position.z)
	jugador.rotation = Vector3(0, deg_to_rad(yaw_mirada), 0)
	_audio.play()
	_capa.visible = true

func _salir():
	dentro = false
	_capa.visible = false
	Inventario.escondido = false
	jugador.global_position = _pos_prev
	jugador.rotation = _rot_prev
	jugador.set_physics_process(true)
	_audio.play()
	# Se devuelve el control un instante despues para que esta misma pulsacion de E no active otra cosa
	get_tree().create_timer(0.3).timeout.connect(func(): Inventario.ui_bloqueada = false)
