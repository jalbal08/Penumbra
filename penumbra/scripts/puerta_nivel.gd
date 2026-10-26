extends Area3D
# Puerta generica para pasar de un nivel a otro.
# Se configura desde el Inspector:
#   escena_destino -> escena a la que lleva
#   requisito      -> nombre de una variable de Inventario que debe ser verdadera
#                     (por ejemplo tiene_llave_ala_medica o codigo_parte2). Vacio = sin requisito.

@export var puerta_visual: Node3D
@export_file("*.tscn") var escena_destino = ""
@export var requisito = ""
@export var prompt_abrir = "Presiona E para abrir la puerta"
@export var prompt_bloqueada = "La puerta está cerrada"
@export_multiline var texto_al_abrir = "Abres la puerta..."

var jugador_cerca = false
var abierta = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _cumple_requisito():
	if requisito == "":
		return true
	var valor = Inventario.get(requisito)
	if valor == null:
		return false
	if valor is String:
		return valor != ""
	return valor == true

func _on_body_entered(body):
	if body.name == "Player" and not abierta:
		jugador_cerca = true
		if _cumple_requisito():
			get_tree().call_group("ui_interaccion", "mostrar_prompt", prompt_abrir)
		else:
			get_tree().call_group("ui_interaccion", "mostrar_prompt", prompt_bloqueada)

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		get_tree().call_group("ui_interaccion", "ocultar_prompt")

func _process(_delta):
	if jugador_cerca and not abierta and not Inventario.ui_bloqueada and Input.is_action_just_pressed("interactuar"):
		if not _cumple_requisito():
			get_tree().call_group("ui_interaccion", "mostrar_nota", prompt_bloqueada)
			return
		abierta = true
		if puerta_visual:
			puerta_visual.visible = false
		get_tree().call_group("ui_interaccion", "ocultar_prompt")
		get_tree().call_group("ui_interaccion", "mostrar_nota", texto_al_abrir)
		await get_tree().create_timer(1.5).timeout
		Transicion.ir_a(escena_destino)
