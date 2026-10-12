extends Node

var tiene_llave_sotano = false
var fusibles_encontrados = 0
const FUSIBLES_NECESARIOS = 3
var generador_encendido = false
var tiene_llave_ala_medica = false

func tiene_los_3_fusibles():
	return fusibles_encontrados >= FUSIBLES_NECESARIOS

func reiniciar_sotano():
	fusibles_encontrados = 0
	generador_encendido = false
	tiene_llave_ala_medica = false
