extends MeshInstance3D
class_name N_Line




var line_alpha: float = 1.0
var fade_speed: float = 0.5 
func _process(delta):
	if material_override:
		line_alpha = max(0.0, line_alpha - fade_speed * delta)
		material_override.albedo_color.a = line_alpha
		if line_alpha <= 0.0:
			queue_free()
