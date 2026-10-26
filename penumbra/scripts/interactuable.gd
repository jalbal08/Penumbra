extends Area3D
# Objeto con el que se interactua con E. Se configura desde el Inspector:
#   da_llave   -> true: da la llave del sotano (solo una vez). false: solo muestra la nota.
#   prompt     -> texto que sale al acercarse
#   texto_nota -> texto que aparece al presionar E

@export var da_llave = true
@export var prompt = "Presiona E para revisar el archivador"
@export_multiline var texto_nota = "Encontraste la llave del sótano."
# Solo nivel 3: al leer la nota aparece la entidad
@export var dispara_susto = false

var jugador_cerca = false
var ya_recogida = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# Si ya tenemos la llave (por ejemplo al volver a este nivel), no se vuelve a dar
	if da_llave and Inventario.tiene_llave_sotano:
		ya_recogida = true

func _on_body_entered(body):
	if body.name == "Player" and not ya_recogida:
		jugador_cerca = true
		get_tree().call_group("ui_interaccion", "mostrar_prompt", prompt)

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		get_tree().call_group("ui_interaccion", "ocultar_prompt")

func _process(_delta):
	if jugador_cerca and not ya_recogida and not Inventario.ui_bloqueada and Input.is_action_just_pressed("interactuar"):
		if da_llave:
			ya_recogida = true
			Inventario.tiene_llave_sotano = true
		get_tree().call_group("ui_interaccion", "mostrar_nota", texto_nota)
		get_tree().call_group("ui_interaccion", "ocultar_prompt")
		if dispara_susto:
			get_tree().call_group("susto_nivel3", "iniciar")
