extends Node
# Ajustes del juego (volumen, pantalla completa, sensibilidad del mouse).
# Se guardan en user://ajustes.cfg para que se conserven al cerrar el juego.

const RUTA = "user://ajustes.cfg"

var volumen = 0.8
var pantalla_completa = false
var sensibilidad = 0.003

func _ready():
	cargar()
	aplicar()

func aplicar():
	AudioServer.set_bus_volume_db(0, linear_to_db(max(volumen, 0.0001)))
	AudioServer.set_bus_mute(0, volumen <= 0.001)
	var esta_en_completa = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	if pantalla_completa != esta_en_completa:
		if pantalla_completa:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func guardar():
	var cfg = ConfigFile.new()
	cfg.set_value("ajustes", "volumen", volumen)
	cfg.set_value("ajustes", "pantalla_completa", pantalla_completa)
	cfg.set_value("ajustes", "sensibilidad", sensibilidad)
	cfg.save(RUTA)

func cargar():
	var cfg = ConfigFile.new()
	if cfg.load(RUTA) != OK:
		return
	volumen = cfg.get_value("ajustes", "volumen", volumen)
	pantalla_completa = cfg.get_value("ajustes", "pantalla_completa", pantalla_completa)
	sensibilidad = cfg.get_value("ajustes", "sensibilidad", sensibilidad)
