extends Area3D
# Puerta del nivel 1 que lleva al sotano. Necesita la llave del sotano.

@export var puerta_visual: Node3D
@export_file("*.tscn") var escena_destino = "res://scenes/nivel2_sotano.tscn"

var jugador_cerca = false
var abierta = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# Si ya la abrimos antes (al volver del ala medica), se queda abierta
	if Inventario.sotano_abierto:
		abierta = true
		if puerta_visual:
			puerta_visual.visible = false

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
	if jugador_cerca and not abierta and Inventario.tiene_llave_sotano and not Inventario.ui_bloqueada and Input.is_action_just_pressed("interactuar"):
		abierta = true
		Inventario.sotano_abierto = true
		if puerta_visual:
			puerta_visual.visible = false
		get_tree().call_group("ui_interaccion", "ocultar_prompt")
		get_tree().call_group("ui_interaccion", "mostrar_nota", "Abres la puerta. Una escalera oscura baja al sótano...")
		await get_tree().create_timer(1.5).timeout
		Transicion.ir_a(escena_destino)
