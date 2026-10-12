extends Area3D

var jugador_cerca = false
var abierta = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player" and not abierta:
		jugador_cerca = true
		if Inventario.generador_encendido:
			get_tree().call_group("ui_interaccion", "mostrar_prompt", "Presiona E para abrir la caja fuerte")
		else:
			get_tree().call_group("ui_interaccion", "mostrar_prompt", "La caja fuerte no tiene energía")

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		get_tree().call_group("ui_interaccion", "ocultar_prompt")

func _process(_delta):
	if jugador_cerca and not abierta and Inventario.generador_encendido and Input.is_action_just_pressed("interactuar"):
		abierta = true
		Inventario.tiene_llave_ala_medica = true
		get_tree().call_group("ui_interaccion", "mostrar_nota", "La caja fuerte se abre.\n\nPrimeros dígitos del código: 4 8 - -\n\nTambién encuentras la llave del ala médica.")
		get_tree().call_group("ui_interaccion", "ocultar_prompt")
