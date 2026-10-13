extends CharacterBody3D

@export var VEL_PATRULLA = 1.5
@export var VEL_PERSECUCION = 2.6
@export var DISTANCIA_ATRAPAR = 1.3
@export var DETECCION_NORMAL = 4.0
@export var DETECCION_CON_LINTERNA = 8.0
@export var DISTANCIA_PERDER = 12.0
@export var punto_inicial: int = 0

const COLOR_PATRULLA = Color(0.35, 0.02, 0.02)
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

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var dist = Vector2(jugador.global_position.x - global_position.x, jugador.global_position.z - global_position.z).length()

	# Detección
	var rango = DETECCION_CON_LINTERNA if linterna.visible else DETECCION_NORMAL
	if not persiguiendo and dist < rango:
		persiguiendo = true
		material.albedo_color = COLOR_PERSECUCION
	elif persiguiendo and dist > DISTANCIA_PERDER:
		persiguiendo = false
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
