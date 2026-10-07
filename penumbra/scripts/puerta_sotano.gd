extends Area3D

@export var puerta_visual: Node3D

var jugador_cerca = false
var abierta = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player" and not abierta:
		jugador_cerca = true
		if Inventario.tiene_llave_sotano:
			get_tree().call_group("ui_interaccion", "mostrar_prompt", "Presiona E para abrir la puerta")
		else:
			get_tree().call_group("ui_interaccion", "mostrar_prompt", "Necesitas la llave del sótano")

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		get_tree().call_group("ui_interaccion", "ocultar_prompt")

func _process(_delta):
	if jugador_cerca and not abierta and Inventario.tiene_llave_sotano and Input.is_action_just_pressed("interactuar"):
		abierta = true
		if puerta_visual:
			puerta_visual.visible = false
		get_tree().call_group("ui_interaccion", "ocultar_prompt")
