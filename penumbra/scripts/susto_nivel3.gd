extends Node
# Director del susto del nivel 3.
# La entidad NO esta al empezar. Al leer la nota del medico empiezan sus "visitas":
#   1) AVISO: rugido lejano, luces parpadeando, mensaje y latidos lentos (unos segundos para esconderte)
#   2) VISITA: la entidad aparece en un extremo del pasillo y recorre su ruta; el latido sube mientras se acerca
#   3) Si no te ve, llega al final de la ruta y desaparece. Si te ve te persigue (y si te alcanza sale el susto)
#   4) DESCANSO: unos segundos sin nada y vuelve a avisar
# Si te atrapa, el nivel se reinicia y las visitas regresan solas.

@export var enemigo: Node3D
@export var aviso_primera = 9.0          # segundos de aviso la primera vez (alcanzas a leer la nota)
@export var aviso_visita = 7.0           # segundos de aviso en las siguientes visitas
@export var descanso = 28.0              # segundos tranquilos entre visitas
@export var espera_tras_reinicio = 18.0  # segundos antes de la primera visita despues de que te atrapa
@export var tiempo_maximo_visita = 70.0  # por seguridad, si algo se atora la entidad se va sola

const LATIDO = preload("res://assets/audio/latido.wav")
const RUGIDO = preload("res://assets/audio/rugido.wav")

# Rutas de la entidad (X, Z). Aparece en el extremo mas lejano al jugador.
const RUTA_ESTE_OESTE = [Vector2(12, 0), Vector2(9.5, 0), Vector2(0, 0), Vector2(-9.5, 0), Vector2(-9.5, 5), Vector2(-9.5, 0), Vector2(-12, 0)]
const RUTA_OESTE_ESTE = [Vector2(-12, 0), Vector2(-9.5, 0), Vector2(0, 0), Vector2(9.5, 0), Vector2(7.0, -5.5), Vector2(9.5, 0), Vector2(12, 0)]

enum Estado { REPOSO, ESPERA, AVISO, VISITA, DESCANSO }
var estado = Estado.REPOSO
var iniciado = false
var visitas = 0
var _t = 0.0
var _t_visita = 0.0
var _t_latido = 0.0
var _terminada = false
var _mensaje_dado = false
var _latido: AudioStreamPlayer
var _rugido: AudioStreamPlayer

func _ready():
	add_to_group("susto_nivel3")
	_latido = AudioStreamPlayer.new()
	_latido.stream = LATIDO
	add_child(_latido)
	_rugido = AudioStreamPlayer.new()
	_rugido.stream = RUGIDO
	add_child(_rugido)
	if is_instance_valid(enemigo):
		enemigo.visita_terminada.connect(func(): _terminada = true)
	# Si ya habias leido la nota (por ejemplo despues de que te atrapo), las visitas regresan solas
	if Inventario.susto_iniciado:
		iniciado = true
		_ir_a_espera(espera_tras_reinicio)

# Lo llama la nota del medico al leerla
func iniciar():
	if iniciado:
		return
	iniciado = true
	Inventario.susto_iniciado = true
	_ir_a_espera(1.5)

# Lo llama la entidad cuando empieza a perseguirte
func rugir():
	_rugido.play()

func _ir_a_espera(seg):
	estado = Estado.ESPERA
	_t = seg

func _empezar_aviso():
	estado = Estado.AVISO
	_t = aviso_primera if visitas == 0 else aviso_visita
	_mensaje_dado = false
	_t_latido = 0.0
	_rugido.play()
	get_tree().call_group("luces_nivel", "susto", min(_t, 6.0))

func _aparecer():
	estado = Estado.VISITA
	visitas += 1
	_terminada = false
	_t_visita = 0.0
	var jug = get_parent().get_node_or_null("Player")
	var desde_este = true
	if jug:
		desde_este = abs(12.0 - jug.global_position.x) >= abs(-12.0 - jug.global_position.x)
	var ruta = RUTA_ESTE_OESTE if desde_este else RUTA_OESTE_ESTE
	enemigo.aparecer(ruta.duplicate())

func _terminar_visita():
	if is_instance_valid(enemigo) and enemigo.activo:
		enemigo.desaparecer()
	estado = Estado.DESCANSO
	_t = descanso

func _process(delta):
	if not iniciado or not is_instance_valid(enemigo):
		return
	match estado:
		Estado.ESPERA:
			_t -= delta
			if _t <= 0.0:
				_empezar_aviso()
		Estado.AVISO:
			_t -= delta
			# La primera vez el mensaje espera a que alcances a leer la nota
			var total = aviso_primera if visitas == 0 else aviso_visita
			var espera_msg = min(5.5, aviso_primera * 0.6) if visitas == 0 else 0.0
			if not _mensaje_dado and total - _t >= espera_msg:
				_mensaje_dado = true
				if visitas == 0:
					get_tree().call_group("ui_interaccion", "mostrar_nota", "Algo se acerca...\nEscóndete en un casillero (E) o aléjate del pasillo.")
				else:
					get_tree().call_group("ui_interaccion", "mostrar_nota", "Algo se acerca...")
			# Latido lento durante el aviso
			_t_latido += delta
			if _t_latido >= 1.2:
				_t_latido = 0.0
				_latido.volume_db = -14.0
				_latido.play()
			if _t <= 0.0:
				_aparecer()
		Estado.VISITA:
			_t_visita += delta
			_latir_segun_distancia(delta)
			if _terminada or _t_visita > tiempo_maximo_visita:
				_terminar_visita()
		Estado.DESCANSO:
			_t -= delta
			if _t <= 0.0:
				_empezar_aviso()

# El latido sube de ritmo y de volumen mientras la entidad se acerca
func _latir_segun_distancia(delta):
	var jug = get_parent().get_node_or_null("Player")
	if jug == null:
		return
	var d = Vector2(jug.global_position.x - enemigo.global_position.x, jug.global_position.z - enemigo.global_position.z).length()
	var cerca = clamp((d - 3.0) / 19.0, 0.0, 1.0)   # 0 = encima, 1 = lejos
	var intervalo = lerp(0.4, 1.3, cerca)
	_t_latido += delta
	if _t_latido >= intervalo:
		_t_latido = 0.0
		_latido.volume_db = lerp(-3.0, -22.0, cerca)
		_latido.play()
