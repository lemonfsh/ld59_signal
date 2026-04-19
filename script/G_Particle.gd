extends Node







enum ParticleType {
	Converge,
	Diverge,
	Die,
	Hit,
}

var lookup_dict : Dictionary[ParticleType, PackedScene] = {
	ParticleType.Converge : preload("res://scenes/p_converge.tscn"),
	ParticleType.Diverge : preload("res://scenes/p_diverge.tscn"),
	ParticleType.Die : preload("res://scenes/p_die.tscn"),
	ParticleType.Hit : preload("res://scenes/p_hit.tscn"),
}


func spawn_particle(particle_type : ParticleType, pos : Vector3) -> N_Particle:
	var instance : N_Particle = lookup_dict[particle_type].instantiate()
	add_child(instance)
	instance.global_position = pos
	instance.emitting = true
	instance.one_shot = true
	return instance
