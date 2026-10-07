extends Area3D

var jugador_cerca = false
var ya_recogida = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player" and not ya_recogida:
		jugador_cerca = true
		get_tree().call_group("ui_interaccion", "mostrar_prompt", "Presiona E para revisar el archivador")

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		get_tree().call_group("ui_interaccion", "ocultar_prompt")

func _process(_delta):
	if jugador_cerca and not ya_recogida and Input.is_action_just_pressed("interactuar"):
		ya_recogida = true
		Inventario.tiene_llave_sotano = true
		get_tree().call_group("ui_interaccion", "mostrar_nota", "Encontraste la llave del sótano.")
		get_tree().call_group("ui_interaccion", "ocultar_prompt")
