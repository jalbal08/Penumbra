extends CharacterBody3D

@export var VEL_PATRULLA = 1.5
@export var VEL_PERSECUCION = 2.6
@export var DISTANCIA_ATRAPAR = 1.3
@export var DETECCION_NORMAL = 4.0
@export var DETECCION_CON_LINTERNA = 8.0
@export var DISTANCIA_PERDER = 12.0
@export var punto_inicial: int = 0
@export var ANGULO_VISION = 100.0
@export var TIEMPO_DETECCION = 0.8
@export var TIEMPO_PERDER = 3.0
@export var RANGO_OIDO = 1.5

const COLOR_PATRULLA = Color(0.35, 0.02, 0.02)
const COLOR_ALERTA = Color(0.95, 0.5, 0.05)
const COLOR_PERSECUCION = Color(1.0, 0.1, 0.1)

# Puntos por los que patrulla (X, Z)
var puntos = [
	Vector2(-6, -1),
	Vector2(6, -1),
	Vector2(6, 3),
	Vector2(-5, 3),
]
var punto_actual = 0
var persiguiendo = false
var tiempo_visto = 0.0
var tiempo_sin_ver = 0.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jugador: Node3D
var linterna: Node3D
var material: StandardMaterial3D

func _ready():
	punto_actual = punto_inicial
	jugador = get_parent().get_node("Player")
	linterna = jugador.get_node("Camera3D/Linterna")
	material = StandardMaterial3D.new()
	material.albedo_color = COLOR_PATRULLA
	$CSGBox3D.material = material

func puede_ver_jugador(dist):
	var rango = DETECCION_CON_LINTERNA if linterna.visible else DETECCION_NORMAL
	if dist > rango:
		return false
	# Oído: si está muy cerca te percibe aunque no lo mires
	if dist < RANGO_OIDO:
		return true
	# Cono de visión
	var hacia = jugador.global_position - global_position
	hacia.y = 0
	var frente = -global_transform.basis.z
	frente.y = 0
	if frente.normalized().dot(hacia.normalized()) < cos(deg_to_rad(ANGULO_VISION / 2.0)):
		return false
	# Línea de visión (las paredes la bloquean)
	var espacio = get_world_3d().direct_space_state
	var origen = global_position + Vector3(0, 0.6, 0)
	var final = jugador.global_position + Vector3(0, 0.6, 0)
	var consulta = PhysicsRayQueryParameters3D.create(origen, final)
	consulta.exclude = [get_rid()]
	var resultado = espacio.intersect_ray(consulta)
	if resultado.is_empty():
		return true
	return resultado.collider == jugador

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var dist = Vector2(jugador.global_position.x - global_position.x, jugador.global_position.z - global_position.z).length()
	var lo_ve = puede_ver_jugador(dist)

	# Detección
	if not persiguiendo:
		if lo_ve:
			tiempo_visto += delta
			material.albedo_color = COLOR_ALERTA
			if tiempo_visto >= TIEMPO_DETECCION:
				persiguiendo = true
				tiempo_sin_ver = 0.0
				material.albedo_color = COLOR_PERSECUCION
		else:
			tiempo_visto = max(0.0, tiempo_visto - delta)
			if tiempo_visto == 0.0:
				material.albedo_color = COLOR_PATRULLA
	else:
		if lo_ve:
			tiempo_sin_ver = 0.0
		else:
			tiempo_sin_ver += delta
		if tiempo_sin_ver > TIEMPO_PERDER or dist > DISTANCIA_PERDER:
			persiguiendo = false
			tiempo_visto = 0.0
			material.albedo_color = COLOR_PATRULLA

	# Atrapar
	if persiguiendo and dist < DISTANCIA_ATRAPAR:
		Inventario.reiniciar_sotano()
		get_tree().reload_current_scene()
		return

	# Movimiento
	var destino: Vector3
	var vel: float
	if persiguiendo:
		destino = jugador.global_position
		vel = VEL_PERSECUCION
	else:
		var p = puntos[punto_actual]
		destino = Vector3(p.x, global_position.y, p.y)
		vel = VEL_PATRULLA
		if Vector2(destino.x - global_position.x, destino.z - global_position.z).length() < 0.5:
			punto_actual = (punto_actual + 1) % puntos.size()

	var direccion = destino - global_position
	direccion.y = 0
	if direccion.length() > 0.1:
		direccion = direccion.normalized()
		velocity.x = direccion.x * vel
		velocity.z = direccion.z * vel
		look_at(Vector3(destino.x, global_position.y, destino.z), Vector3.UP)

	move_and_slide()
