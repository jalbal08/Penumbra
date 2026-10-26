extends CharacterBody3D

@export var VEL_PATRULLA = 1.5
@export var VEL_PERSECUCION = 2.6
@export var DISTANCIA_ATRAPAR = 1.3
@export var DETECCION_NORMAL = 4.0
@export var DETECCION_CON_LINTERNA = 8.0
@export var DISTANCIA_PERDER = 12.0
@export var punto_inicial: int = 0
@export var ANGULO_VISION = 100.0
@export var TIEMPO_DETECCION = 0.8
@export var TIEMPO_PERDER = 3.0
@export var RANGO_OIDO = 1.5
# Puntos (X, Z) por los que patrulla. Se editan en el Inspector de cada enemigo.
@export var puntos_patrulla: PackedVector2Array = PackedVector2Array()
# Nivel 3: la entidad empieza oculta y aparece con aparecer(); al atraparte sale el susto a pantalla completa
@export var empieza_oculto = false
@export var susto_al_atrapar = false
# Nivel 3: la entidad hace "visitas": aparece, recorre su ruta y desaparece al llegar al final
@export var modo_visita = false
signal visita_terminada

const COLOR_PATRULLA = Color(0.35, 0.02, 0.02)
const COLOR_ALERTA = Color(0.95, 0.5, 0.05)
const COLOR_PERSECUCION = Color(1.0, 0.1, 0.1)

# Puntos por defecto si no se configuran en el Inspector
var puntos = [
	Vector2(-6, -1),
	Vector2(6, -1),
	Vector2(6, 3),
	Vector2(-5, 3),
]
var punto_actual = 0
var persiguiendo = false
var tiempo_visto = 0.0
var tiempo_sin_ver = 0.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jugador: Node3D
var linterna: Node3D
var material: StandardMaterial3D

var nav: NavigationAgent3D
var activo = true
var _t_repath = 0.0
var _ultimo_destino = Vector3(INF, INF, INF)

func _ready():
	if puntos_patrulla.size() > 0:
		puntos = []
		for p in puntos_patrulla:
			puntos.append(p)
	punto_actual = punto_inicial % puntos.size()
	jugador = get_parent().get_node("Player")
	linterna = jugador.get_node("Camera3D/Linterna")
	nav = get_node_or_null("NavigationAgent3D")
	material = StandardMaterial3D.new()
	material.albedo_color = COLOR_PATRULLA
	# El color de alerta cambia todo el cuerpo (menos los ojos)
	for c in find_children("*", "CSGShape3D", true, false):
		if not c.name.begins_with("Ojo"):
			c.material = material
	if empieza_oculto:
		_ocultar()

func _ocultar():
	activo = false
	visible = false
	set_physics_process(false)
	$CollisionShape3D.disabled = true

# Hace aparecer a la entidad en el punto donde esta colocada en la escena
func aparecer(ruta: Array = []):
	if activo:
		return
	if ruta.size() > 0:
		puntos = ruta
		punto_actual = 1 if ruta.size() > 1 else 0
		global_position = Vector3(ruta[0].x, 1.0, ruta[0].y)
		velocity = Vector3.ZERO
	persiguiendo = false
	tiempo_visto = 0.0
	tiempo_sin_ver = 0.0
	material.albedo_color = COLOR_PATRULLA
	activo = true
	visible = true
	$CollisionShape3D.disabled = false
	set_physics_process(true)

# La entidad se va y desaparece (fin de la visita)
func desaparecer():
	persiguiendo = false
	Inventario.perseguido = false
	_ocultar()
	global_position = Vector3(0, -30, 0)

