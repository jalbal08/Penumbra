extends Area3D

var jugador_cerca = false
var ya_recogido = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player" and not ya_recogido:
		jugador_cerca = true
		get_tree().call_group("ui_interaccion", "mostrar_prompt", "Presiona E para tomar el fusible")

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		get_tree().call_group("ui_interaccion", "ocultar_prompt")

func _process(_delta):
	if jugador_cerca and not ya_recogido and Input.is_action_just_pressed("interactuar"):
		ya_recogido = true
		Inventario.fusibles_encontrados += 1
		get_tree().call_group("ui_interaccion", "mostrar_nota", "Fusible recogido (" + str(Inventario.fusibles_encontrados) + "/3)")
		get_tree().call_group("ui_interaccion", "ocultar_prompt")
		queue_free()
