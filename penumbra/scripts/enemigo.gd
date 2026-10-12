extends CharacterBody3D

const VELOCIDAD = 2.0
const DISTANCIA_ATRAPAR = 1.3

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jugador: Node3D

func _ready():
	jugador = get_parent().get_node("Player")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if jugador:
		var direccion = jugador.global_position - global_position
		direccion.y = 0
		if direccion.length() < DISTANCIA_ATRAPAR:
			Inventario.reiniciar_sotano()
			get_tree().reload_current_scene()
			return
		direccion = direccion.normalized()
		velocity.x = direccion.x * VELOCIDAD
		velocity.z = direccion.z * VELOCIDAD
		look_at(Vector3(jugador.global_position.x, global_position.y, jugador.global_position.z), Vector3.UP)

	move_and_slide()
