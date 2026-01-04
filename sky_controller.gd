@tool
extends Node3D

## Controlador de Espacio para el Editor
## Modifica estos valores para ver cambios en tiempo real en el cielo.

@export_group("Nebulae")
@export_color_no_alpha var nebula_color_1: Color = Color(0.02, 0.05, 0.2):
	set(v):
		nebula_color_1 = v
		_update_shader()

@export_color_no_alpha var nebula_color_2: Color = Color(0.1, 0.02, 0.15):
	set(v):
		nebula_color_2 = v
		_update_shader()

@export_range(0.0, 1.0) var nebula_opacity: float = 0.8:
	set(v):
		nebula_opacity = v
		_update_shader()

@export_range(0.0, 5.0) var nebula_intensity: float = 1.0:
	set(v):
		nebula_intensity = v
		_update_shader()

@export_range(0.1, 5.0) var nebula_scale: float = 1.5:
	set(v):
		nebula_scale = v
		_update_shader()

@export_group("Stars")
@export_range(0.0, 20.0) var star_density: float = 1.0:
	set(v):
		star_density = v
		_update_shader()

@export_range(0.0, 10.0) var star_brightness: float = 1.5:
	set(v):
		star_brightness = v
		_update_shader()

@export_range(0.01, 2.0) var star_size: float = 0.1:
	set(v):
		star_size = v
		_update_shader()

@export_range(0.0, 20.0) var twinkle_intensity: float = 0.5:
	set(v):
		twinkle_intensity = v
		_update_shader()

@export_range(0.0, 50.0) var twinkle_speed: float = 12.0:
	set(v):
		twinkle_speed = v
		_update_shader()

@export_group("Depth and Colors")
@export_color_no_alpha var space_base_color: Color = Color(0.001, 0.001, 0.005):
	set(v):
		space_base_color = v
		_update_shader()

@export_range(0.0, 2.0) var galactic_edge: float = 0.5:
	set(v):
		galactic_edge = v
		_update_shader()

@export_range(0.0, 0.1) var parallax_amount: float = 0.001:
	set(v):
		parallax_amount = v
		_update_shader()

func _ready():
	_update_shader()

func _update_shader():
	# Intentar encontrar el material en el WorldEnvironment de la escena
	var parent = get_parent()
	var env_node: WorldEnvironment = null
	
	# Buscar el nodo WorldEnvironment en la raíz
	if parent:
		for child in parent.get_children():
			if child is WorldEnvironment:
				env_node = child
				break
	
	if env_node and env_node.environment and env_node.environment.sky:
		var mat = env_node.environment.sky.sky_material
		if mat is ShaderMaterial:
			mat.set_shader_parameter("nebula_color1", nebula_color_1)
			mat.set_shader_parameter("nebula_color2", nebula_color_2)
			mat.set_shader_parameter("nebula_opacity", nebula_opacity)
			mat.set_shader_parameter("nebula_intensity", nebula_intensity)
			mat.set_shader_parameter("nebula_scale", nebula_scale)
			mat.set_shader_parameter("star_density", star_density)
			mat.set_shader_parameter("star_brightness", star_brightness)
			mat.set_shader_parameter("star_size", star_size)
			mat.set_shader_parameter("twinkle_intensity", twinkle_intensity)
			mat.set_shader_parameter("twinkle_speed", twinkle_speed)
			mat.set_shader_parameter("base_color", space_base_color)
			mat.set_shader_parameter("galactic_edge_intensity", galactic_edge)
			mat.set_shader_parameter("parallax_factor", parallax_amount)
