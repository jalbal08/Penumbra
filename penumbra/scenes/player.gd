extends CharacterBody3D

const SPEED = 3.0
const RUN_SPEED = 5.5
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D
@onready var linterna = $Camera3D/Linterna

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		linterna.visible = not linterna.visible

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("mover_izquierda", "mover_derecha", "mover_adelante", "mover_atras")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var current_speed = SPEED
	if Input.is_action_pressed("correr"):
		current_speed = RUN_SPEED
		

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
