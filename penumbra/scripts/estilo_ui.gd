extends RefCounted
# Funciones para darle el mismo estilo (oscuro con rojo) a toda la interfaz.

static func caja(fondo, borde, grosor = 2):
	var estilo = StyleBoxFlat.new()
	estilo.bg_color = fondo
	estilo.border_color = borde
	estilo.set_border_width_all(grosor)
	return estilo

static func boton(b, ancho = 280, alto = 55, letra = 24):
	b.custom_minimum_size = Vector2(ancho, alto)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", letra)
	b.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	b.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	b.add_theme_stylebox_override("normal", caja(Color(0.08, 0.08, 0.09), Color(0.3, 0.3, 0.3)))
	b.add_theme_stylebox_override("hover", caja(Color(0.25, 0.03, 0.03), Color(0.75, 0.1, 0.1)))
	b.add_theme_stylebox_override("pressed", caja(Color(0.4, 0.05, 0.05), Color(0.9, 0.2, 0.2)))
	b.add_theme_stylebox_override("focus", caja(Color(0.25, 0.03, 0.03), Color(0.75, 0.1, 0.1)))

static func texto(l, letra = 22, color = Color(0.8, 0.8, 0.8)):
	l.add_theme_font_size_override("font_size", letra)
	l.add_theme_color_override("font_color", color)

static func panel(p):
	p.add_theme_stylebox_override("panel", caja(Color(0.05, 0.05, 0.06), Color(0.75, 0.1, 0.1)))
