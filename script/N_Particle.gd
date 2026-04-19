extends CPUParticles3D
class_name N_Particle

func _ready() -> void:
	await Util.create_timer(2.0)
	queue_free()
