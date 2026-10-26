extends OmniLight3D
# Luz del juego. Opciones desde el Inspector:
#   parpadea                  -> la luz titila (ambiente de terror)
#   controlada_por_generador  -> empieza apagada y se enciende al activar el generador del sotano
# Ademas, el nivel 3 puede hacer que todas las luces parpadeen fuerte por un rato (susto()).

@export var parpadea = false
@export var controlada_por_generador = false

var _base = 1.0
var _encendida = true
var _t = 0.0
var _siguiente = 0.1
var _susto_t = 0.0
var _susto_paso = 0.0

func _ready():
	add_to_group("luces_nivel")
	_base = light_energy
	if controlada_por_generador:
		add_to_group("luces_generador")
		if not Inventario.generador_encendido:
			_encendida = false
			light_energy = 0.0

func encender():
	if _encendida:
		return
	_encendida = true
	# parpadeo corto al volver la energia y luego se queda prendida
	var tw = create_tween()
	tw.tween_property(self, "light_energy", _base, 0.08)
	tw.tween_property(self, "light_energy", 0.0, 0.08)
	tw.tween_property(self, "light_energy", _base, 0.08)
	tw.tween_property(self, "light_energy", 0.2 * _base, 0.1)
	tw.tween_property(self, "light_energy", _base, 0.3)

# Parpadeo fuerte durante "duracion" segundos (aviso de que viene la entidad)
func susto(duracion):
	_susto_t = duracion

func _process(delta):
	if not _encendida:
		return
	if _susto_t > 0.0:
		_susto_t -= delta
		_susto_paso -= delta
		if _susto_paso <= 0.0:
			_susto_paso = randf_range(0.04, 0.16)
			light_energy = _base * (randf_range(0.0, 0.15) if randf() < 0.6 else randf_range(0.7, 1.1))
		if _susto_t <= 0.0:
			light_energy = _base
		return
	if not parpadea:
		return
	_t += delta
	if _t >= _siguiente:
		_t = 0.0
		if randf() < 0.18:
			light_energy = _base * randf_range(0.05, 0.4)
			_siguiente = randf_range(0.04, 0.12)
		else:
			light_energy = _base * randf_range(0.85, 1.0)
			_siguiente = randf_range(0.1, 0.6)
