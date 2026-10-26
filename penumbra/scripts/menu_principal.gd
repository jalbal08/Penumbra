extends Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	$Fondo.color = Color(0.04, 0.04, 0.05)

	$Titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Titulo.add_theme_font_size_override("font_size", 56)
	$Titulo.add_theme_color_override("font_color", Color(0.75, 0.1, 0.1))

	$Botones.add_theme_constant_override("separation", 18)
	for boton in $Botones.get_children():
		_estilizar(boton)

	$Botones/BtnJugar.pressed.connect(_on_jugar)
	$Botones/BtnSalir.pressed.connect(_on_salir)

func _estilizar(boton: Button):
	boton.custom_minimum_size = Vector2(280, 55)
	boton.add_theme_font_size_override("font_size", 24)
	boton.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	boton.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	boton.add_theme_stylebox_override("normal", _crear_estilo(Color(0.08, 0.08, 0.09), Color(0.3, 0.3, 0.3)))
	boton.add_theme_stylebox_override("hover", _crear_estilo(Color(0.25, 0.03, 0.03), Color(0.75, 0.1, 0.1)))
	boton.add_theme_stylebox_override("pressed", _crear_estilo(Color(0.4, 0.05, 0.05), Color(0.9, 0.2, 0.2)))
	boton.add_theme_stylebox_override("focus", _crear_estilo(Color(0.25, 0.03, 0.03), Color(0.75, 0.1, 0.1)))

func _crear_estilo(fondo: Color, borde: Color) -> StyleBoxFlat:
	var estilo = StyleBoxFlat.new()
	estilo.bg_color = fondo
	estilo.border_color = borde
	estilo.set_border_width_all(2)
	return estilo

func _on_jugar():
	get_tree().change_scene_to_file("res://scenes/nivel1_recepcion.tscn")

func _on_salir():
	get_tree().quit()