func puede_ver_jugador(dist):
	# Si el jugador esta escondido en un casillero no lo ve
	if Inventario.escondido:
		return false
	var rango = DETECCION_CON_LINTERNA if linterna.visible else DETECCION_NORMAL
	if dist > rango:
		return false
	# Oído: si está muy cerca te percibe aunque no lo mires
	if dist < RANGO_OIDO:
		return true
	# Cono de visión
	var hacia = jugador.global_position - global_position
	hacia.y = 0
	var frente = -global_transform.basis.z
	frente.y = 0
	if frente.normalized().dot(hacia.normalized()) < cos(deg_to_rad(ANGULO_VISION / 2.0)):
		return false
	# Línea de visión (las paredes la bloquean)
	var espacio = get_world_3d().direct_space_state
	var origen = global_position + Vector3(0, 0.6, 0)
	var final = jugador.global_position + Vector3(0, 0.6, 0)
	var consulta = PhysicsRayQueryParameters3D.create(origen, final)
	consulta.exclude = [get_rid()]
	var resultado = espacio.intersect_ray(consulta)
	if resultado.is_empty():
		return true
	return resultado.collider == jugador

# Devuelve el siguiente punto al que caminar para llegar a "destino".
# Si hay malla de navegacion, rodea paredes y muebles; si no, va en linea recta.
func _siguiente_punto(destino: Vector3, delta: float) -> Vector3:
	if nav == null:
		return destino
	if NavigationServer3D.map_get_iteration_id(nav.get_navigation_map()) == 0:
		return destino
	_t_repath += delta
	var d_plano = Vector2(destino.x - _ultimo_destino.x, destino.z - _ultimo_destino.z).length()
	if d_plano > 0.5 or _t_repath > 0.5:
		nav.target_position = destino
		_ultimo_destino = destino
		_t_repath = 0.0
	# get_next_path_position() es lo que calcula la ruta, por eso se llama primero
	var siguiente = nav.get_next_path_position()
	# Si no hay ruta valida todavia (malla vacia o destino inalcanzable) camina en linea recta
	if nav.get_current_navigation_path().size() < 2:
		return destino
	if nav.is_navigation_finished():
		return destino
	return siguiente

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var dist = Vector2(jugador.global_position.x - global_position.x, jugador.global_position.z - global_position.z).length()
	var lo_ve = puede_ver_jugador(dist)

	# Detección
	if not persiguiendo:
		if lo_ve:
			tiempo_visto += delta
			material.albedo_color = COLOR_ALERTA
			if tiempo_visto >= TIEMPO_DETECCION:
				persiguiendo = true
				Inventario.perseguido = true
				get_tree().call_group("susto_nivel3", "rugir")
				tiempo_sin_ver = 0.0
				material.albedo_color = COLOR_PERSECUCION
		else:
			tiempo_visto = max(0.0, tiempo_visto - delta)
			if tiempo_visto == 0.0:
				material.albedo_color = COLOR_PATRULLA
	else:
		if lo_ve:
			tiempo_sin_ver = 0.0
		else:
			tiempo_sin_ver += delta
		if tiempo_sin_ver > TIEMPO_PERDER or dist > DISTANCIA_PERDER:
			persiguiendo = false
			Inventario.perseguido = false
			tiempo_visto = 0.0
			material.albedo_color = COLOR_PATRULLA

	# Atrapar
	if persiguiendo and dist < DISTANCIA_ATRAPAR:
		set_physics_process(false)
		Inventario.perseguido = false
		if susto_al_atrapar:
			await Susto.reproducir()
		Inventario.reiniciar_nivel_actual()
		Transicion.recargar()
		return

	# Movimiento
	var meta: Vector3
	var vel: float
	if persiguiendo:
		meta = Vector3(jugador.global_position.x, 0.0, jugador.global_position.z)
		vel = VEL_PERSECUCION
	else:
		var p = puntos[punto_actual]
		meta = Vector3(p.x, 0.0, p.y)
		vel = VEL_PATRULLA
		if Vector2(meta.x - global_position.x, meta.z - global_position.z).length() < 0.7:
			# En modo visita, al llegar al ultimo punto de la ruta la entidad se va
			if modo_visita and punto_actual >= puntos.size() - 1:
				visita_terminada.emit()
				desaparecer()
				return
			punto_actual = (punto_actual + 1) % puntos.size()

	var siguiente = _siguiente_punto(meta, delta)
	var direccion = siguiente - global_position
	direccion.y = 0
	if direccion.length() > 0.05:
		direccion = direccion.normalized()
		velocity.x = direccion.x * vel
		velocity.z = direccion.z * vel
		look_at(Vector3(siguiente.x, global_position.y, siguiente.z), Vector3.UP)
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()
