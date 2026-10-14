extends Node3D

const SECUENCIA = [1, 2, 3]
var progreso = 0
var resuelto = false

@onready var texto = $Pantalla/Label3D

func _ready():
	texto.text = "--"

func palanca_presionada(numero):
	if resuelto:
		return
	if numero == SECUENCIA[progreso]:
		progreso += 1
		get_tree().call_group("ui_interaccion", "mostrar_nota", "Palanca " + str(numero) + " activada (" + str(progreso) + "/3)")
		if progreso == SECUENCIA.size():
			resuelto = true
			texto.text = "92"
			get_tree().call_group("ui_interaccion", "mostrar_nota", "El panel se desbloquea.\n\nÚltimos dígitos del código: - - 9 2")
	else:
		progreso = 0
		texto.text = "ERR"
		get_tree().call_group("ui_interaccion", "mostrar_nota", "Orden incorrecto. El panel se reinicia.")
		await get_tree().create_timer(1.5).timeout
		if not resuelto:
			texto.text = "--"
