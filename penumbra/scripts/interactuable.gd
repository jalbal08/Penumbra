extends Area3D

@export var nota_texto: String = "Los primeros dos dígitos de la puerta de salida están guardados en la caja fuerte del sótano. La llave del sótano está en el archivador."

var jugador_cerca = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		jugador_cerca = true
		get_tree().call_group("ui_interaccion", "mostrar_prompt", "Presiona E para revisar")

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		get_tree().call_group("ui_interaccion", "ocultar_prompt")

func _process(_delta):
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		get_tree().call_group("ui_interaccion", "mostrar_nota", nota_texto)
