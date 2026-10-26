extends Area3D
# Puerta metalica de la recepcion con el candado digital de 4 digitos (final del juego).

const TECLADO = preload("res://scripts/teclado_codigo.gd")

var jugador_cerca = false
var teclado = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		jugador_cerca = true
		get_tree().call_group("ui_interaccion", "mostrar_prompt", "Presiona E para usar el candado digital")

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false
		get_tree().call_group("ui_interaccion", "ocultar_prompt")

func _process(_delta):
	if jugador_cerca and teclado == null and not Inventario.ui_bloqueada and Input.is_action_just_pressed("interactuar"):
		if Inventario.codigo_completo():
			_abrir_teclado()
		else:
			get_tree().call_group("ui_interaccion", "mostrar_nota", "El candado pide un código de 4 dígitos.\n\nTodavía no lo tienes completo: " + Inventario.texto_codigo())

func _abrir_teclado():
	get_tree().call_group("ui_interaccion", "ocultar_prompt")
	teclado = TECLADO.new()
	add_child(teclado)
	teclado.codigo_ingresado.connect(_on_codigo)
	teclado.cancelado.connect(func(): teclado = null)

func _on_codigo(codigo):
	if codigo == Inventario.CODIGO_CORRECTO:
		# No devolvemos el control al jugador: pasamos directo a la pantalla final
		teclado.queue_free()
		teclado = null
		Transicion.ir_a("res://scenes/fin.tscn", 1.2)
	else:
		teclado.mostrar_error()
