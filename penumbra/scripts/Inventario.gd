extends Node
# Estado global del juego. Todos los niveles leen y escriben aqui,
# asi las piezas (llave, fusibles, generador, caja fuerte, panel, puerta final)
# quedan conectadas entre si.

const FUSIBLES_NECESARIOS = 3
const CODIGO_CORRECTO = "4892"

# Nivel 1
var tiene_llave_sotano = false
var sotano_abierto = false

# Nivel 2
var fusibles_encontrados = 0
var generador_encendido = false
var tiene_llave_ala_medica = false
var codigo_parte1 = ""   # primeros 2 digitos (caja fuerte)

# Nivel 3
var codigo_parte2 = ""   # ultimos 2 digitos (panel de palancas)
var susto_iniciado = false   # true cuando ya se leyo la nota del medico y aparece la entidad
var escondido = false   # true mientras el jugador esta dentro de un casillero
var perseguido = false   # true mientras la entidad esta persiguiendo al jugador

# Si es true el jugador no se mueve (teclado del candado, transiciones)
var ui_bloqueada = false

func tiene_los_3_fusibles():
	return fusibles_encontrados >= FUSIBLES_NECESARIOS

func codigo_completo():
	return codigo_parte1 != "" and codigo_parte2 != ""

func reiniciar_todo():
	tiene_llave_sotano = false
	sotano_abierto = false
	fusibles_encontrados = 0
	generador_encendido = false
	tiene_llave_ala_medica = false
	codigo_parte1 = ""
	codigo_parte2 = ""
	susto_iniciado = false
	escondido = false
	perseguido = false
	ui_bloqueada = false

# Cuando la entidad atrapa al jugador se reinicia solo el progreso del nivel actual
func reiniciar_nivel_actual():
	var escena = get_tree().current_scene
	if escena == null:
		return
	var ruta = escena.scene_file_path
	if ruta.ends_with("nivel2_sotano.tscn"):
		fusibles_encontrados = 0
		generador_encendido = false
		tiene_llave_ala_medica = false
		codigo_parte1 = ""
	elif ruta.ends_with("nivel3_ala_medica.tscn"):
		codigo_parte2 = ""

func texto_codigo():
	var t = ""
	for i in range(2):
		t += (codigo_parte1[i] if codigo_parte1.length() > i else "_") + " "
	for i in range(2):
		t += (codigo_parte2[i] if codigo_parte2.length() > i else "_") + " "
	return t.strip_edges()

func objetivo_actual():
	if not tiene_llave_sotano:
		return "Busca la llave del sótano (revisa el escritorio y el archivador)"
	if not tiene_llave_ala_medica:
		if not generador_encendido:
			if not tiene_los_3_fusibles():
				return "Encuentra los 3 fusibles del sótano (" + str(fusibles_encontrados) + "/3)"
			return "Enciende el generador"
		return "Abre la caja fuerte"
	if codigo_parte2 == "":
		if susto_iniciado:
			return "Panel de control: palanca azul, roja y verde. Si algo se acerca, escóndete en un casillero (E)"
		return "Busca la nota del médico en la farmacia y resuelve el panel de control"
	return "Regresa a la recepción e ingresa el código en la puerta metálica"
