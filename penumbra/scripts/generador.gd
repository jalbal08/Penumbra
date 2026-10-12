extends Area3D

@export var luz: DirectionalLight3D

var jugador_cerca = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player" and not Inventario.generador_encendido:
		jugador_cerca = true
		if Inventario.tiene_los_3_fusibles():
			get_tree().call_group("ui_interaccion", "mostrar_prompt", "Presiona E para encender el generador")
		else:
			get_tree().call_group("ui_interaccion", "mostrar_prompt", "Faltan fusibles (" + str(Inventario.fusibles_encontrados) + "/3)")

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		get_tree().call_group("ui_interaccion", "ocultar_prompt")

func _process(_delta):
	if jugador_cerca and not Inventario.generador_encendido and Inventario.tiene_los_3_fusibles() and Input.is_action_just_pressed("interactuar"):
		Inventario.generador_encendido = true
		if luz:
			luz.light_energy = 0.6
		get_tree().call_group("ui_interaccion", "mostrar_nota", "El generador se enciende. Se escucha un clic cerca de la caja fuerte.")
		get_tree().call_group("ui_interaccion", "ocultar_prompt")
