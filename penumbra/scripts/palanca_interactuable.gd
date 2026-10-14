extends Area3D

var jugador_cerca = false
var numero = 0

func _ready():
	# El número sale del nombre del nodo: Palanca1 = 1, Palanca2 = 2, Palanca3 = 3
	numero = int(str(name).right(1))
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		jugador_cerca = true
		get_tree().call_group("ui_interaccion", "mostrar_prompt", "Presiona E para activar la palanca")

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		get_tree().call_group("ui_interaccion", "ocultar_prompt")

func _process(_delta):
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		get_parent().palanca_presionada(numero)
