extends Node3D
# Script de cada nivel: prepara la navegacion de la entidad y muestra el mensaje inicial.

@export_multiline var mensaje_inicial = ""
@export var region_navegacion: NavigationRegion3D

func _ready():
	Inventario.escondido = false
	Inventario.perseguido = false
	# La malla de navegacion ya viene guardada en assets/navegacion/. Si algun dia cambias las paredes
	# o muebles del nivel, selecciona el nodo "Navegacion" y presiona "Bake NavMesh" en el editor.
	# Si la malla estuviera vacia, se hornea al cargar como respaldo.
	if region_navegacion and region_navegacion.navigation_mesh and region_navegacion.navigation_mesh.get_polygon_count() == 0:
		await get_tree().process_frame
		await get_tree().process_frame
		region_navegacion.bake_navigation_mesh(false)
	if mensaje_inicial != "":
		await get_tree().create_timer(1.4).timeout
		get_tree().call_group("ui_interaccion", "mostrar_nota", mensaje_inicial)
